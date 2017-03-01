//
//  T8BaseRequestAgent.h
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "T8Request.h"


@interface T8BaseRequestAgent : NSObject <T8RequestAgent>

+ (T8BaseRequestAgent *)sharedBaseRequestAgent;

@end
