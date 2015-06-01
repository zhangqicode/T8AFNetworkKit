//
//  BaseNetworkService.m
//  yiyonghai
//
//  Created by 琦张 on 15/5/11.
//  Copyright (c) 2015年 YYH. All rights reserved.
//

#import "T8BaseNetworkService.h"

static NSString *T8BaseNetworkUrl = nil;

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
                                                     if ([[json allKeys] containsObject:@"code"] && [json[@"code"] intValue] != 0)
                                                     {
                                                         // 出错啦，取错误信息
                                                         NSString *errorMsg = json[@"msg"];
                                                         T8NetworkError *e = [T8NetworkError errorWithCode:[json[@"code"] integerValue] errorMessage:errorMsg];
                                                         completeBlock(RequestStatusFailure, nil, e);
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
