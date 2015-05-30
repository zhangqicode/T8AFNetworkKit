//
//  DemoService.h
//  T8AFNetworkKitDemo
//
//  Created by 琦张 on 15/5/30.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "T8BaseNetworkService.h"

@interface DemoService : NSObject

+ (void)testRequestWithUserid:(NSString *)userid device:(NSString *)device block:(RequestComplete)requestComplete;

@end
