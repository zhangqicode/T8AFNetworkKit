//
//  T8BatchRequest.m
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import "T8BatchRequest.h"


@interface T8BatchRequest ()
{
    id<T8RequestCompleteDelegate> _completeDelegate;
}

@property (nonatomic, strong) NSArray *requests;
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

- (void)dealloc
{
    _requests = nil;
    _completeBlock = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        _completeCondition = BatchRequestCompleteCondiction_AnyFailed;
        _completeBlock = nil;
        
        _completeCount = 0;
        _succeedCount = 0;
        _failedCount = 0;
        
        self.state = T8RequestState_Unkown;
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
        _completeBlock = [completeBlock copy];
        
        self.state = T8RequestState_Ready;
    }
    
    return self;
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
    
    for (id<T8Request> request in _requests) {
        request.completeDelegate = self;
        [request start];
        
        [NSThread sleepForTimeInterval:0.05f];
    }
}

- (void)cancel
{
    for (id<T8Request> request in _requests) {
        [request cancel];
    }
}


#pragma mark -
#pragma mark - completeDelegate get/set methods

- (void)setCompleteDelegate:(id<T8RequestCompleteDelegate>)completeDelegate
{
    _completeDelegate = completeDelegate;
}

- (id<T8RequestCompleteDelegate>)completeDelegate
{
    return _completeDelegate;
}


#pragma mark -
#pragma mark - class extension methods

- (void)reset
{
    _completeCount = 0;
    _succeedCount = 0;
    _failedCount = 0;
}


#pragma mark -
#pragma mark - T8RequestCompleteDelegate

- (void)requestCompleted:(id<T8Request>)request
{
    self.completeCount++;
    if (request.state == T8RequestState_CompletedSucceed) {
        self.succeedCount++;
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
    }
}

@end
