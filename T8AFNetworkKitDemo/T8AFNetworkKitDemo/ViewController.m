//
//  ViewController.m
//  T8AFNetworkKitDemo
//
//  Created by 琦张 on 15/5/30.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import "ViewController.h"
#import "DemoService.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [T8BaseNetworkService setBaseUrl:@"http://123.56.100.23:8080/bloodstone"];
    
    [DemoService testRequestWithUserid:@"5565bddd36396439351e7dc7" device:@"ip" block:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        NSLog(@"tt:%@", data);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
