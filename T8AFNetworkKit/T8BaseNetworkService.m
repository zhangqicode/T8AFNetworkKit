//
//  BaseNetworkService.m
//  yiyonghai
//
//  Created by 琦张 on 15/5/11.
//  Copyright (c) 2015年 YYH. All rights reserved.
//

#import "T8BaseNetworkService.h"

static NSString *T8BaseNetworkUrl = nil;
static RequestHandleBlock T8RequestHandleBlock = nil;

@implementation T8BaseNetworkService

+ (AFHTTPRequestOperationManager *)shareInstance
{
    static AFHTTPRequestOperationManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [AFHTTPRequestOperationManager manager];
        shareInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        shareInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];

    });
    
    return shareInstance;
}

+ (void)setBaseUrl:(NSString *)baseUrl
{
    T8BaseNetworkUrl = baseUrl;
}

+ (void)setHandleBlock:(RequestHandleBlock)handleBlock
{
    T8RequestHandleBlock = handleBlock;
}

+ (void)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock
{
    NSString *method;
    switch (httpMethod) {
        case HttpMethodGet:
            method = @"GET";
            break;
        case HttpMethodPost:
            method = @"POST";
            break;
        case HttpMethodPut:
            method = @"PUT";
            break;
        case HttpMethodDelete:
            method = @"DELETE";
            break;
        case HttpMethodPatch:
            method = @"PATCH";
            break;
        case HttpMethodHead:
            method = @"HEAD";
            break;
        default:
            break;
    }
    
    AFHTTPRequestOperationManager *op = [self shareInstance];
    NSMutableURLRequest *request = [op.requestSerializer requestWithMethod:method URLString:[self getRequestUrl:strUrlPath] parameters:dictParams error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    AFHTTPRequestOperation *operation = [op HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation __unused *operation, id responseObject)
                                         {
                                             NSDictionary *resJson = responseObject;
                                             
                                             NSLog(@"\n请求接口：%@\n请求的结果：%@\n", strUrlPath, resJson);
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 NSDictionary *json = nil;
                                                 
                                                 if (resJson) {
                                                     if ([resJson isKindOfClass:[NSArray class]]) {
                                                         // 兼容NSArray的情况
                                                         json = @{@"array":resJson};
                                                     } else {
                                                         json = [NSDictionary dictionaryWithDictionary:resJson];
                                                     }
                                                 }
                                                 
                                                 if (json && [json isKindOfClass:[NSDictionary class]] && (json.count > 0))
                                                 {
                                                     // 看是否出错
                                                     if ([[json allKeys] containsObject:@"code"] && [json[@"code"] intValue] != 1)
                                                     {
                                                         // 出错啦，取错误信息
                                                         NSString *errorMsg = json[@"message"];
                                                         T8NetworkError *e = [T8NetworkError errorWithCode:[json[@"code"] integerValue] errorMessage:errorMsg];
                                                         completeBlock(RequestStatusFailure, json, e);
                                                         NSLog(@"\n请求接口：%@\n错误信息：%@", strUrlPath, errorMsg);
                                                     }else{
                                                         // 接口调用成功
                                                         completeBlock(RequestStatusSuccess, json, nil);
                                                     }
                                                 }else{
                                                     // 接口数据为空
                                                     NSLog(@"\n请求接口：%@\n接口数据异常", strUrlPath);
                                                     T8NetworkError *e = [T8NetworkError errorWithCode:-1 errorMessage:@"数据异常"];
                                                     completeBlock(RequestStatusFailure, @{}, e);
                                                 }
                                             });
                                             
                                         } failure:^(AFHTTPRequestOperation __unused *operation, NSError *error) {
                                             NSLog(@"\n网络错误，请求的错误提示：%@\n", error);
                                             dispatch_async(dispatch_get_main_queue(), ^{
                                                 if (completeBlock != nil) {
                                                     T8NetworkError *e = [T8NetworkError errorWithNSError:error];
                                                     completeBlock(RequestStatusFailure, nil, e);
                                                 }
                                             });
                                         }];
    
    [op.operationQueue addOperation:operation];
}

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename completBlock:(RequestComplete)completBlock;
{
    [self uploadImage:imageData urlPath:strUrlPath filename:filename progressBlock:nil completBlock:completBlock];
}

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock
{
    AFHTTPRequestOperationManager *manager = [T8BaseNetworkService shareInstance];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[self getRequestUrl:strUrlPath] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:filename fileName:filename mimeType:@"image/jpg"];
    } error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    
    AFHTTPRequestOperation *option = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completBlock(RequestStatusSuccess, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        T8NetworkError *e = [T8NetworkError errorWithNSError:error];
        completBlock(RequestStatusFailure, nil, e);
    }];
    
    [manager.operationQueue addOperation:option];
   
    if (progressBlock) {
        [option setUploadProgressBlock:progressBlock];
    }
}

