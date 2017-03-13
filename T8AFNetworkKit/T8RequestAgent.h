//
//  T8RequestAgent.h
//  Pods
//
//  Created by JustBen on 06/03/2017.
//
//

#import <Foundation/Foundation.h>
#import "T8Request.h"

@interface T8RequestAgent : NSObject

//  添加请求
- (void)addRequest:(id<T8Request>)request;
//  移除请求
- (void)removeRequest:(id<T8Request>)request;
//  清空所有请求
- (void)removeAllRequests;
//  取消所有请求
- (void)cancelAllRequests;

@end
