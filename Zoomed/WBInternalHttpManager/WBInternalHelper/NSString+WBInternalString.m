//
//  NSString+WBInternalStringExtension.m
//  BaseLibs
//
//  Created by jungao on 2020/7/31.
//

#import "NSString+WBInternalString.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (WBInternalString)

#pragma mark - extension
+ (BOOL)isIPHost:(nonnull NSString *)host
{
    if ([self isEmptyString:host]) return NO;
    //ipv6
    if ([host containsString:@":"]) return YES;
    //ipv4 192.168.1.10
    if ([host componentsSeparatedByString:@"."].count != 4) return NO;
    host = [host stringByReplacingOccurrencesOfString:@"." withString:@""];
    return [self isPureInt:host];
}

+ (BOOL)isIPV6:(nonnull NSString *)ipv6
{
    if ([self isEmptyString:ipv6]) return NO;
    return ([ipv6 containsString:@":"]);
}

+ (BOOL)isPureInt:(nonnull NSString *)string
{
    if ([self isEmptyString:string]) return NO;
    // 编写正则表达式：只能是数字
    NSString *regex = @"^[0-9]*$";
    // 创建谓词对象并设定条件的表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}

#pragma mark - about MD5
+(NSString *)generateStringMD5:(nonnull NSString *)string{

    if([NSString isEmptyString:string])
    {
        return @"";
    }
    const char *cStr=string.UTF8String;
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    //generate string md5
    CC_MD5(cStr, (CC_LONG)strlen(cStr), digest);
    NSMutableString *md5Str=[[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i=0;i<CC_MD5_DIGEST_LENGTH;i++)
    {
        [md5Str appendFormat:@"%02x",digest[i]];
    }
    return md5Str;
}

#pragma mark -
+ (nullable NSString *)generateTaskIdentifier:(nonnull NSURLSessionTask *)task
{
    if (!task) return nil;
    NSString *taskId = [NSString stringWithFormat:@"%lu",(unsigned long)task.taskIdentifier];
    NSString *guid = [self wbInternalGUUID];
    NSString *key = [NSString stringWithFormat:@"%@%@",taskId,guid];
    return key;
}

+ (nullable NSString *)wbInternalGUUID
{
    CFUUIDRef guuidRef = CFUUIDCreate(NULL);
    NSString *guuid = CFBridgingRelease(CFUUIDCreateString(NULL, guuidRef));
    return guuid;
}

#pragma mark - base helper
+ (BOOL)isEmptyString:(NSString *)string
{
    if (!string || ![string isKindOfClass:[NSString class]] || string.length < 1) return YES;
    return NO;
}

@end
