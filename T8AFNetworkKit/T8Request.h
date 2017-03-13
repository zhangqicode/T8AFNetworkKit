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
    /**
     *  被取消
     */
    T8RequestState_Canceled = 4
};


//  默认的最大重发次数
#ifndef T8Request_DefaultMaxRetryCount
#define T8Request_DefaultMaxRetryCount 3
#endif

//  默认的重发间隔
#ifndef T8Request_DefaultRetryInterval
#define T8Request_DefaultRetryInterval 3
#endif


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
@property (nonatomic, weak) id<T8RequestCompleteDelegate> completeDelegate;


/**
 消息重发机制。通过配置控制请求重发的行为。
 
 重发机制的流程：
 在网络请求返回错误之后，
 1. 首先检测retryEnable查看是否允许重发请求。若不支持重发则按照既定的规则处理（回调block等），若支持重发则进入重发流程。
 2. 进入重发流程后首先判断当前的请求是否满足重发的条件：
    - retryEnable = YES
    - retryCount < maxRetryCount
    - 通过error.code判断该请求是否可以重发，例如：若请求的HOST无法找到或者请求的URL是不符合规范的，就不应该重发。其次，也可以通过fatalStatusCodes变量自定义不可以重发的code，提高了重发判断能力的灵活性。
 3. 满足重发条件后，首先要计算重发的时间间隔：
    - retryProgressive = YES：重发的时间间隔是累进的，即下一次重发的时间间隔比上一次高一个量级。我们使用“指数”的方式计算时间间隔（例如：若retryCount为3，retryInterval为3，则每次重发的时间间隔为：3s, 9s, 27s），具体为pow(retryInterval, ++retryCount)，通过这种方式可以将请求成功率高的在短时间内请求完毕，成功率低的则后延更长的时间执行，有效降低请求的并发数量，降低服务器的压力。***注意，若某个请求需要用户等待，不建议使用重发机制，应该让用户手动重发。***
    - retryProgressive = NO：重发的时间间隔不是累进的，即每次重发的时间间隔是固定的，都是retryInterval。采用这种方式需要跟具体的业务相结合，不建议大量进行这种重发。
 4. 计算好重发的时间间隔后，通过dispatch_after(dispatch_time, retryDispatchQueue, retry_block);的方式进行重发操作。这里的retryDispatchQueue默认为主线程，可以满足大多数的情况；也可以自定义retryDispatchQueue。
 
 关于重发的取消：
 - 若消息是主动取消的，则不会重发。
 - 若在重发过程中进行了取消操作，则取消重发操作。
 - 已经被主动取消的操作，只有主动开始之后（先调start），才可以再重发。
 - 以上3条适用于所有类型的http请求。
 
 关于重发的几点建议：
 - 核心建议：用户体验优先。
 - 由用户主动发起的请求，不建议开启重发功能。应及时给用户反馈，让用户自行决定是否再次发送请求。
 - 重发机制应该用到对UI影响比较小，但是对数据的完整性要求比较高的地方。
 
 关于批量请求（T8BatchRequest或T8ChainRequest）中重发机制的实现：
 - 在批量请求中，重发功能是针对批量请求中的某一个具体的请求的，不是对批量请求本身的重发。例如：在一个T8BatchRequest请求（A）中，若某一个请求（A-1）响应失败了，且满足了重发条件，则重发请求（A-1），而不是重发请求（A）。这样的重发机制对批量请求的规则是无影响的，不会对当前已有的调用请求的代码产生影响。
 - 为了保证批量请求的时间不会过长，默认在批量请求中重发的时间间隔是不累进的（retryProgressive = 0），并且也不建议重发间隔设置的过大，否则会影响用户的体验。
 **/
@property (nonatomic, assign) BOOL retryEnable;             //  是否允许重发，默认为YES。
@property (nonatomic, assign) NSUInteger maxRetryCount;     //  最大重发次数，默认为T8Request_DefaultMaxRetryCount。
@property (nonatomic, assign) NSUInteger retryCount;        //  已重发次数，默认为0。
@property (nonatomic, assign) NSTimeInterval retryInterval; //  重发间隔(s)，默认为T8Request_DefaultRetryInterval。若为0，则在允许重发的情况下直接开始重发。
@property (nonatomic, assign) BOOL retryProgressive;        //  重发时间间隔是否是累进的，默认为YES。若是累进的，时间间隔为retryInterval的指数为(已发送次数+1)的幂的值，否则时间间隔为retryInterval。
@property (nonatomic, copy) NSArray<NSNumber *> *fatalStatusCodes;  //  自定义的灾难性的网络响应错误code。若HTTP Response返回的错误code包含在fatalStatusCodes之中就不会启动重发机制。
@property (nonatomic, weak) dispatch_queue_t retryDispatchQueue;  //  在哪个dispatch启动重发，默认为main_queue。


@required
//  启动请求
- (void)start;
//  取消请求
- (void)cancel;

//  请求状态
@property (nonatomic, assign, readonly) T8RequestState state;

@end
