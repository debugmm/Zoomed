//
//  NSError+WBInternalError.m
//  WeiboTechs
//
//  Created by jungao on 2020/12/15.
//

#import "NSError+WBInternalError.h"
#import "NSString+WBInternalString.h"

@implementation NSError (WBInternalError)

- (BOOL)isHttpRequestCancelled
{
    if (self.code != NSURLErrorCancelled) return NO;
    NSString *errorDomain = self.domain;
    if ([NSString isEmptyString:errorDomain]) return NO;
    if (![errorDomain isEqualToString:NSURLErrorDomain]) return NO;
    return YES;
}

@end
