//
//  T8ChainRequest.m
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import "T8ChainRequest.h"
#import "T8ChainRequestAgent.h"


@interface T8ChainRequest ()
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

@property (nonatomic, copy) NSMutableArray *requests;
@property (nonatomic, assign) NSUInteger currentRequestIndex;
@property (nonatomic, assign) ChainRequestCompleteCondiction completeCondition;
@property (nonatomic, copy) ChainRequestCompleteBlock completeBlock;

@property (nonatomic, assign, readwrite) NSUInteger completeCount;
@property (nonatomic, assign, readwrite) NSUInteger succeedCount;
@property (nonatomic, assign, readwrite) NSUInteger failedCount;

@property (nonatomic, assign, readwrite) T8RequestState state;

//  启动下一个请求
- (void)startNextRequest;

//  重置一些属性值
- (void)reset;

@end


@implementation T8ChainRequest

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
    [_requests removeAllObjects];
    _requests = nil;
    _completeBlock = nil;
}


#pragma mark -
#pragma mark - init

- (id)init
{
    self = [super init];
    if (self) {
        _requests = [[NSMutableArray alloc] init];
        _completeCondition = ChainRequestCompleteCondiction_AnyFailed;
        _currentRequestIndex = 0;
        _completeCount = 0;
        _succeedCount = 0;
        _failedCount = 0;
        _completeBlock = nil;
        _shouldComplete = YES;
        
        _state = T8RequestState_Unkown;
        
        _retryEnable = NO;
        _maxRetryCount = T8Request_DefaultMaxRetryCount;
        _retryCount = 0;
        _retryInterval = T8Request_DefaultRetryInterval;
        _retryProgressive = NO;
        _retryDispatchQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (id)initWithRequests:(NSArray *)requests completeCondition:(ChainRequestCompleteCondiction)completeCondition completeBlock:(ChainRequestCompleteBlock)completeBlock shouldComplete:(BOOL)shouldComplete
{
    self = [self init];
    if (self) {
        [_requests addObjectsFromArray:requests];
        _completeCondition = completeCondition;
        if (completeBlock) {
            _completeBlock = [completeBlock copy];
        }
        _shouldComplete = shouldComplete;
        
        _state = T8RequestState_Ready;
    }
    
    return self;
}

- (id)initWithRequests:(NSArray *)requests completeBlock:(ChainRequestCompleteBlock)completeBlock shouldComplete:(BOOL)shouldComplete
{
    return [self initWithRequests:requests completeCondition:ChainRequestCompleteCondiction_AnyFailed completeBlock:completeBlock shouldComplete:shouldComplete];
}


#pragma mark -
#pragma mark - T8Request Protocol

- (void)start
{
    [self reset];
    
    if (self.state == T8RequestState_Loading) {
        return;
    }
    
    //  将当前请求添加到代理中
    [[T8ChainRequestAgent sharedChainRequestAgent] addRequest:self];
    
    self.state = T8RequestState_Loading;
    
    [self startNextRequest];
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
}


#pragma mark -
#pragma mark - object methods

- (void)addRequest:(id<T8Request>)request shouldComplete:(BOOL)shouldComplete
{
    if (request) {
        BOOL shouldStartImmediate = NO;
        if (self.requests.count <= self.currentRequestIndex) {
            shouldStartImmediate = YES;
        }
        
        [self.requests addObject:request];
        
        self.shouldComplete = shouldComplete;
        
        if (shouldStartImmediate && self.state == T8RequestState_Loading) {
            [self startNextRequest];
        }
    }
}


#pragma mark - 
#pragma mark - setters

- (void)setShouldComplete:(BOOL)shouldComplete
{
    _shouldComplete = shouldComplete;
    
    if (_shouldComplete && self.completeCount >= self.requests.count) {
        self.state = T8RequestState_CompletedSucceed;
        
        if (self.completeBlock) {
            self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
        }
        
        if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
            [self.completeDelegate requestCompleted:self];
        }
        
        //  将当前请求从代理中移除
        [[T8ChainRequestAgent sharedChainRequestAgent] removeRequest:self];
    }
}


#pragma mark -
#pragma mark - class extension methods

- (void)startNextRequest
{
    if (self.requests.count > self.currentRequestIndex) {
        id<T8Request> request = _requests[_currentRequestIndex];
        request.retryEnable = self.retryEnable;
        request.maxRetryCount = self.maxRetryCount;
        request.retryCount = 0;
        request.retryInterval = self.retryInterval;
        request.retryProgressive = self.retryProgressive;
        request.retryDispatchQueue = self.retryDispatchQueue;
        request.completeDelegate = self;
        
        self.currentRequestIndex++;
        
        [request start];
    }
}

- (void)reset
{
    _currentRequestIndex = 0;
    _completeCount = 0;
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
            
            if (self.completeCount >= self.requests.count && self.shouldComplete) {
                self.state = T8RequestState_CompletedSucceed;
                
                if (self.completeBlock) {
                    self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
                }
                
                if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                    [self.completeDelegate requestCompleted:self];
                }
                
                //  将当前请求从代理中移除
                [[T8ChainRequestAgent sharedChainRequestAgent] removeRequest:self];
            } else {
                [self startNextRequest];
            }
        } else {
            self.failedCount++;
            
            if (self.completeCondition == BatchRequestCompleteCondiction_AnyFailed) {
                self.state = T8RequestState_CompletedFailed;
                
                if (self.completeBlock) {
                    self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
                }
                
                if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                    [self.completeDelegate requestCompleted:self];
                }
                
                //  将当前请求从代理中移除
                [[T8ChainRequestAgent sharedChainRequestAgent] removeRequest:self];
            } else if (self.completeCondition == BatchRequestCompleteCondiction_AllRequested) {
                if (self.completeCount >= self.requests.count && self.shouldComplete) {
                    self.state = T8RequestState_CompletedSucceed;
                    
                    if (self.completeBlock) {
                        self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
                    }
                    
                    if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                        [self.completeDelegate requestCompleted:self];
                    }
                    
                    //  将当前请求从代理中移除
                    [[T8ChainRequestAgent sharedChainRequestAgent] removeRequest:self];
                } else {
                    [self startNextRequest];
                }
            }
        }
    }
}

@end
