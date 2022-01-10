//
//  Person.m
//  Zoomed
//
//  Created by jungao on 2021/1/19.
//

#import "Person.h"
#import "Person+Private.h"

@implementation Person

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static Person *_p;
    dispatch_once(&once, ^{
        _p = [[Person alloc] init];
    });
    return _p;
}

@end
