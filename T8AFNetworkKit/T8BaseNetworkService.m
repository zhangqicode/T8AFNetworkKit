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
static RequestErrorHandleBlock T8RequestErrorHandleBlock = nil;
static RequestFailureBlock T8RequestFailureBlock = nil;

@implementation T8BaseNetworkService

+ (AFHTTPRequestOperationManager *)shareInstance
{
    static AFHTTPRequestOperationManager *shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shareInstance = [AFHTTPRequestOperationManager manager];
        shareInstance.completionQueue = dispatch_queue_create("com.tinfinite.network.completionqueue", DISPATCH_QUEUE_CONCURRENT);
        shareInstance.responseSerializer = [AFJSONResponseSerializer serializer];
        shareInstance.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
        shareInstance.requestSerializer.timeoutInterval = 10;
        shareInstance.operationQueue.maxConcurrentOperationCount = 10;
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

+ (void)setErrorHandleBlock:(RequestErrorHandleBlock)errorHandleBlock
{
    T8RequestErrorHandleBlock = errorHandleBlock;
}

+ (void)setFailureBlock:(RequestFailureBlock)failureBlock
{
    T8RequestFailureBlock = failureBlock;
}

+ (AFHTTPRequestOperation *)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock
{
    return [self sendRequestUrlPath:strUrlPath httpMethod:httpMethod dictParams:dictParams completeBlock:completeBlock cachePolicy:-1];
}

+ (AFHTTPRequestOperation *)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock cachePolicy:(NSURLRequestCachePolicy)policy
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
    request.cachePolicy = policy;
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    AFHTTPRequestOperation *operation = [op HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation __unused *operation, id responseObject)
                                         {
                                             [self handleSuccesss:operation response:responseObject block:completeBlock];
                                             
                                         } failure:^(AFHTTPRequestOperation __unused *operation, NSError *error) {
                                             [self handleFail:operation error:error block:completeBlock];
                                             
                                         }];
    
    [op.operationQueue addOperation:operation];
    
    return operation;
}

+ (AFHTTPRequestOperation *)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock useCacheWhenFail:(BOOL)cache
{
    if (cache) {
        return [self sendRequestUrlPath:strUrlPath httpMethod:httpMethod dictParams:dictParams completeBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
            if (status == RequestStatusSuccess) {
                completeBlock(status, data, error);
            }else{
                [T8BaseNetworkService sendRequestUrlPath:strUrlPath httpMethod:httpMethod dictParams:dictParams completeBlock:completeBlock cachePolicy:NSURLRequestReturnCacheDataDontLoad];
            }
        }];
    }else{
        return [self sendRequestUrlPath:strUrlPath httpMethod:httpMethod dictParams:dictParams completeBlock:completeBlock];
    }
}

+ (AFHTTPRequestOperation *)uploadFilesRequestWithFileInfos:(NSArray *)fileInfos urlPath:(NSString *)urlPath params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock
{
    AFHTTPRequestOperationManager *manager = [T8BaseNetworkService shareInstance];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[self getRequestUrl:urlPath] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i<fileInfos.count; i++) {
            NSDictionary *fileDict = fileInfos[i];
            NSString *type = [fileDict objectForKey:@"type"];
            NSString *filename = [fileDict objectForKey:@"filename"]?[fileDict objectForKey:@"filename"]:@"";
            NSString *mimetype = [fileDict objectForKey:@"mimetype"]?[fileDict objectForKey:@"mimetype"]:@"";
            if ([type isEqualToString:@"data"]) {
                NSData *data = [fileDict objectForKey:@"data"];
                if (data) {
                    [formData appendPartWithFileData:data name:filename fileName:filename mimeType:mimetype];
                }
            }else if ([type isEqualToString:@"path"]){
                NSString *path = [fileDict objectForKey:@"path"];
                if (path.length > 0) {
                    [formData appendPartWithFileURL:[NSURL URLWithString:path] name:filename fileName:filename mimeType:mimetype error:nil];
                }
            }
        }
    } error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    
    AFHTTPRequestOperation *operation = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleSuccesss:operation response:responseObject block:completBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFail:operation error:error block:completBlock];
    }];
    
    if (progressBlock) {
        [operation setUploadProgressBlock:progressBlock];
    }
    
    [manager.operationQueue addOperation:operation];
    
    return operation;
}


+ (void)sendSyncRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock
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
    
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:&error];
    if (error) {
        [self handleFail:nil error:error block:completeBlock];
    }else{
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error) {
            [self handleFail:nil error:error block:completeBlock];
        }else{
            [self handleSuccesss:nil response:dict block:completeBlock];
        }
    }
}

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename completBlock:(RequestComplete)completBlock;
{
    [self uploadImage:imageData urlPath:strUrlPath filename:filename progressBlock:nil completBlock:completBlock];
}

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock
{
    [self uploadImage:imageData urlPath:strUrlPath filename:filename params:nil progressBlock:progressBlock completBlock:completBlock];
}

+ (void)uploadImage:(NSData *)imageData urlPath:(NSString *)strUrlPath filename:(NSString *)filename params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock
{
    AFHTTPRequestOperationManager *manager = [T8BaseNetworkService shareInstance];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[self getRequestUrl:strUrlPath] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:imageData name:filename fileName:filename mimeType:@"image/jpg"];
    } error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    
    AFHTTPRequestOperation *option = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleSuccesss:operation response:responseObject block:completBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFail:operation error:error block:completBlock];
    }];
    
    [manager.operationQueue addOperation:option];
    
    if (progressBlock) {
        [option setUploadProgressBlock:progressBlock];
    }
}

