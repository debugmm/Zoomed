//
//  WBInternalAFHTTPSessionManager+Private.h
//  WeiboTechs
//
//  Created by jungao on 2020/11/28.
//

#import "WBInternalAFHTTPSessionManager.h"
#import "WBInternalDataTaskDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalAFURLSessionManagerTaskDelegate : NSObject
@end

@interface WBInternalAFHTTPSessionManager ()

- (NSURLSessionDataTask *)dataTaskWithRequest:(NSURLRequest *)request
                               uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                             downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                        extensionTaskDelegate:(nullable id<WBInternalDataTaskDelegate>)extensionTaskDelegate
                            completionHandler:(nullable void (^)(NSURLResponse *response, id _Nullable responseObject,  NSError * _Nullable error))completionHandler;

@end

NS_ASSUME_NONNULL_END
