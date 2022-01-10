//
//  WBInternalDownloadTask.h
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#import "WBInternalDataTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalDownloadTask : WBInternalDataTask

/// 收到数据时，回调（回调多次）
@property (nullable, nonatomic, copy) WBInternalDataTaskDidReceiveDataBlock taskReceiveDataBlock;
/// 收到服务端响应时，回调
@property (nullable, nonatomic, copy) WBInternalDataTaskDidReceiveResponseBlock taskDidReceiveResponseBlock;
/// 下载断点续传时，额外需要参数生成block
@property (nullable, nonatomic, copy) WBInternalResumeTaskHTTPHeaderFieldsBlock resumeHttpHeaderFieldsBlock;

@end

NS_ASSUME_NONNULL_END
