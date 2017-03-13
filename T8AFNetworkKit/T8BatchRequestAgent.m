//
//  T8BatchRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8BatchRequestAgent.h"

@implementation T8BatchRequestAgent

+ (T8BatchRequestAgent *)sharedBatchRequestAgent
{
    static T8BatchRequestAgent *sharedBatchRequestAgent;
    static dispatch_once_t onceTokenForSharedBatchRequestAgent;
    dispatch_once(&onceTokenForSharedBatchRequestAgent, ^{
        sharedBatchRequestAgent = [[T8BatchRequestAgent alloc] init];
    });
    
    return sharedBatchRequestAgent;
}

@end
