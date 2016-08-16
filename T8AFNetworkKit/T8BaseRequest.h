//
//  T8BaseRequest.h
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import <Foundation/Foundation.h>
#import "T8BaseNetworkService.h"
#import "T8Request.h"


@interface T8BaseRequest : NSObject <T8Request>

/**
 *  初始化方法
 *
 *  @param path          请求路径
 *  @param httpMethod    请求方法
 *  @param params        请求参数
 *  @param completeBlock 请求完成后的回调Block
 *  @param useCacheWhenFailed 网络请求失败后是否使用本地缓存
 *
 *  @return T8BaseRequest对象
 */
- (id)initWithPath:(NSString *)path httpMethod:(HttpMethod)httpMethod params:(NSDictionary *)params completeBlock:(RequestComplete)completeBlock useCacheWhenFailed:(BOOL)useCacheWhenFailed;
- (id)initWithPath:(NSString *)path httpMethod:(HttpMethod)httpMethod params:(NSDictionary *)params completeBlock:(RequestComplete)completeBlock;


//  请求路径
@property (nonatomic, strong) NSString *path;
//  http请求方法，默认为HttpMethodGet
@property (nonatomic, assign) HttpMethod httpMethod;
//  请求参数，默认为nil
@property (nonatomic, strong) NSDictionary *params;

//  请求失败后是否适用cache，默认为NO
@property (nonatomic, assign) BOOL useCacheWhenFailed;

//  请求完成的回调block，默认为nil
@property (nonatomic, copy) RequestComplete completeBlock;

@end
