//
//  T8BaseRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8BaseRequestAgent.h"

@implementation T8BaseRequestAgent

+ (T8BaseRequestAgent *)sharedBaseRequestAgent
{
    static T8BaseRequestAgent *sharedBaseRequestAgent;
    static dispatch_once_t onceTokenForSharedBaseRequestAgent;
    dispatch_once(&onceTokenForSharedBaseRequestAgent, ^{
        sharedBaseRequestAgent = [[T8BaseRequestAgent alloc] init];
    });
    
    return sharedBaseRequestAgent;
}

@end
