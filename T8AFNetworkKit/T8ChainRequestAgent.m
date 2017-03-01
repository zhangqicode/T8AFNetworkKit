//
//  T8ChainRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8ChainRequestAgent.h"


@interface T8ChainRequestAgent ()
{
    NSMutableSet *_requests;   //  请求池
}

@end

@implementation T8ChainRequestAgent

@synthesize requests = _requests;

+ (T8ChainRequestAgent *)sharedChainRequestAgent
{
    static T8ChainRequestAgent *sharedChainRequestAgent;
    static dispatch_once_t onceTokenForSharedChainRequestAgent;
    dispatch_once(&onceTokenForSharedChainRequestAgent, ^{
        sharedChainRequestAgent = [[T8ChainRequestAgent alloc] init];
    });
    
    return sharedChainRequestAgent;
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
