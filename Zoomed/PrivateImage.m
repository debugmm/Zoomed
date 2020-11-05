//
//  PrivateImage.m
//  Zoomed
//
//  Created by jungao on 2020/11/5.
//

#import "PrivateImage.h"

@implementation PrivateImage

+ (UIImage *)imageNamed:(NSString *)name
{
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat nativeScale = [UIScreen mainScreen].nativeScale;
    if (scale == nativeScale) return [super imageNamed:name];
    UIImage *originImage = [super imageNamed:name];
    if (!originImage) return nil;
    CIImage *ciimage = [[CIImage alloc] initWithImage:originImage];
    NSDictionary *options = @{CIDetectorImageOrientation:@(1)};
    NSArray<CIFilter *> * filters = [ciimage autoAdjustmentFiltersWithOptions:options];
    for (CIFilter *filter in filters) {
        [filter setValue:ciimage forKey:kCIInputImageKey];
        ciimage = filter.outputImage;
    }
    CGImageRef cgImage = [[CIContext context] createCGImage:ciimage fromRect:ciimage.extent];
    return [[UIImage alloc] initWithCGImage:cgImage];
}

@end
