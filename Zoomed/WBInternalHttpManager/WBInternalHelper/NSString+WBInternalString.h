//
//  NSString+WBInternalStringExtension.h
//  BaseLibs
//
//  Created by jungao on 2020/7/31.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface NSString (WBInternalString)

#pragma mark - base helper
+ (BOOL)isEmptyString:(NSString *)string;

#pragma mark - extension
+ (BOOL)isIPHost:(nonnull NSString *)host;
+ (BOOL)isIPV6:(nonnull NSString *)ipv6;
+ (BOOL)isPureInt:(nonnull NSString *)string;
+ (NSString *)generateStringMD5:(nonnull NSString *)string;

#pragma mark -
+ (nullable NSString *)generateTaskIdentifier:(nonnull NSURLSessionTask *)task;
+ (nullable NSString *)wbInternalGUUID;

@end

NS_ASSUME_NONNULL_END
