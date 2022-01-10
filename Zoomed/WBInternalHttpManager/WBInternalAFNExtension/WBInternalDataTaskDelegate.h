//
//  WBInternalDataTaskDelegate.h
//  WeiboTechs
//
//  Created by jungao on 2020/11/28.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

NS_ASSUME_NONNULL_BEGIN

@protocol WBInternalDataTaskDelegate <NSObject>
/// 收到服务端响应时回调（服务端返回的初始化响应头）
/// @param session session
/// @param dataTask dataTask
/// @param response response
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response;

/// 收到服务端返回的数据时回调
/// @param session session
/// @param dataTask dataTask
/// @param data data
- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
