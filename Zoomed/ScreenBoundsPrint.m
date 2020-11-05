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

+ (nonnull NSString *)screenInfo
{
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat nativeScale = [UIScreen mainScreen].nativeScale;
    CGFloat nh = [UIScreen mainScreen].nativeBounds.size.height;
    CGFloat nw = [UIScreen mainScreen].nativeBounds.size.width;
    NSString *displayModel = @"标准显示模式";
    if (scale < nativeScale) displayModel = @"放大显示模式";
    NSString *screenInfo = [NSString stringWithFormat:@"当前显示模式：%@\n\n屏幕逻辑尺寸信息：\n屏幕高度：%f\n屏幕宽度：%f\n屏幕放大比例：%f\n\n像素信息：\n屏幕像素高度：%f\n屏幕像素宽度：%f\n屏幕像素放大比例：%f",displayModel,h,w,scale,nh,nw,nativeScale];
    return screenInfo;
}

@end
