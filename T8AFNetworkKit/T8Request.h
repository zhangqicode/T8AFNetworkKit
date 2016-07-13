//
//  T8Request.h
//  Pods
//
//  Created by JustBen on 7/12/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, T8RequestState) {
    T8RequestState_Unkown = -1,   //  未知
    T8RequestState_Ready = 0,     //  已准备好请求
    T8RequestState_Loading = 1,   //  加载中
    T8RequestState_CompletedSucceed = 2, //  加载完成，且请求成功
    T8RequestState_CompletedFailed = 3, //  加载完成，且请求失败
};


@protocol T8Request;
@protocol T8RequestCompleteDelegate <NSObject>

@required
//  请求完成
- (void)requestCompleted:(id<T8Request>)request;
@end


@protocol T8Request <NSObject>

@optional
@property (nonatomic, assign) id<T8RequestCompleteDelegate> completeDelegate;

@required
//  启动请求
- (void)start;
//  取消请求
- (void)cancel;
//  请求状态
@property (nonatomic, assign, readonly) T8RequestState state;
@end
