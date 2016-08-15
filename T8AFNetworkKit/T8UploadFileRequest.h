//
//  T8UploadFileRequest.h
//  T8AFNetworkKitDemo
//
//  Created by JustBen on 8/15/16.
//  Copyright © 2016 琦张. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "T8BaseNetworkService.h"
#import "T8Request.h"


@interface T8UploadFileRequest : NSObject <T8Request>

- (id)initWithFileInfos:(NSArray *)fileInfos path:(NSString *)path params:(NSMutableDictionary *)params progressBlock:(RequestProgressBlock)progressBlock completeBlock:(RequestComplete)completeBlock;


//  需要上传的文件信息
@property (nonatomic, copy, readonly) NSArray *fileInfos;
//  请求路径
@property (nonatomic, copy, readonly) NSString *path;
//  请求参数，默认为nil
@property (nonatomic, strong, readonly) NSDictionary *params;
//  上传进度Blocks
@property (nonatomic, copy, readonly) RequestProgressBlock progressBlock;
//  请求完成的回调block，默认为nil
@property (nonatomic, copy, readonly) RequestComplete completeBlock;

@end
