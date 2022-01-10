//
//  WBInternalVolatileCachedDownloadTask+Private.h
//  WeiboTechs
//
//  Created by jungao on 2020/12/18.
//

#import "WBInternalVolatileCachedDownloadTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalVolatileCachedDownloadTask ()

@property (nullable, readwrite, nonatomic, strong) NSData *resumeData;

@end

NS_ASSUME_NONNULL_END
