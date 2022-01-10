//
//  WBInternalVolatileCachedDownloadTask.h
//  WeiboTechs
//
//  Created by jungao on 2020/11/28.
//

#import "WBInternalTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalVolatileCachedDownloadTask : WBInternalTask

/// 恢复继续执行
- (void)resume;

#pragma mark - property
@property (nullable, nonatomic, copy) WBIVolatileCachedDownloadTaskSuccessBlock successBlock;
@property (nullable, nonatomic, copy) WBIVolatileCachedDownloadTaskFailureBlock failureBlock;
@property (nullable, nonatomic, copy) WBIVolatileCachedDownloadTaskDestination destinationBlock;
@property (nullable, readonly, nonatomic, strong) NSData *resumeData;

@end

NS_ASSUME_NONNULL_END
