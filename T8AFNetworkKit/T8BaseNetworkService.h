//
//  BaseNetworkService.h
//  yiyonghai
//
//  Created by 琦张 on 15/5/11.
//  Copyright (c) 2015年 YYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
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
typedef void(^RequestErrorHandleBlock)(NSDictionary *data);

@interface T8BaseNetworkService : NSObject

+ (void)setBaseUrl:(NSString *)baseUrl;

+ (void)setHandleBlock:(RequestHandleBlock)handleBlock;

+ (void)setErrorHandleBlock:(RequestErrorHandleBlock)errorHandleBlock;

+ (AFHTTPRequestOperation *)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock;

+ (AFHTTPRequestOperation *)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock useCacheWhenFail:(BOOL)cache;

+ (void)sendSyncRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock;

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename completBlock:(RequestComplete)completBlock;

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock;

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock;

+ (void)uploadImageDataArray:(NSArray *)imageDataArray urlPath:(NSString *)strUrlPath filename:(NSString *)filename params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock;

+ (void)uploadVideo:(NSURL *)videoUrl urlPath:(NSString *)strUrlPath filename:(NSString *)filename params:(NSMutableDictionary *)mutDict completeBlock:(RequestComplete)completeBlock;

+ (void)uploadVideo:(NSURL *)videoUrl urlPath:(NSString *)strUrlPath filename:(NSString *)filename progressBlock:(RequestProgressBlock)progressBlock params:(NSMutableDictionary *)mutDict completeBlock:(RequestComplete)completeBlock;

+ (void)uploadVideoWithParams:(NSMutableDictionary *)params mediaUrl:(NSURL *)mediaUrl path:(NSString *)path uploadCompletion:(void (^)(NSURLResponse *, id, NSError *))completionBlock progressBlock:(void (^)(NSURLSessionUploadTask *))progressBlock;

/**
 *  上传一个数组的文件
 *
 *  @param files         每个元素是一个字典，包括type（"data","path"两种方式），data（如果type是data，类型是NSData），path（如果type是path，类型是string），filename，mimetype（图片是"image/jpg"，视频是"video/mpeg"）
 *  @param strUrlPath
 *  @param params
 *  @param progressBlock
 *  @param completBlock
 */
+ (void)uploadFiles:(NSArray *)files urlPath:(NSString *)strUrlPath params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock;

+ (NSString *)getRequestUrl:(NSString *)path;

@end