+ (void)uploadVideo:(NSURL *)videoUrl urlPath:(NSString *)strUrlPath filename:(NSString *)filename params:(NSMutableDictionary *)mutDict completeBlock:(RequestComplete)completeBlock
{
    [self uploadVideo:videoUrl urlPath:strUrlPath filename:filename progressBlock:nil params:mutDict completeBlock:completeBlock];
}

+ (void)uploadVideo:(NSURL *)videoUrl urlPath:(NSString *)strUrlPath filename:(NSString *)filename progressBlock:(RequestProgressBlock)progressBlock params:(NSMutableDictionary *)mutDict completeBlock:(RequestComplete)completeBlock
{
    AFHTTPRequestOperationManager *manager = [T8BaseNetworkService shareInstance];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[self getRequestUrl:strUrlPath] parameters:mutDict constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:videoUrl name:filename error:nil];
    } error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    
    AFHTTPRequestOperation *option = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        completeBlock(RequestStatusSuccess, responseObject, nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        T8NetworkError *e = [T8NetworkError errorWithNSError:error];
        completeBlock(RequestStatusFailure, nil, e);
    }];
    
    [manager.operationQueue addOperation:option];
    
    if (progressBlock) {
        [option setUploadProgressBlock:progressBlock];
    }
}

+ (void)uploadVideoWithParams:(NSMutableDictionary *)params mediaUrl:(NSURL *)mediaUrl path:(NSString *)path uploadCompletion:(void (^)(NSURLResponse *, id, NSError *))completionBlock progressBlock:(void (^)(NSURLSessionUploadTask *))progressBlock
{
    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:@"POST" URLString:[self getRequestUrl:path] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileURL:mediaUrl name:@"filefield" error:nil];
    } error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    
    NSString* tmpFilename = [NSString stringWithFormat:@"%f", NSDate.timeIntervalSinceReferenceDate];
    NSURL* tmpFileUrl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:tmpFilename]];
    
    [AFHTTPRequestSerializer.serializer requestWithMultipartFormRequest:request writingStreamContentsToFile:tmpFileUrl completionHandler:^(NSError *error) {
        // Once the multipart form is serialized into a temporary file, we can initialize
        // the actual HTTP request using session manager.
        // Create default session manager.
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:NSURLSessionConfiguration.defaultSessionConfiguration];
        manager.responseSerializer = [AFHTTPResponseSerializer serializer]; //很重要，去掉会出现Content-Type错误
        // Here note that we are submitting the initial multipart request. We are, however,
        // forcing the body stream to be read from the temporary file.
        NSURLSessionUploadTask *uploadTask = [manager uploadTaskWithRequest:request fromFile:tmpFileUrl progress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            // Cleanup: remove temporary file.
            [NSFileManager.defaultManager removeItemAtURL:tmpFileUrl error:nil];
            completionBlock(response, responseObject, error);
        }];
        
        progressBlock(uploadTask);
    }];
}

+ (NSString *)getRequestUrl:(NSString *)path
{
    if ([path hasPrefix:@"http"]) {
        return path;
    }

    if (T8BaseNetworkUrl.length>0) {
        return [NSString stringWithFormat:@"%@/%@", T8BaseNetworkUrl, path];
    }else{
        return path;
    }
}

@end
