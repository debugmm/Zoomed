//
//  WBInternalVolatileCachedDownloadTask.m
//  WeiboTechs
//
//  Created by jungao on 2020/11/28.
//

#import "WBInternalVolatileCachedDownloadTask.h"
#import "WBInternalHttpManager+Private.h"
#import "WBInternalHttpManager.h"
#import "WBInternalTask+Private.h"
#import "WBInternalVolatileCachedDownloadTask+Private.h"

@implementation WBInternalVolatileCachedDownloadTask

- (void)resume
{
    [self cancel];
    [self.httpManager resumeDownloadWithWBIVolatileCachedDownloadTask:self];
}

- (void)cancel
{
    if (!self.task) return;
    if (self.task.state == NSURLSessionTaskStateRunning ||
        self.task.state == NSURLSessionTaskStateSuspended)
    {
        if ([self.task isKindOfClass:[NSURLSessionDownloadTask class]])
        {
            __weak typeof(self) weakSelf = self;
            [((NSURLSessionDownloadTask *)self.task) cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
                weakSelf.resumeData = resumeData;
            }];
        }
        else
        {
            [self.task cancel];
        }
    }
}

@end
