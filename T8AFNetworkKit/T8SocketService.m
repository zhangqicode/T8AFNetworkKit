//
//  T8SocketService.m
//  T8AFNetworkKitDemo
//
//  Created by 琦张 on 15/6/6.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import "T8SocketService.h"
#import "T8AFNetworkKitDemo-Swift.h"

@interface T8SocketService ()

@property (nonatomic) SocketIOClient *socketClient;

@end

@implementation T8SocketService

+ (T8SocketService *)sharedInstance
{
    static dispatch_once_t once;
    static T8SocketService *singleInstance;
    dispatch_once(&once, ^{
        singleInstance = [[self alloc] init];
    });
    return singleInstance;
}

- (void)connectWithUrlWithPort:(NSString *)urlWithPort andParams:(NSDictionary *)params
{
    if (self.socketClient.connected || self.socketClient.connecting) {
        [self.socketClient disconnectWithFast:YES];
    }
    self.socketClient = [[SocketIOClient alloc] initWithSocketURL:urlWithPort options:[NSDictionary dictionaryWithObject:params forKey:@"connectParams"]];
    __weak typeof(self) weakSelf = self;
    [self.socketClient onAny:^(SocketAnyEvent * __nonnull socketEvent) {
        NSLog(@"event:%@, items:%@", socketEvent.event, socketEvent.items);
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(socketRecievedEvent:items:)]) {
            [weakSelf.delegate socketRecievedEvent:socketEvent.event items:socketEvent.items];
        }
    }];
    [self.socketClient connect];
}

- (void)disconnect
{
    if (self.socketClient) {
        [self.socketClient disconnectWithFast:YES];
    }
}

@end
