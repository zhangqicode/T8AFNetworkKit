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

@interface T8BaseNetworkService : NSObject

+ (AFHTTPRequestOperationManager *)shareInstance;

+ (void)setBaseUrl:(NSString *)baseUrl;

+ (void)sendRequestUrlPath:(NSString *)strUrlPath httpMethod:(HttpMethod)httpMethod dictParams:(NSMutableDictionary *)dictParams completeBlock:(RequestComplete)completeBlock;

@end
