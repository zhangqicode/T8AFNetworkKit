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
    /**
     *  一旦某个请求失败了，那么整个批量请求也失败了
     */
    BatchRequestCompleteCondiction_AnyFailed = 0,
    /**
     *  所有请求必须都执行一遍
     */
    BatchRequestCompleteCondiction_AllCompleted = 1,
};


typedef void(^BatchRequestCompleteBlock)(NSUInteger completeCount, NSUInteger succeedCount, NSUInteger failedCount);


@interface T8BatchRequest : NSObject <T8Request, T8RequestCompleteDelegate>

/**
 *  初始化方法
 *
 *  @param requests          请求队列
 *  @param completeCondition 该BatchRequest完成的条件
 *  @param completeBlock     该BatchRequest请求完成的回调Block
 *
 *  @return T8BatchRequest对象
 */
- (id)initWithRequests:(NSArray *)requests completeCondition:(BatchRequestCompleteCondiction)completeCondition completeBlock:(BatchRequestCompleteBlock)completeBlock;

//  完成请求的数量
@property (nonatomic, assign, readonly) NSUInteger completeCount;
//  请求成功的数量
@property (nonatomic, assign, readonly) NSUInteger succeedCount;
//  请求失败的数量
@property (nonatomic, assign, readonly) NSUInteger failedCount;

@end
