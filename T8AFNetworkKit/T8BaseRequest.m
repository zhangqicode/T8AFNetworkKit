//
//  T8BaseRequest.m
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import "T8BaseRequest.h"


@interface T8BaseRequest ()
{
    id<T8RequestCompleteDelegate> _completeDelegate;
}

//  该请求对应的AFHTTPRequestOperation
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@property (nonatomic, strong, readwrite) NSString *path;
@property (nonatomic, assign, readwrite) HttpMethod httpMethod;
@property (nonatomic, strong, readwrite) NSDictionary *params;
@property (nonatomic, assign, readwrite) BOOL useCacheWhenFailed;
@property (nonatomic, copy, readwrite) RequestComplete completeBlock;

@property (nonatomic, assign, readwrite) T8RequestState state;

@end


@implementation T8BaseRequest

- (void)dealloc
{
    if (_requestOperation) {
        [_requestOperation cancel];
        _requestOperation = nil;
    }
    
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
        
        self.state = T8RequestState_Unkown;
    }
    
    return self;
}

- (id)initWithPath:(NSString *)path httpMethod:(HttpMethod)httpMethod params:(NSDictionary *)params completeBlock:(RequestComplete)completeBlock useCacheWhenFailed:(BOOL)useCacheWhenFailed
{
    self = [self init];
    if (self) {
        _path = path;
        _httpMethod = httpMethod;
        _params = [params copy];
        _useCacheWhenFailed = useCacheWhenFailed;
        _completeBlock = [completeBlock copy];
        
        self.state = T8RequestState_Ready;
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
    
    self.state = T8RequestState_Loading;
    
    self.requestOperation = [T8BaseNetworkService sendRequestUrlPath:self.path httpMethod:self.httpMethod dictParams:[self.params mutableCopy] completeBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        if (self.completeBlock) {
            self.completeBlock(status, data, error);
        }
        
        if (status == RequestStatusSuccess) {
            self.state = T8RequestState_CompletedSucceed;
        } else {
            self.state = T8RequestState_CompletedFailed;
        }
        
        if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
            [self.completeDelegate requestCompleted:self];
        }
        
    } useCacheWhenFail:self.useCacheWhenFailed];
}

- (void)cancel
{
    if (self.state == T8RequestState_CompletedFailed || self.state == T8RequestState_CompletedSucceed) {
        return;
    }
    self.state = T8RequestState_CompletedFailed;
    
    if (self.requestOperation && !self.requestOperation.isCancelled) {
        [self.requestOperation cancel];
    }
    
    if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
        [self.completeDelegate requestCompleted:self];
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

@end
