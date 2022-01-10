//
//  WBInternalIdentifierGenerator.m
//  WeiboTechs
//
//  Created by jungao on 2020/12/22.
//

#import "WBInternalIdentifierGenerator.h"
#import "NSString+WBInternalString.h"

@implementation WBInternalIdentifierGenerator

+ (NSString *)generateTaskIdentifier
{
    return [NSString wbInternalGUUID];
}

@end
