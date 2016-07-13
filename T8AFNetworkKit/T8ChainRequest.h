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


typedef void(^ChainRequestCompleteBlock)(NSUInteger completeCount);


@interface T8ChainRequest : NSObject <T8Request, T8RequestCompleteDelegate>

/**
 *  初始化方法
 *
 *  @param requests       请求队列
 *  @param completeBlock  请求队列执行完成后的回调Block
 *  @param shouldComplete 当前队列中的请求执行完毕后是否可以完成该ChainRequest。若shouldComplete为YES，则不能再添加请求到当前队列中。
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

@end
