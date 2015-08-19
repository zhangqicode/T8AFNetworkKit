//
//  BaseNetworkService.h
//  yiyonghai
//
//  Created by 琦张 on 15/5/11.
//  Copyright (c) 2015年 YYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "T8NetworkError.h"

typedef NS_ENUM(NSInteger, RequestStatus)
{
    RequestStatusSuccess,
    RequestStatusFailure
};

typedef NS_ENUM(NSInteger, HttpMethod) {
    HttpMethodGet,
    HttpMethodPost,
    HttpMethodPut,
    HttpMethodDelete,
    HttpMethodPatch,
    HttpMethodHead
};

typedef void(^RequestComplete)(RequestStatus status, NSDictionary *data, T8NetworkError *error);
typedef void(^RequestHandleBlock)(NSMutableURLRequest *request);
typedef void(^RequestProgressBlock)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite);

@interface T8BaseNetworkService : NSObject

+ (void)setBaseUrl:(NSString *)baseUrl;

+ (void)setHandleBlock:(RequestHandleBlock)handleBlock;

+ (void)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock;

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename completBlock:(RequestComplete)completBlock;

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock;

+ (void)uploadVideo:(NSURL *)videoUrl urlPath:(NSString *)strUrlPath filename:(NSString *)filename params:(NSMutableDictionary *)mutDict completeBlock:(RequestComplete)completeBlock;

+ (void)uploadVideo:(NSURL *)videoUrl urlPath:(NSString *)strUrlPath filename:(NSString *)filename progressBlock:(RequestProgressBlock)progressBlock params:(NSMutableDictionary *)mutDict completeBlock:(RequestComplete)completeBlock;

+ (void)uploadVideoWithParams:(NSMutableDictionary *)params mediaUrl:(NSURL *)mediaUrl path:(NSString *)path uploadCompletion:(void (^)(NSURLResponse *, id, NSError *))completionBlock progressBlock:(void (^)(NSURLSessionUploadTask *))progressBlock;

+ (NSString *)getRequestUrl:(NSString *)path;

@end
