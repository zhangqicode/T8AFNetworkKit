//
//  T8BaseRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8BaseRequestAgent.h"


@interface T8BaseRequestAgent ()
{
    NSMutableSet *_requests;   //  请求池
}

@end

@implementation T8BaseRequestAgent

@synthesize requests = _requests;

+ (T8BaseRequestAgent *)sharedBaseRequestAgent
{
    static T8BaseRequestAgent *sharedBaseRequestAgent;
    static dispatch_once_t onceTokenForSharedBaseRequestAgent;
    dispatch_once(&onceTokenForSharedBaseRequestAgent, ^{
        sharedBaseRequestAgent = [[T8BaseRequestAgent alloc] init];
    });
    
    return sharedBaseRequestAgent;
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
