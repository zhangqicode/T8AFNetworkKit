//
//  T8UploadFileRequestAgent.h
//  Pods
//
//  Created by JustBen on 28/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "T8Request.h"


@interface T8UploadFileRequestAgent : NSObject <T8RequestAgent>

+ (T8UploadFileRequestAgent *)sharedUploadFileRequestAgent;

@end
