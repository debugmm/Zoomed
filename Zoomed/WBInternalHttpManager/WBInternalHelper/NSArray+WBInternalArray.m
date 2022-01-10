//
//  NSArray+WBInternalArray.m
//  BaseLibs
//
//  Created by jungao on 2020/8/5.
//

#import "NSArray+WBInternalArray.h"

@implementation NSArray (WBInternalArray)

+ (BOOL)isEmptyArray:(nonnull NSArray *)array
{
    if (!array || ![array isKindOfClass:[NSArray class]] || array.count == 0) return YES;
    return NO;
}

@end
