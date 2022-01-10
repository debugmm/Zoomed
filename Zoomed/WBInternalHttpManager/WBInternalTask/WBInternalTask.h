//
//  WBInternalTask.h
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

#import "WBInternalBlockDefine.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalTask : NSObject

- (void)cancel;

- (void)resume;

#pragma mark - property
@property (nullable, nonatomic, copy) WBIProgress downloadProgressBlock;
@property (nullable, nonatomic, copy) WBIProgress uploadProgressBlock;

@property (nonatomic, strong) NSURLSessionTask *task;

/// 只读属性
@property (nonatomic, readonly, assign) NSURLSessionTaskState state;
@property (nonatomic, readonly, copy) NSURLRequest *currentRequest;
@property (nonatomic, readonly, copy) NSURLRequest *originalRequest;
@property (nonatomic, readonly, assign) NSUInteger taskIdentifier;
@property (nonatomic, readonly, copy) NSString *taskDescription;
@property (nonatomic, readonly, copy) NSError *error;
@property (nonatomic, readonly, copy) NSURLResponse *response;

@end

NS_ASSUME_NONNULL_END
