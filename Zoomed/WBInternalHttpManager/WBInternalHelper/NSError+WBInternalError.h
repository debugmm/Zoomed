//
//  NSError+WBInternalError.h
//  WeiboTechs
//
//  Created by jungao on 2020/12/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (WBInternalError)

/// 表示URLLoadingSystem 取消请求（返回的错误）
- (BOOL)isHttpRequestCancelled;

@end

NS_ASSUME_NONNULL_END
