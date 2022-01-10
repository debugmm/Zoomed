//
//  WBInternalDataTask.h
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#import "WBInternalTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalDataTask : WBInternalTask

#pragma mark - property
@property (nullable, nonatomic, copy) WBIDataTaskSuccessBlock successBlock;
@property (nullable, nonatomic, copy) WBIDataTaskFailureBlock failureBlock;

@end

NS_ASSUME_NONNULL_END
