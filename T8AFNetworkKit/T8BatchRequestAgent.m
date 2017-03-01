//
//  T8BatchRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8BatchRequestAgent.h"


@interface T8BatchRequestAgent ()
{
    NSMutableSet *_requests;   //  请求池
}

@end

@implementation T8BatchRequestAgent

@synthesize requests = _requests;

+ (T8BatchRequestAgent *)sharedBatchRequestAgent
{
    static T8BatchRequestAgent *sharedBatchRequestAgent;
    static dispatch_once_t onceTokenForSharedBatchRequestAgent;
    dispatch_once(&onceTokenForSharedBatchRequestAgent, ^{
        sharedBatchRequestAgent = [[T8BatchRequestAgent alloc] init];
    });
    
    return sharedBatchRequestAgent;
}

- (id)init
{
    self = [super init];
    if (self) {
        _requests = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)addRequest:(id<T8Request>)request
{
    if (request) {
        [_requests addObject:request];
    }
}

- (void)removeRequest:(id<T8Request>)request
{
    if (request) {
        [_requests removeObject:request];
    }
}

- (void)removeAllRequests
{
    [_requests removeAllObjects];
}

- (void)cancelAllRequests
{
    for (id<T8Request> request in _requests) {
        [request cancel];
    }
}

@end
