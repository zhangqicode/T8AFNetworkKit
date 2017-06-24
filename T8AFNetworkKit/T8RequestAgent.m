//
//  T8RequestAgent.m
//  Pods
//
//  Created by JustBen on 06/03/2017.
//
//

#import "T8RequestAgent.h"
#import <pthread.h>


@interface T8RequestAgent ()
{
    pthread_mutex_t _lock;
}

@property (nonatomic, strong, readwrite) NSMutableSet *requests;    //  请求池

@end


@implementation T8RequestAgent

- (void)dealloc
{
    pthread_mutex_destroy(&_lock);
    
    if (_requests) {
        [_requests removeAllObjects];
        _requests = nil;
    }
}

- (id)init
{
    self = [super init];
    if (self) {
        pthread_mutex_init(&_lock, NULL);
        _requests = [[NSMutableSet alloc] init];
    }
    
    return self;
}

- (void)addRequest:(id<T8Request>)request
{
    if (request) {
        pthread_mutex_lock(&_lock);
        [_requests addObject:request];
        pthread_mutex_unlock(&_lock);
    }
}

- (void)removeRequest:(id<T8Request>)request
{
    if (request) {
        pthread_mutex_lock(&_lock);
        [_requests removeObject:request];
        pthread_mutex_unlock(&_lock);
    }
}

- (void)removeAllRequests
{
    pthread_mutex_lock(&_lock);
    [_requests removeAllObjects];
    pthread_mutex_unlock(&_lock);
}

- (void)cancelAllRequests
{
    pthread_mutex_lock(&_lock);
    for (id<T8Request> request in _requests) {
        [request cancel];
    }
    pthread_mutex_unlock(&_lock);
}

@end
