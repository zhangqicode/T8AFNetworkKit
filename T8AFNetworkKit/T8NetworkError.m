//
//  extError.m
//  Telegraph
//
//  Created by yewei on 15/2/14.
//
//

#import "T8NetworkError.h"

@implementation T8NetworkError

+ (T8NetworkError*)errorWithNSError:(NSError*)error {
    T8NetworkError* myError;
    if(error){
        NSString *errorDomain;
        if(error.domain){
            errorDomain = error.domain;
        }else{
            errorDomain = @"";
        }
        myError = [T8NetworkError errorWithDomain:errorDomain code:error.code userInfo:error.userInfo];
    }else{
        NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
        [userInfo setObject:[NSString stringWithFormat:@"%d", -1] forKey:@"code"];
        [userInfo setObject:@"网络连接失败，请稍后再试" forKey:@"msg"];
        myError = [T8NetworkError errorWithDomain:@"ChannelSoft" code:-1 userInfo:userInfo];
    }
    
    return myError;
}

+ (T8NetworkError*)errorWithCode:(NSInteger)code errorMessage:(NSString*)errorMessage
{
    NSMutableDictionary* userInfo = [[NSMutableDictionary alloc] initWithCapacity:2];
    [userInfo setObject:[NSString stringWithFormat:@"%ld", (long)code] forKey:@"code"];
    if (errorMessage) {
        [userInfo setObject:errorMessage forKey:@"msg"];
    }
    
    T8NetworkError* error = [T8NetworkError errorWithDomain:@"ChannelSoft" code:code userInfo:userInfo];
    return error;
    
}

- (NSString*)titleForError {
    NSString* title = nil;
    if (NSOrderedSame == [self.domain compare:@"NSURLErrorDomain"]) {
        switch (self.code) {
            case NSURLErrorNotConnectedToInternet:
                title = @"网络连接失败，请稍后再试";
                break;
            case NSURLErrorTimedOut:
                title = @"连接超时";
                break;
            case kCFURLErrorCancelled:
                title = @"网络连接失败，请稍后再试";
            default:
                break;
        }
    } else if (NSOrderedSame == [self.domain compare:@"NSPOSIXErrorDomain"] ||
               NSOrderedSame == [self.domain compare:@"kCFErrorDomainCFNetwork"]) {
        title = @"网络连接失败，请稍后再试";
    }
    else
    {
        
    }
    
    if (title == nil) {
        title = [self.userInfo objectForKey:@"msg"];
    }
    // 如果还没取到，就写死
    if (title == nil) {
        title = @"网络连接失败，请稍后再试";
    }
    
    return title;
}

@end
