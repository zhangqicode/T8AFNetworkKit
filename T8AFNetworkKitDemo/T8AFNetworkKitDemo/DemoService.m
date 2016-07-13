//
//  DemoService.m
//  T8AFNetworkKitDemo
//
//  Created by 琦张 on 15/5/30.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import "DemoService.h"

@implementation DemoService

+ (void)testRequestWithUserid:(NSString *)userid device:(NSString *)device block:(RequestComplete)requestComplete
{
    NSString *urlPath = @"passport/accesstoken/get";
    
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setObject:userid forKey:@"user_id"];
    [mutDict setObject:device forKey:@"device"];
    
    [T8BaseNetworkService sendRequestUrlPath:urlPath httpMethod:HttpMethodGet dictParams:mutDict completeBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        if (requestComplete) {
            requestComplete(status, data, error);
        }
    }];
}

+ (T8BaseRequest *)getTestRequestWithUserid:(NSString *)userid device:(NSString *)device block:(RequestComplete)requestComplete
{
    NSString *urlPath = @"passport/accesstoken/get";
    
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    [mutDict setObject:userid forKey:@"user_id"];
    [mutDict setObject:device forKey:@"device"];
    
    return [[T8BaseRequest alloc] initWithPath:urlPath httpMethod:HttpMethodGet params:mutDict completeBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        if (requestComplete) {
            requestComplete(status, data, error);
        }
    }];
}

@end
