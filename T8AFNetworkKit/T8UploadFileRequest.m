//
//  T8UploadFileRequest.m
//  T8AFNetworkKitDemo
//
//  Created by JustBen on 8/15/16.
//  Copyright © 2016 琦张. All rights reserved.
//

#import "T8UploadFileRequest.h"

@interface T8UploadFileRequest ()
{
    id<T8RequestCompleteDelegate> _completeDelegate;
}

//  该请求对应的AFHTTPRequestOperation
@property (nonatomic, strong) AFHTTPRequestOperation *requestOperation;

@property (nonatomic, copy, readwrite) NSArray *fileInfos;
@property (nonatomic, copy, readwrite) NSString *path;
@property (nonatomic, strong, readwrite) NSDictionary *params;
@property (nonatomic, copy, readwrite) RequestProgressBlock progressBlock;
@property (nonatomic, copy, readwrite) RequestComplete completeBlock;

@property (nonatomic, assign, readwrite) T8RequestState state;

@end


@implementation T8UploadFileRequest

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
        _params = nil;
        _completeBlock = nil;
        
        self.state = T8RequestState_Unkown;
    }
    
    return self;
}

- (id)initWithFileInfos:(NSArray *)fileInfos path:(NSString *)path params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completeBlock:(RequestComplete)completeBlock
{
    self = [self init];
    if (self) {
        _path = path;
        _params = [params copy];
        _progressBlock = [progressBlock copy];
        _completeBlock = [completeBlock copy];
        
        self.state = T8RequestState_Ready;
    }
    
    return self;
}

#pragma mark -
#pragma mark - T8Request Protocol

- (void)start
{
    if (self.state == T8RequestState_Loading) {
        return;
    }
    
    self.state = T8RequestState_Loading;
    
    self.requestOperation = [T8BaseNetworkService uploadFilesRequestWithFileInfos:self.fileInfos urlPath:self.path params:[self.params mutableCopy] progressBlock:self.progressBlock completBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
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
    }];
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
