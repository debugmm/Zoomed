//
//  PrivateScreenMode.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "PrivateScreenMode.h"

@interface PrivateScreenMode ()

@end

@implementation PrivateScreenMode

- (CGSize)size
{
    return CGSizeMake(self.w, self.h);
}

- (CGFloat)pixelAspectRatio
{
    if (self.h == 0 || self.w == 0) return 0.0;
    return self.w / self.h;
}

@end
