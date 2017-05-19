//
//  T8ChainRequestAgent.m
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import "T8ChainRequestAgent.h"


@implementation T8ChainRequestAgent

+ (T8ChainRequestAgent *)sharedChainRequestAgent
{
    static T8ChainRequestAgent *sharedChainRequestAgent;
    static dispatch_once_t onceTokenForSharedChainRequestAgent;
    dispatch_once(&onceTokenForSharedChainRequestAgent, ^{
        sharedChainRequestAgent = [[T8ChainRequestAgent alloc] init];
    });
    
    return sharedChainRequestAgent;
}

@end
