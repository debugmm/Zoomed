//
//  WBInternalUploadTask.h
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#import "WBInternalDataTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalUploadTask : WBInternalTask

@property (nullable, nonatomic, copy) WBIUploadTaskSuccessBlock successBlock;
@property (nullable, nonatomic, copy) WBIUploadTaskFailureBlock failureBlock;

@end

NS_ASSUME_NONNULL_END
