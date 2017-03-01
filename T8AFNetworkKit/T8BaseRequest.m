//
//  T8BaseRequest.m
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import "T8BaseRequest.h"
#import "T8BaseRequestAgent.h"


@interface T8BaseRequest ()
{
    id<T8RequestCompleteDelegate> __weak _completeDelegate;
    
    BOOL _retryEnable;                  //  是否允许重发
    NSUInteger _maxRetryCount;          //  最大重发次数
    NSUInteger _retryCount;             //  已重发次数
    NSTimeInterval _retryInterval;      //  重发间隔
    BOOL _retryProgressive;             //  重发时间间隔是否是累进的。若是累进的，时间间隔为retryInterval的指数为(已发送次数+1)的幂的值，否则时间间隔为retryInterval。
    NSArray<NSNumber *> *_fatalStatusCodes;    // 自定义的灾难性的网络响应错误code
    dispatch_queue_t __weak _retryDispatchQueue;  //  在哪个dispatch启动重发，默认为main_queue
}

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, assign, readwrite) T8RequestState state;

@end


@implementation T8BaseRequest

@synthesize completeDelegate = _completeDelegate;
@synthesize retryEnable = _retryEnable;
@synthesize maxRetryCount = _maxRetryCount;
@synthesize retryCount = _retryCount;
@synthesize retryInterval = _retryInterval;
@synthesize retryProgressive = _retryProgressive;
@synthesize fatalStatusCodes = _fatalStatusCodes;
@synthesize retryDispatchQueue = _retryDispatchQueue;


#pragma mark -
#pragma mark - dealloc

- (void)dealloc
{
    if (_dataTask) {
        [_dataTask cancel];
        _dataTask = nil;
    }
    _completeDelegate = nil;
    _retryDispatchQueue = nil;
    _completeBlock = nil;
}


#pragma mark - 
#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        _path = @"";
        _httpMethod = HttpMethodGet;
        _params = nil;
        
        _useCacheWhenFailed = NO;
        _completeBlock = nil;
        
        _state = T8RequestState_Unkown;
        
        _retryEnable = NO;
        _maxRetryCount = T8Request_DefaultMaxRetryCount;
        _retryCount = 0;
        _retryInterval = T8Request_DefaultRetryInterval;
        _retryProgressive = YES;
        _retryDispatchQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path httpMethod:(HttpMethod)httpMethod params:(NSDictionary *)params completeBlock:(RequestComplete)completeBlock useCacheWhenFailed:(BOOL)useCacheWhenFailed
{
    self = [self init];
    if (self) {
        _path = [path copy];
        _httpMethod = httpMethod;
        
        if (params) {
            _params = [params copy];
        }
        _useCacheWhenFailed = useCacheWhenFailed;
        if (completeBlock) {
            _completeBlock = [completeBlock copy];
        }
        
        _state = T8RequestState_Ready;
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path httpMethod:(HttpMethod)httpMethod params:(NSDictionary *)params completeBlock:(RequestComplete)completeBlock
{
    return [self initWithPath:path httpMethod:httpMethod params:params completeBlock:completeBlock useCacheWhenFailed:NO];
}


#pragma mark -
#pragma mark - T8Request Protocol

- (void)start
{
    if (self.state == T8RequestState_Loading) {
        return;
    }
    
    //  将当前请求添加到代理中
    [[T8BaseRequestAgent sharedBaseRequestAgent] addRequest:self];
    
    self.state = T8RequestState_Loading;
    
    __weak __typeof(self) weakSelf = self;
    self.dataTask = [T8BaseNetworkService sendRequestUrlPath:self.path httpMethod:self.httpMethod dictParams:[self.params mutableCopy] completeBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        if (weakSelf.retryEnable && weakSelf.retryCount < weakSelf.maxRetryCount && status == RequestStatusFailure && weakSelf.state != T8RequestState_Canceled && !([T8NetworkError isFatalErrorWithErrorCode:error.code] || (weakSelf.fatalStatusCodes && [weakSelf.fatalStatusCodes containsObject:@(error.code)]))) {
            
            weakSelf.retryCount++;
            weakSelf.state = T8RequestState_Ready;
            if (weakSelf.retryInterval > 0.0f) {
                dispatch_time_t delay;
                if (weakSelf.retryProgressive) {
                    delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(pow(weakSelf.retryInterval, weakSelf.retryCount)) * NSEC_PER_SEC);
                } else {
                    delay = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(weakSelf.retryInterval * NSEC_PER_SEC));
                }
                
                dispatch_after(delay, weakSelf.retryDispatchQueue, ^{
                    if ((weakSelf.dataTask && weakSelf.dataTask.state == NSURLSessionTaskStateCanceling) || weakSelf.state == T8RequestState_Canceled) {
                        return; //  若请求被主动取消了，则不再重发。
                    }
                    
                    [weakSelf start];
                });
            } else {
                dispatch_async(weakSelf.retryDispatchQueue, ^{
                    if ((weakSelf.dataTask && weakSelf.dataTask.state == NSURLSessionTaskStateCanceling) || weakSelf.state == T8RequestState_Canceled) {
                        return; //  若请求被主动取消了，则不再重发。
                    }
                    
                    [weakSelf start];
                });
            }
        } else {
            if (weakSelf.completeBlock) {
                weakSelf.completeBlock(status, data, error);
            }
            
            if (status == RequestStatusSuccess) {
                weakSelf.state = T8RequestState_CompletedSucceed;
            } else {
                weakSelf.state = T8RequestState_CompletedFailed;
            }
            
            if ([weakSelf.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                [weakSelf.completeDelegate requestCompleted:weakSelf];
            }
            
            //  将当前请求从代理中移除
            [[T8BaseRequestAgent sharedBaseRequestAgent] removeRequest:weakSelf];
        }
    } useCacheWhenFail:self.useCacheWhenFailed];
}

- (void)cancel
{
    if (self.state == T8RequestState_CompletedFailed || self.state == T8RequestState_CompletedSucceed || self.state == T8RequestState_Canceled) {
        return;
    }
    self.state = T8RequestState_Canceled;
    
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
        [self.completeDelegate requestCompleted:self];
    }
    
    //  将当前请求从代理中移除
    [[T8BaseRequestAgent sharedBaseRequestAgent] removeRequest:self];
}

@end
