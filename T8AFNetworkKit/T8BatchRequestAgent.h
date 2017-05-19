//
//  T8BatchRequestAgent.h
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "T8RequestAgent.h"


@interface T8BatchRequestAgent : T8RequestAgent

+ (T8BatchRequestAgent *)sharedBatchRequestAgent;

@end
