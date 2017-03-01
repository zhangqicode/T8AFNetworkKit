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

/**
 根据网络请求返回的响应错误code，判断网络请求是否存在致命的错误（fatal error）
 **/
+ (BOOL)isFatalErrorWithErrorCode:(NSInteger)errorCode
{
    switch (errorCode) {
        case kCFHostErrorHostNotFound:
        case kCFHostErrorUnknown: // Query the kCFGetAddrInfoFailureKey to get the value returned from getaddrinfo; lookup in netdb.h
            // HTTP errors
        case kCFErrorHTTPAuthenticationTypeUnsupported:
        case kCFErrorHTTPBadCredentials:
        case kCFErrorHTTPParseFailure:
        case kCFErrorHTTPRedirectionLoopDetected:
        case kCFErrorHTTPBadURL:
        case kCFErrorHTTPBadProxyCredentials:
        case kCFErrorPACFileError:
        case kCFErrorPACFileAuth:
        case kCFStreamErrorHTTPSProxyFailureUnexpectedResponseToCONNECTMethod:
            // Error codes for CFURLConnection and CFURLProtocol
        case kCFURLErrorUnknown:
        case kCFURLErrorCancelled:
        case kCFURLErrorBadURL:
        case kCFURLErrorUnsupportedURL:
        case kCFURLErrorHTTPTooManyRedirects:
        case kCFURLErrorBadServerResponse:
        case kCFURLErrorUserCancelledAuthentication:
        case kCFURLErrorUserAuthenticationRequired:
        case kCFURLErrorZeroByteResource:
        case kCFURLErrorCannotDecodeRawData:
        case kCFURLErrorCannotDecodeContentData:
        case kCFURLErrorCannotParseResponse:
        case kCFURLErrorInternationalRoamingOff:
        case kCFURLErrorCallIsActive:
        case kCFURLErrorDataNotAllowed:
        case kCFURLErrorRequestBodyStreamExhausted:
        case kCFURLErrorFileDoesNotExist:
        case kCFURLErrorFileIsDirectory:
        case kCFURLErrorNoPermissionsToReadFile:
        case kCFURLErrorDataLengthExceedsMaximum:
            // SSL errors
        case kCFURLErrorServerCertificateHasBadDate:
        case kCFURLErrorServerCertificateUntrusted:
        case kCFURLErrorServerCertificateHasUnknownRoot:
        case kCFURLErrorServerCertificateNotYetValid:
        case kCFURLErrorClientCertificateRejected:
        case kCFURLErrorClientCertificateRequired:
        case kCFURLErrorCannotLoadFromNetwork:
            // Cookie errors
        case kCFHTTPCookieCannotParseCookieFile:
            // Errors originating from CFNetServices
        case kCFNetServiceErrorUnknown:
        case kCFNetServiceErrorCollision:
        case kCFNetServiceErrorNotFound:
        case kCFNetServiceErrorInProgress:
        case kCFNetServiceErrorBadArgument:
        case kCFNetServiceErrorCancel:
        case kCFNetServiceErrorInvalid:
            // Special case
        case 101: // null address
        case 102: // Ignore "Frame Load Interrupted" errors. Seen after app store links.
            return YES;
            
        default:
            break;
    }
    
    return NO;
}

@end
