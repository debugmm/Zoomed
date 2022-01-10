//
//  WBXSliderView.m
//  Zoomed
//
//  Created by jungao on 2021/12/6.
//

#import "WBXSliderView.h"

@implementation WBXSliderView

- (CGRect)maximumValueImageRectForBounds:(CGRect)bounds
{
    NSLog(@">maximumValueImageRectForBounds");
//    NSLog(@"new x:%0.f,y:%0.f,w:%0.f,h:%0.f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    CGRect originBounds = [super maximumValueImageRectForBounds:bounds];
//    CGRect newBounds = CGRectMake(originBounds.origin.x, originBounds.origin.y, bounds.size.width, bounds.size.height);
    NSLog(@">origin x:%0.f,y:%0.f,w:%0.f,h:%0.f",originBounds.origin.x,originBounds.origin.y,originBounds.size.width,originBounds.size.height);
    return originBounds;
}
////
- (CGRect)minimumValueImageRectForBounds:(CGRect)bounds
{
    NSLog(@">>minimumValueImageRectForBounds");
//    NSLog(@"new x:%0.f,y:%0.f,w:%0.f,h:%0.f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    CGRect originBounds = [super minimumValueImageRectForBounds:bounds];
//    CGRect newBounds = CGRectMake(originBounds.origin.x, originBounds.origin.y, bounds.size.width, bounds.size.height);
    NSLog(@">>origin x:%0.f,y:%0.f,w:%0.f,h:%0.f",originBounds.origin.x,originBounds.origin.y,originBounds.size.width,originBounds.size.height);
    return originBounds;
}
////
- (CGRect)trackRectForBounds:(CGRect)bounds
{
    NSLog(@">>>trackRectForBonds");
//    NSLog(@"new x:%0.f,y:%0.f,w:%0.f,h:%0.f",bounds.origin.x,bounds.origin.y,bounds.size.width,bounds.size.height);
    CGRect originBounds = [super trackRectForBounds:bounds];
    NSLog(@">>>origin x:%0.f,y:%0.f,w:%0.f,h:%0.f",originBounds.origin.x,originBounds.origin.y,originBounds.size.width,originBounds.size.height);
    return originBounds;
}

- (CGRect)thumbRectForBounds:(CGRect)bounds
                   trackRect:(CGRect)rect
                       value:(float)value
{
    NSLog(@">>>>thumbRectForBounds");
    NSLog(@"value:%f",value);
    CGRect originBounds = [super thumbRectForBounds:bounds trackRect:rect value:value];
    CGFloat h = 100;
    CGFloat y = (bounds.size.height - h)/2;
    CGRect newBounds = CGRectMake(originBounds.origin.x, y, h, h);
//    NSLog(@">>>>origin x:%0.f,y:%0.f,w:%0.f,h:%0.f",originBounds.origin.x,originBounds.origin.y,originBounds.size.width,originBounds.size.height);
    return originBounds;
}

#pragma mark - helper
- (CGRect)convertNewBoundsFrom:(CGRect)bounds originBounds:(CGRect)originBounds
{
    CGRect newBounds = CGRectMake(originBounds.origin.x, originBounds.origin.y, bounds.size.width, bounds.size.height);
    return newBounds;
}

@end
