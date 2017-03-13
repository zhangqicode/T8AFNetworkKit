//
//  T8UploadFileRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8UploadFileRequestAgent.h"


@implementation T8UploadFileRequestAgent

+ (T8UploadFileRequestAgent *)sharedUploadFileRequestAgent
{
    static T8UploadFileRequestAgent *sharedUploadFileRequestAgent;
    static dispatch_once_t onceTokenForSharedUploadFileRequestAgent;
    dispatch_once(&onceTokenForSharedUploadFileRequestAgent, ^{
        sharedUploadFileRequestAgent = [[T8UploadFileRequestAgent alloc] init];
    });
    
    return sharedUploadFileRequestAgent;
}

@end
