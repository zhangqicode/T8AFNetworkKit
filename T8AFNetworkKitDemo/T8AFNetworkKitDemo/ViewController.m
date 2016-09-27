//
//  ViewController.m
//  T8AFNetworkKitDemo
//
//  Created by 琦张 on 15/5/30.
//  Copyright (c) 2015年 琦张. All rights reserved.
//

#import "ViewController.h"
#import "DemoService.h"

#import "T8BaseRequest.h"
#import "T8BatchRequest.h"
#import "T8ChainRequest.h"
#import "T8UploadFileRequest.h"


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
    
    
    T8ChainRequest *chainRequest = [[T8ChainRequest alloc] initWithRequests:@[] completeCondition:ChainRequestCompleteCondiction_AllRequested completeBlock:^(NSUInteger completeCount, NSUInteger succeedCount, NSUInteger failedCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"🎉🎉🎉🎉🎉🎉🎉🎉🎉chain request completed. completeCount:%ld succeedCount:%ld failedCount:%ld", completeCount, succeedCount, failedCount);
        });
    } shouldComplete:NO];
    
    
    T8BaseRequest *request1 = [DemoService getTestRequestWithUserid:@"5565bddd36396439351e7dc7" device:@"ip" block:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"request1 completed");
        });
    }];
    [chainRequest addRequest:request1 shouldComplete:NO];
    
    
    NSMutableArray *requests = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < 10; i++) {
        T8BaseRequest *request = [DemoService getTestRequestWithUserid:@"5565bddd36396439351e7dc7" device:@"ip" block:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"request completed");
            });
        }];
        [requests addObject:request];
    }
    T8BatchRequest *batchRequest = [[T8BatchRequest alloc] initWithRequests:requests completeCondition:BatchRequestCompleteCondiction_AnyFailed completeBlock:^(NSUInteger completeCount, NSUInteger succeedCount, NSUInteger failedCount) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"chain request completed");
        });
    }];
    
    if (batchRequest) {
        [chainRequest addRequest:batchRequest shouldComplete:NO];
    }
    
    
    T8BaseRequest *request2 = [DemoService getTestRequestWithUserid:@"5565bddd36396439351e7dc7" device:@"ip" block:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"request1 completed");
        });
    }];
    [chainRequest addRequest:request2 shouldComplete:NO];

    
    NSMutableArray *fileInfos = [[NSMutableArray alloc] init];
    UIImage *image = [UIImage imageNamed:@"0578"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.8);
    [fileInfos addObject:@{@"type": @"data", @"data": imageData, @"filename": @"images", @"mimetype": @"image/jpg"}];
    
    T8UploadFileRequest *uploadRequest = [[T8UploadFileRequest alloc] initWithFileInfos:fileInfos path:@"v3/upload/picture" params:nil progressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        
    } completeBlock:^(RequestStatus status, NSDictionary *data, T8NetworkError *error) {
        
    }];
    
    [chainRequest addRequest:uploadRequest shouldComplete:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
