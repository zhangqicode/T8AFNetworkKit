//
//  T8Request.h
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import <Foundation/Foundation.h>

/**
 *  网络请求的状态
 */
typedef NS_ENUM(NSInteger, T8RequestState) {
    /**
     *  未知
     */
    T8RequestState_Unkown = -1,
    /**
     *  已做好请求的准备
     */
    T8RequestState_Ready = 0,
    /**
     *  加载中
     */
    T8RequestState_Loading = 1,
    /**
     *  加载完成，且请求成功
     */
    T8RequestState_CompletedSucceed = 2,
    /**
     *  加载完成，且请求失败
     */
    T8RequestState_CompletedFailed = 3,
};


@protocol T8Request;

/**
 *  网络请求完成的协议。
 *  通过该协议实现T8BaseRequest、T8BatchRequest和T8ChainRequest之间传递“网络请求完成”事件。
 */
@protocol T8RequestCompleteDelegate <NSObject>

@required
/**
 *  请求完成
 *
 *  @param request 加载完成的请求
 */
- (void)requestCompleted:(id<T8Request>)request;

@end


/**
 *  对网络请求的基本属性和方法的抽象。
 *  T8BaseRequest、T8BatchRequest和T8ChainRequest类都遵循该协议。
 */
@protocol T8Request <NSObject>

@optional
//  请求完成后可通过该属性调用被委托方的requestCompleted:方法。
@property (nonatomic, assign) id<T8RequestCompleteDelegate> completeDelegate;

@required
//  启动请求
- (void)start;
//  取消请求
- (void)cancel;

//  请求状态
@property (nonatomic, assign, readonly) T8RequestState state;

@end
