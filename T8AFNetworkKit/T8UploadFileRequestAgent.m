//
//  T8UploadFileRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8UploadFileRequestAgent.h"


@interface T8UploadFileRequestAgent ()
{
    NSMutableSet *_requests;   //  请求池
}

@end

@implementation T8UploadFileRequestAgent

@synthesize requests = _requests;

+ (T8UploadFileRequestAgent *)sharedUploadFileRequestAgent
{
    static T8UploadFileRequestAgent *sharedUploadFileRequestAgent;
    static dispatch_once_t onceTokenForSharedUploadFileRequestAgent;
    dispatch_once(&onceTokenForSharedUploadFileRequestAgent, ^{
        sharedUploadFileRequestAgent = [[T8UploadFileRequestAgent alloc] init];
    });
    
    return sharedUploadFileRequestAgent;
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
