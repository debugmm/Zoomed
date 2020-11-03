//
//  ScreenBoundsPrint.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "ScreenBoundsPrint.h"
#import <UIKit/UIKit.h>

@implementation ScreenBoundsPrint

+ (void)screenBoundsPrint:(nonnull NSString *)methodName
{
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat nativeScale = [UIScreen mainScreen].nativeScale;
    CGFloat nh = [UIScreen mainScreen].nativeBounds.size.height;
    CGFloat nw = [UIScreen mainScreen].nativeBounds.size.width;
    NSLog(@"%@ h:%f,w:%f,scale:%f,nscale:%f,nh:%f,nw:%f",methodName,h,w,scale,nativeScale,nh,nw);
}

@end
