//
//  T8BatchRequest.h
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import <Foundation/Foundation.h>
#import "T8BaseRequest.h"
#import "T8Request.h"


/**
 *  批量网络请求完成的条件
 */
typedef NS_ENUM(NSInteger, BatchRequestCompleteCondiction) {
    //  一旦某个请求失败了，那么整个请求队列随之失败
    BatchRequestCompleteCondiction_AnyFailed = 0,
    // 所有请求必须都请求一遍
    BatchRequestCompleteCondiction_AllRequested = 1,
};


typedef void(^BatchRequestCompleteBlock)(NSUInteger completeCount, NSUInteger succeedCount, NSUInteger failedCount);


@interface T8BatchRequest : NSObject <T8Request, T8RequestCompleteDelegate>

/**
 *  初始化方法
 *
 *  @param requests                     请求队列
 *  @param completeCondition    请求队列完成的条件
 *  @param completeBlock            请求队列请求完成的回调Block
 *
 *  @return T8BatchRequest对象
 */
- (id)initWithRequests:(NSArray *)requests completeCondition:(BatchRequestCompleteCondiction)completeCondition completeBlock:(BatchRequestCompleteBlock)completeBlock;

/**
 *  初始化方法，请求队列完成条件为BatchRequestCompleteCondiction_AllRequested
 *
 *  @param requests                     请求队列
 *  @param completeBlock            请求队列请求完成的回调Block
 *
 *  @return T8BatchRequest对象
 */
- (id)initWithRequests:(NSArray *)requests completeBlock:(BatchRequestCompleteBlock)completeBlock;

//  每次请求之间的间隔(s)，默认0.05s
@property (nonatomic, assign) NSTimeInterval requestInterval;

//  完成请求的数量
@property (nonatomic, assign, readonly) NSUInteger completeCount;
//  请求成功的数量
@property (nonatomic, assign, readonly) NSUInteger succeedCount;
//  请求失败的数量
@property (nonatomic, assign, readonly) NSUInteger failedCount;

@end
