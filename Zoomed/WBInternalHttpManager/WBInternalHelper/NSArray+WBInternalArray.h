//
//  NSArray+WBInternalArray.h
//  BaseLibs
//
//  Created by jungao on 2020/8/5.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (WBInternalArray)

+ (BOOL)isEmptyArray:(nonnull NSArray *)array;

@end

NS_ASSUME_NONNULL_END
