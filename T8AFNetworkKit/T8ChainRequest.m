//
//  T8ChainRequest.m
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import "T8ChainRequest.h"


@interface T8ChainRequest ()
{
    id<T8RequestCompleteDelegate> _completeDelegate;
}

@property (nonatomic, strong) NSMutableArray *requests;
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

- (void)dealloc
{
    [_requests removeAllObjects];
    _requests = nil;
    _completeBlock = nil;
}

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
        
        self.state = T8RequestState_Unkown;
    }
    
    return self;
}

- (id)initWithRequests:(NSArray *)requests completeCondition:(ChainRequestCompleteCondiction)completeCondition completeBlock:(ChainRequestCompleteBlock)completeBlock shouldComplete:(BOOL)shouldComplete
{
    self = [self init];
    if (self) {
        [_requests addObjectsFromArray:requests];
        _completeCondition = completeCondition;
        _completeBlock = [completeBlock copy];
        _shouldComplete = shouldComplete;
        
        self.state = T8RequestState_Ready;
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
    
    self.state = T8RequestState_Loading;
    
    [self startNextRequest];
}

- (void)cancel
{
    for (id<T8Request> request in _requests) {
        [request cancel];
    }
}

- (void)setCompleteDelegate:(id<T8RequestCompleteDelegate>)completeDelegate
{
    _completeDelegate = completeDelegate;
}

- (id<T8RequestCompleteDelegate>)completeDelegate
{
    return _completeDelegate;
}

#pragma mark -
#pragma mark - object methods

- (void)addRequest:(id<T8Request>)request shouldComplete:(BOOL)shouldComplete
{
    if (!_shouldComplete && request) {
        _shouldComplete = shouldComplete;
        
        BOOL shouldStartImmediate = NO;
        if (self.requests.count <= self.currentRequestIndex) {
            shouldStartImmediate = YES;
        }
        
        [self.requests addObject:request];
        
        if (shouldStartImmediate) {
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
    }
}

#pragma mark -
#pragma mark - class extension methods

- (void)startNextRequest
{
    if (self.requests.count > self.currentRequestIndex) {
        id<T8Request> request = _requests[_currentRequestIndex];
        request.completeDelegate = self;
        
        [request start];
    }
}

- (void)reset
{
    _currentRequestIndex = 0;
    _completeCount = 0;
}


#pragma mark -
#pragma mark - T8RequestCompleteDelegate

- (void)requestCompleted:(id<T8Request>)request
{
    request.completeDelegate = nil;
    
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
        } else {
            self.currentRequestIndex++;
            
            [self startNextRequest];
        }
    } else {
        self.failedCount++;
        
        if (self.completeCondition == BatchRequestCompleteCondiction_AnyFailed) {
            self.state = T8RequestState_CompletedFailed;
            
            [self cancel];
            
            if (self.completeBlock) {
                self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
            }
            
            if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                [self.completeDelegate requestCompleted:self];
            }
        } else if (self.completeCondition == BatchRequestCompleteCondiction_AllRequested) {
            if (self.completeCount >= self.requests.count && self.shouldComplete) {
                self.state = T8RequestState_CompletedSucceed;
                
                if (self.completeBlock) {
                    self.completeBlock(self.completeCount, self.succeedCount, self.failedCount);
                }
                
                if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
                    [self.completeDelegate requestCompleted:self];
                }
            } else {
                self.currentRequestIndex++;
                
                [self startNextRequest];
            }
        }
    }
}

@end
