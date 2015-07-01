//
//  ViewController.m
//  T8AFNetworkKitDemo
//
//  Created by 琦张 on 15/5/30.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import "ViewController.h"
#import "DemoService.h"
#import "T8SocketService.h"
#import <Foundation/Foundation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [T8BaseNetworkService setBaseUrl:@"http://123.56.100.23:8080/bloodstone"];
    
//    [DemoService testRequestWithUserid:@"5565bddd36396439351e7dc7" device:@"ip" block:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
//        NSLog(@"tt:%@", data);
//    }];
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:@"5565bddd36396439351e7dc7", @"user_id", @"device1", @"device_id", @"dG9rZW46ODBlN2ZlZDFhZDdiNDE2OTljN2JlNDc5YTMzZGZkZmY6ZXhwaXJlOjIzNzk0OTI1ODQ0MDQ=", @"token" , nil];
    [[T8SocketService sharedInstance] connectWithUrlWithPort:@"10.0.0.6:3000" andParams:params];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
