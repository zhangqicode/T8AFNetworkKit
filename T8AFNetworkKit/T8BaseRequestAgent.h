//
//  T8BaseRequestAgent.h
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "T8RequestAgent.h"


@interface T8BaseRequestAgent : T8RequestAgent

+ (T8BaseRequestAgent *)sharedBaseRequestAgent;

@end
