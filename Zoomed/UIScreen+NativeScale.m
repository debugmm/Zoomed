//
//  UIScreen+NativeScale.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "UIScreen+NativeScale.h"
#import "PrivateScreenMode.h"

@implementation UIScreen (NativeScale)

//- (CGFloat)nativeScale
//{
//    return self.scale;
//}
////
//- (CGRect)bounds
//{
//    CGFloat scale = self.scale;
//    CGFloat h = self.nativeBounds.size.height / scale;
//    CGFloat w = self.nativeBounds.size.width / scale;
//    return CGRectMake(0, 0, w, h);
//}
//
//- (UIScreenMode *)currentMode
//{
//    PrivateScreenMode *m = [[PrivateScreenMode alloc] init];
//    m.h = self.nativeBounds.size.height;
//    m.w = self.nativeBounds.size.width;
//    return m;
//}
//
//- (UIScreenMode *)preferredMode
//{
//    return [self currentMode];
//}

@end
