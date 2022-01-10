//
//  WBInternalDataTask.m
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#import "WBInternalDataTask.h"
#import "WBInternalHttpManager+Private.h"
#import "WBInternalHttpManager.h"
#import "WBInternalTask+Private.h"

@implementation WBInternalDataTask

- (void)resume
{
    [self cancel];
    [self.httpManager resumeTask:self];
}

@end
