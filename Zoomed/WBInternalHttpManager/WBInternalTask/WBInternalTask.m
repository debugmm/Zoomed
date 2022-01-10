//
//  WBInternalTask.m
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#import "WBInternalTask.h"
#import "WBInternalTask+Private.h"

@implementation WBInternalTask

- (void)cancel
{
    if (!self.task) return;
    if (self.task.state == NSURLSessionTaskStateRunning ||
        self.task.state == NSURLSessionTaskStateSuspended)
    {
        [self.task cancel];
    }
}

- (void)resume
{
}

#pragma mark - property

#pragma mark -
- (NSURLSessionTaskState)state
{
    return self.task.state;
}

- (NSURLRequest *)currentRequest
{
    
    return self.task.currentRequest;
}

- (NSURLRequest *)originalRequest
{
    return [self.originResumeRequest copy];
}

- (NSUInteger)taskIdentifier
{
    return self.task.taskIdentifier;
}

- (NSString *)taskDescription
{
    return self.task.taskDescription;
}

- (NSError *)error
{
    return self.task.error;
}

- (NSURLResponse *)response
{
    return self.task.response;
}

#pragma mark -
- (int64_t)countOfBytesExpectedToReceive
{
    return self.task.countOfBytesExpectedToReceive;
}

- (int64_t)countOfBytesReceived
{
    return self.task.countOfBytesReceived;
}

- (int64_t)countOfBytesSent
{
    return self.task.countOfBytesSent;
}

@end
