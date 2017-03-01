//
//  extError.h
//  Telegraph
//
//  Created by yewei on 15/2/14.
//
//

#import <Foundation/Foundation.h>

@interface T8NetworkError : NSError

/**
 * 返回由NSError构建的错误对象.
 */
+ (T8NetworkError*)errorWithNSError:(NSError*)error;

/**
 * 构造错误对象。
 *
 * @param code 错误代码
 * @param errorMessage 错误信息
 *
 * 返回错误对象.
 */
+ (T8NetworkError*)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage;

/**
 * 返回用于展现给用户的错误提示标题
 */
- (NSString*)titleForError;


/**
 * 根据网络请求返回的响应错误code，判断网络请求是否存在致命的错误（fatal error）
 */
+ (BOOL)isFatalErrorWithErrorCode:(NSInteger)errorCode;

@end
