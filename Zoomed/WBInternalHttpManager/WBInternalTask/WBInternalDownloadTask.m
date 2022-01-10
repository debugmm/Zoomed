//
//  WBInternalDownloadTask.m
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#import "WBInternalDownloadTask.h"
#import "WBInternalDataTaskDelegate.h"
#import "WBInternalTask+Private.h"
#import "WBInternalDownloadTask+Private.h"
#import "WBInternalHttpManager.h"
#import "WBInternalHttpManager+Private.h"

@implementation WBInternalDownloadTask

- (void)resume
{
    [self cancel];
    if (self.resumeHttpHeaderFieldsBlock)
    {
        NSDictionary<NSString *,NSString *> *fields = self.resumeHttpHeaderFieldsBlock();
        if (fields && fields.count > 0)
        {
            [fields enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
                [self.originResumeRequest setValue:obj forHTTPHeaderField:key];
            }];
        }
    }
    [self.httpManager resumeTask:self];
}

#pragma mark - WBInternalDataTaskDelegate

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
{
    if (self.taskDidReceiveResponseBlock)
    {
        self.taskDidReceiveResponseBlock(session, dataTask, response);
    }
}

- (void)URLSession:(__unused NSURLSession *)session
          dataTask:(__unused NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    if (self.taskReceiveDataBlock)
    {
        self.taskReceiveDataBlock(session, dataTask, data);
    }
}

@end
