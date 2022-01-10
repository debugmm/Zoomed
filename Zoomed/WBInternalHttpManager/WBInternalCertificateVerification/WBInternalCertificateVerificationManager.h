//
//  WBInternalCertificateVerificationManager.h
//  WeiboTechs
//
//  Created by jungao on 2020/10/22.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

@class WBInternalHttpDNSResult;

NS_ASSUME_NONNULL_BEGIN

typedef id (^WBInternalTaskAuthenticationChallengeBlock)(NSURLSession *session, NSURLSessionTask *task, NSURLAuthenticationChallenge *challenge, void (^completionHandler)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential));

@interface WBInternalCertificateVerificationManager : NSObject

- (nullable id)certificateVerification:(NSURLSession * _Nonnull)session
                                  task:(NSURLSessionTask * _Nonnull)task
                             challenge:(NSURLAuthenticationChallenge * _Nonnull)challenge
                     completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler;

#pragma mark -
@property (nonatomic, assign, readonly) BOOL cacheCerMD5;

@end

NS_ASSUME_NONNULL_END
