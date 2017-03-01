//
//  T8UploadFileRequest.m
//  T8AFNetworkKitDemo
//
//  Created by JustBen on 8/15/16.
//  Copyright © 2016 琦张. All rights reserved.
//

#import "T8UploadFileRequest.h"
#import "T8UploadFileRequestAgent.h"


@interface T8UploadFileRequest ()
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

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;

@property (nonatomic, assign, readwrite) T8RequestState state;

@end


@implementation T8UploadFileRequest

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
    if (_dataTask) {
        [_dataTask cancel];
        _dataTask = nil;
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
        
        _state = T8RequestState_Unkown;
        
        _retryEnable = NO;
        _maxRetryCount = T8Request_DefaultMaxRetryCount;
        _retryCount = 0;
        _retryInterval = T8Request_DefaultRetryInterval;
        _retryProgressive = YES;
        _retryDispatchQueue = dispatch_get_main_queue();
    }
    
    return self;
}

- (id)initWithFileInfos:(NSArray *)fileInfos path:(NSString *)path params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completeBlock:(RequestComplete)completeBlock
{
    self = [self init];
    if (self) {
        if (fileInfos) {
            _fileInfos = [fileInfos copy];
        }
        
        _path = path;
        
        if (params) {
            _params = [params copy];
        }
        
        if (progressBlock) {
            _progressBlock = [progressBlock copy];
        }
        
        if (completeBlock) {
            _completeBlock = [completeBlock copy];
        }
        
        _state = T8RequestState_Ready;
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
    
    [[T8UploadFileRequestAgent sharedUploadFileRequestAgent] addRequest:self];
    
    self.state = T8RequestState_Loading;
    
    __weak __typeof(self) weakSelf = self;
    self.dataTask = [T8BaseNetworkService uploadFilesRequestWithFileInfos:self.fileInfos urlPath:self.path params:[self.params mutableCopy] progressBlock:self.progressBlock completBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        if (weakSelf.completeBlock) {
            weakSelf.completeBlock(status, data, error);
        }
        
        if (status == RequestStatusSuccess) {
            weakSelf.state = T8RequestState_CompletedSucceed;
        } else {
            weakSelf.state = T8RequestState_CompletedFailed;
        }
        
        if ([weakSelf.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
            [weakSelf.completeDelegate requestCompleted:weakSelf];
        }
    }];
}

- (void)cancel
{
    if (self.state == T8RequestState_CompletedFailed || self.state == T8RequestState_CompletedSucceed) {
        return;
    }
    self.state = T8RequestState_CompletedFailed;
    
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    
    __weak __typeof(self) weakSelf = self;
    if ([self.completeDelegate respondsToSelector:@selector(requestCompleted:)]) {
        [self.completeDelegate requestCompleted:weakSelf];
    }
    
    [[T8UploadFileRequestAgent sharedUploadFileRequestAgent] removeRequest:self];
}

@end
