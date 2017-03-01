//
//  T8BatchRequest.m
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import "T8BatchRequest.h"
#import "T8BatchRequestAgent.h"


@interface T8BatchRequest ()
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

@property (nonatomic, copy) NSArray *requests;
@property (nonatomic, assign) BatchRequestCompleteCondiction completeCondition;
@property (nonatomic, copy) BatchRequestCompleteBlock completeBlock;


@property (nonatomic, assign, readwrite) NSUInteger completeCount;
@property (nonatomic, assign, readwrite) NSUInteger succeedCount;
@property (nonatomic, assign, readwrite) NSUInteger failedCount;

//  重置一些属性值
- (void)reset;

@property (nonatomic, assign, readwrite) T8RequestState state;

@end


@implementation T8BatchRequest

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
    _requests = nil;
    _completeBlock = nil;
    _retryDispatchQueue = nil;
    _completeBlock = nil;
}


#pragma mark -
#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        _completeCondition = BatchRequestCompleteCondiction_AllRequested;
        _completeBlock = nil;
        
        _completeCount = 0;
        _succeedCount = 0;
        _failedCount = 0;
        _requestInterval = 0.05f;
        
        _state = T8RequestState_Unkown;
    }
    
    return self;
}

- (id)initWithRequests:(NSArray *)requests completeCondition:(BatchRequestCompleteCondiction)completeCondition completeBlock:(BatchRequestCompleteBlock)completeBlock
{
    self = [self init];
    if (self) {
        if (!requests || requests.count <= 0) {
            return nil;
        }
        
        _requests = [[NSArray alloc] initWithArray:requests];
        
        _completeCondition = completeCondition;
        if (completeBlock) {
            _completeBlock = [completeBlock copy];
        }
        _state = T8RequestState_Ready;
        
        _retryEnable = NO;
        _maxRetryCount = T8Request_DefaultMaxRetryCount;
        _retryCount = 0;
        _retryInterval = T8Request_DefaultRetryInterval;
        _retryProgressive = NO;
        _retryDispatchQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (id)initWithRequests:(NSArray *)requests completeBlock:(BatchRequestCompleteBlock)completeBlock
{
    return [self initWithRequests:requests completeCondition:BatchRequestCompleteCondiction_AllRequested completeBlock:completeBlock];
}


#pragma mark -
#pragma mark - T8Request Protocol

- (void)start
{
    [self reset];
    
    if (self.state == T8RequestState_Loading) {
        return;
    }
    
    //  将当前的请求添加到代理中
    [[T8BatchRequestAgent sharedBatchRequestAgent] addRequest:self];
    
    self.state = T8RequestState_Loading;
    
    for (id<T8Request> request in _requests) {
        request.retryEnable = self.retryEnable;
        request.maxRetryCount = self.maxRetryCount;
        request.retryCount = 0;
        request.retryInterval = self.retryInterval;
        request.retryProgressive = self.retryProgressive;
        request.retryDispatchQueue = self.retryDispatchQueue;
        request.completeDelegate = self;
        [request start];
        
        [NSThread sleepForTimeInterval:self.requestInterval];
    }
}

- (void)cancel
{
    if (self.state == T8RequestState_CompletedFailed || self.state == T8RequestState_CompletedSucceed || self.state == T8RequestState_Canceled) {
        return;
    }
    
    self.state = T8RequestState_Canceled;
    
    if (self.completeBlock) {
        self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
    }
    
    if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
        [self.completeDelegate requestCompleted:self];
    }
    
    for (id<T8Request> request in _requests) {
        [request cancel];
    }
    
    //  将当前的请求从代理中移除
    [[T8BatchRequestAgent sharedBatchRequestAgent] removeRequest:self];
}


#pragma mark -
#pragma mark - class extension methods

- (void)reset
{
    _completeCount = 0;
    _succeedCount = 0;
    _failedCount = 0;
    _retryCount = 0;
}


#pragma mark -
#pragma mark - T8RequestCompleteDelegate

- (void)requestCompleted:(id<T8Request>)request
{
    if (self.state == T8RequestState_Loading) {
        self.completeCount++;
        if (request.state == T8RequestState_CompletedSucceed) {
            self.succeedCount++;
        } else {
            self.failedCount++;
            
            if (self.completeCondition == BatchRequestCompleteCondiction_AnyFailed && self.state == T8RequestState_Loading) {
                self.state = T8RequestState_CompletedFailed;
                
                for (id<T8Request> request in _requests) {
                    [request cancel];
                }
                
                if (self.completeBlock) {
                    self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
                }
                
                if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                    [self.completeDelegate requestCompleted:self];
                }
                
                //  将当前的请求从代理中移除
                [[T8BatchRequestAgent sharedBatchRequestAgent] removeRequest:self];
                
                return;
            }
        }
        
        if (self.completeCount == self.requests.count) {
            self.state = T8RequestState_CompletedSucceed;
            
            if (self.completeBlock) {
                self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
            }
            
            if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                [self.completeDelegate requestCompleted:self];
            }
            
            //  将当前的请求从代理中移除
            [[T8BatchRequestAgent sharedBatchRequestAgent] removeRequest:self];
        }
    }
}

@end