+ (void)uploadImageDataArray:(NSArray *)imageDataArray urlPath:(NSString *)strUrlPath filename:(NSString *)filename params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock
{
    AFHTTPRequestOperationManager *manager = [T8BaseNetworkService shareInstance];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[self getRequestUrl:strUrlPath] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i<imageDataArray.count; i++) {
            NSData *uploadImageData = imageDataArray[i];
            NSString *name = [NSString stringWithFormat:@"%@%d",filename,i];
            [formData appendPartWithFileData:uploadImageData name:name fileName:name mimeType:@"image/jpg"];
        }
    } error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    
    AFHTTPRequestOperation *option = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleSuccesss:operation response:responseObject block:completBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFail:operation error:error block:completBlock];
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
        [self handleSuccesss:operation response:responseObject block:completeBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFail:operation error:error block:completeBlock];
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

/**
 *  上传一个数组的文件
 *
 *  @param files         每个元素是一个字典，包括type（"data","path"两种方式），data（如果type是data，类型是NSData），path（如果type是path，类型是string），filename，mimetype（图片是"image/jpg"，视频是"video/mpeg"）
 *  @param strUrlPath
 *  @param params
 *  @param progressBlock
 *  @param completBlock
 */
+ (void)uploadFiles:(NSArray *)files urlPath:(NSString *)strUrlPath params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completBlock:(RequestComplete)completBlock
{
    AFHTTPRequestOperationManager *manager = [T8BaseNetworkService shareInstance];
    
    NSMutableURLRequest *request = [manager.requestSerializer multipartFormRequestWithMethod:@"POST" URLString:[self getRequestUrl:strUrlPath] parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        for (int i = 0; i<files.count; i++) {
            NSDictionary *fileDict = files[i];
            NSString *type = [fileDict objectForKey:@"type"];
            NSString *filename = [fileDict objectForKey:@"filename"]?[fileDict objectForKey:@"filename"]:@"";
            NSString *mimetype = [fileDict objectForKey:@"mimetype"]?[fileDict objectForKey:@"mimetype"]:@"";
            if ([type isEqualToString:@"data"]) {
                NSData *data = [fileDict objectForKey:@"data"];
                if (data) {
                    [formData appendPartWithFileData:data name:filename fileName:filename mimeType:mimetype];
                }
            }else if ([type isEqualToString:@"path"]){
                NSString *path = [fileDict objectForKey:@"path"];
                if (path.length > 0) {
                    [formData appendPartWithFileURL:[NSURL URLWithString:path] name:filename fileName:filename mimeType:mimetype error:nil];
                }
            }
        }
    } error:nil];
    if (T8RequestHandleBlock) {
        T8RequestHandleBlock(request);
    }
    
    AFHTTPRequestOperation *option = [manager HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self handleSuccesss:operation response:responseObject block:completBlock];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self handleFail:operation error:error block:completBlock];
    }];
    
    [manager.operationQueue addOperation:option];
    
    if (progressBlock) {
        [option setUploadProgressBlock:progressBlock];
    }
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

+ (void)handleSuccesss:(AFHTTPRequestOperation *)operation response:(id)responseObject block:(RequestComplete)completeBlock
{
#ifndef __OPTIMIZE__
    NSLog(@"\n请求接口：%@\n请求的结果：%@\n", operation.request.URL.absoluteString, responseObject);
#endif
    NSDictionary *json = responseObject;
    
    if (json && [json isKindOfClass:[NSDictionary class]] && (json.count > 0))
    {
        // 看是否出错
        if ([[json allKeys] containsObject:@"code"] && [json[@"code"] intValue] != 1)
        {
            // 出错啦，取错误信息
            NSString *errorMsg = json[@"message"];
            T8NetworkError *e = [T8NetworkError errorWithCode:[json[@"code"] integerValue] errorMessage:errorMsg];
            completeBlock(RequestStatusFailure, json, e);
            if (T8RequestErrorHandleBlock) {
                T8RequestErrorHandleBlock(json);
            }
#ifndef __OPTIMIZE__
            NSLog(@"\n请求接口：%@\n错误信息：%@", operation.request.URL.absoluteString, errorMsg);
#endif
        }else{
            // 接口调用成功
            completeBlock(RequestStatusSuccess, json, nil);
        }
    }else{
        // 接口数据为空
#ifndef __OPTIMIZE__
        NSLog(@"\n请求接口：%@\n接口数据异常", operation.request.URL.absoluteString);
#endif
        T8NetworkError *e = [T8NetworkError errorWithCode:-1 errorMessage:@"数据异常"];
        completeBlock(RequestStatusFailure, @{}, e);
    }
}

+ (void)handleFail:(AFHTTPRequestOperation *)operation error:(NSError *)error block:(RequestComplete)completeBlock
{
#ifndef __OPTIMIZE__
    NSLog(@"\n网络错误，请求的错误提示：%@\n", error);
#endif
    if (completeBlock != nil) {
        T8NetworkError *e = [T8NetworkError errorWithNSError:error];
        completeBlock(RequestStatusFailure, nil, e);
    }
    
    if (T8RequestFailureBlock) {
        T8RequestFailureBlock([operation.request.URL.absoluteString stringByReplacingOccurrencesOfString:T8BaseNetworkUrl withString:@""], error);
    }
}

@end
