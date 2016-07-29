//
//  T8ChainRequest.h
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import <Foundation/Foundation.h>
#import "T8BaseRequest.h"
#import "T8BatchRequest.h"
#import "T8Request.h"


typedef void(^ChainRequestCompleteBlock)(NSUInteger completeCount, NSUInteger succeedCount, NSUInteger failedCount);


/**
 *  链式网络请求完成的条件
 */
typedef NS_ENUM(NSInteger, ChainRequestCompleteCondiction) {
    //  一旦某个请求失败了，那么整个请求队列随之失败
    ChainRequestCompleteCondiction_AnyFailed = 0,
    // 所有请求必须都请求一遍
    ChainRequestCompleteCondiction_AllRequested = 1,
};


@interface T8ChainRequest : NSObject <T8Request, T8RequestCompleteDelegate>

/**
 *  初始化方法
 *
 *  @param requests       请求队列
 *  @param completeBlock  请求队列执行完成后的回调Block
 *  @param completeCondition 请求队列完成的条件
 *  @param shouldComplete 当前队列中的请求执行完毕后是否可以完成该ChainRequest。若shouldComplete为YES，则不能再添加请求到当前队列中。
 *
 *  @return T8ChainRequest对象
 */
- (id)initWithRequests:(NSArray *)requests completeCondition:(ChainRequestCompleteCondiction)completeCondition completeBlock:(ChainRequestCompleteBlock)completeBlock shouldComplete:(BOOL)shouldComplete;

/**
 *  初始化方法，请求队列完成的条件为ChainRequestCompleteCondiction_AnyFailed
 *
 *  @param requests       请求队列
 *  @param completeBlock  请求队列执行完成后的回调Block
 *  @param shouldComplete 当前队列中的请求都执行完毕后是否可以complete该队列。若shouldComplete为YES，则不能再添加请求到当前队列中。
 *
 *  @return T8ChainRequest对象
 */
- (id)initWithRequests:(NSArray *)requests completeBlock:(ChainRequestCompleteBlock)completeBlock shouldComplete:(BOOL)shouldComplete;


/**
 *  向当前请求队列中添加请求
 *
 *  @param request        请求
 *  @param shouldComplete 当前队列中的请求执行完毕后是否可以完成该ChainRequest。若shouldComplete为YES，则不能再添加请求到当前队列中。
 */
- (void)addRequest:(id<T8Request>)request shouldComplete:(BOOL)shouldComplete;


//  当前队列中的请求执行完毕后是否可以完成该ChainRequest。若shouldComplete为YES，则不能再添加请求到当前队列中。
@property (nonatomic, assign) BOOL shouldComplete;

//  完成请求的数量
@property (nonatomic, assign, readonly) NSUInteger completeCount;
//  请求成功的数量
@property (nonatomic, assign, readonly) NSUInteger succeedCount;
//  请求失败的数量
@property (nonatomic, assign, readonly) NSUInteger failedCount;

@end
