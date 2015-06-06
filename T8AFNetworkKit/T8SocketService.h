//
//  T8SocketService.h
//  T8AFNetworkKitDemo
//
//  Created by 琦张 on 15/6/6.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol T8SocketServiceDelegate <NSObject>

- (void)socketRecievedEvent:(NSString *)event items:(NSArray *)items;

@end

@interface T8SocketService : NSObject

@property (nonatomic, weak) id<T8SocketServiceDelegate> delegate;

+ (T8SocketService *)sharedInstance;

- (void)connectWithUrlWithPort:(NSString *)urlWithPort andParams:(NSDictionary *)params;
- (void)disconnect;

@end
