//
//  UIView+Border.m
//  Zoomed
//
//  Created by jungao on 2021/11/5.
//

#import "UIView+Border.h"
#import "UIBezierPath+CustomPath.h"

@implementation UIView (Border)

- (void)drawBoardDottedLine:(double)width
                      lenth:(double)lenth
                      space:(double)space
               cornerRadius:(double)cornerRadius
                      color:(UIColor*)color
{
    self.layer.cornerRadius = cornerRadius;

    CAShapeLayer *borderLayer = [CAShapeLayer layer];

    borderLayer.bounds = self.bounds;
    borderLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    borderLayer.path = [UIBezierPath bezierPathWithRoundedRect:borderLayer.bounds cornerRadius:cornerRadius].CGPath;
    borderLayer.lineWidth = width / [[UIScreen mainScreen] scale];
    //虚线边框---小边框的长度
    borderLayer.lineDashPattern = @[@(lenth), @(space)];//前边是虚线的长度，后边是虚线之间空隙的长度
    borderLayer.lineDashPhase = 0.1;
    //实线边框
    borderLayer.fillColor = [UIColor clearColor].CGColor;
    borderLayer.strokeColor = color.CGColor;
    [self.layer addSublayer:borderLayer];
}

- (void)drawImage
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, YES , 0.0);
    UIImage *image = [self drawXXRect:self.bounds];
    if (!image) {
        image = UIGraphicsGetImageFromCurrentImageContext();
    }
    UIGraphicsEndImageContext();
    self.layer.contents = (id)image.CGImage;
}

- (UIImage *)drawXXRect:(CGRect)rect
{
    CGSize size = rect.size;
    if (size.width <= 0 || size.height <= 0) {
        return nil;
    }

    CGContextRef context = UIGraphicsGetCurrentContext();
    [self _drawBorderWithContext:context size:size];

    return nil;
}

- (BOOL)_bitmapOpaqueWithSize:(CGSize)size
{
    return YES;
}

- (void)_drawBorderWithContext:(CGContextRef)context size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGContextSetAlpha(context, 1.0);
    // fill background color
    UIColor* bgColor = [UIColor greenColor];
    if (bgColor && [bgColor respondsToSelector:@selector(CGColor)]) {
        if (CGColorGetAlpha(bgColor.CGColor) > 0) {
            CGContextSetFillColorWithColor(context, bgColor.CGColor);
            UIBezierPath *bezierPath = [UIBezierPath wx_bezierPathWithRoundedRect:rect topLeft:12 topRight:12 bottomLeft:12 bottomRight:12];
            [bezierPath fill];
            self.backgroundColor = UIColor.clearColor;
        }
    }
    NSInteger borderStyle = 1;
//    _borderTopStyle = _borderLeftStyle = _borderBottomStyle
    // Top
//    if (_borderTopWidth > 0) {
//        if(_borderTopStyle == WBXBorderStyleDashed || _borderTopStyle == WBXBorderStyleDotted){
            CGFloat lengths[2];
            lengths[0] = lengths[1] = (borderStyle == 1 ? 3 : 1) * 1;
            CGContextSetLineDash(context, 0, lengths, sizeof(lengths) / sizeof(*lengths));
//        } else{
//            CGContextSetLineDash(context, 0, 0, 0);
//        }
        CGContextSetLineWidth(context, 1);
//        [self.weexInstance chooseColor:_borderTopColor lightSchemeColor:_lightSchemeBorderTopColor darkSchemeColor:_darkSchemeBorderTopColor invert:self.invertForDarkScheme scene:[self colorSceneType]]
        CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
        CGContextAddArc(context, size.width-12, 12, 12-1/2, -M_PI_4+(1>0?0:M_PI_4), -M_PI_2, 1);
        CGContextMoveToPoint(context, size.width-12, 1/2);
        CGContextAddLineToPoint(context, 12, 1/2);
        CGContextAddArc(context, 12, 12, 12-1/2, -M_PI_2, -M_PI_2-M_PI_4-(1>0?0:M_PI_4), 1);
        CGContextStrokePath(context);
//        _lastBorderRecords |= WBXComponentBorderRecordTop;
//    } else {
//        _lastBorderRecords &= ~(WBXComponentBorderRecordTop);
//    }

    // Left
//    if (_borderLeftWidth > 0) {
//        if(_borderLeftStyle == WBXBorderStyleDashed || _borderLeftStyle == WBXBorderStyleDotted){
//            CGFloat lengths[2];
            lengths[0] = lengths[1] = (YES ? 3 : 1) * 1;
            CGContextSetLineDash(context, 0, lengths, sizeof(lengths) / sizeof(*lengths));
//        } else{
//            CGContextSetLineDash(context, 0, 0, 0);
//        }
        CGContextSetLineWidth(context, 1);
//        [self.weexInstance chooseColor:_borderLeftColor lightSchemeColor:_lightSchemeBorderLeftColor darkSchemeColor:_darkSchemeBorderLeftColor invert:self.invertForDarkScheme scene:[self colorSceneType]]
        CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
        CGContextAddArc(context, 12, 12, 12-1/2, -M_PI, -M_PI_2-M_PI_4+(1 > 0?0:M_PI_4), 0);
        CGContextMoveToPoint(context, 1/2, 12);
        CGContextAddLineToPoint(context, 1/2, size.height-12);
        CGContextAddArc(context, 12, size.height-12, 12-1/2, M_PI, M_PI-M_PI_4-(1>0?0:M_PI_4), 1);
        CGContextStrokePath(context);
//        _lastBorderRecords |= WBXComponentBorderRecordLeft;
//    } else {
//        _lastBorderRecords &= ~WBXComponentBorderRecordLeft;
//    }

    // Bottom
//    if (_borderBottomWidth > 0) {
//        if(_borderBottomStyle == WBXBorderStyleDashed || _borderBottomStyle == WBXBorderStyleDotted){
//            CGFloat lengths[2];
            lengths[0] = lengths[1] = (YES ? 3 : 1) * 1;
            CGContextSetLineDash(context, 0, lengths, sizeof(lengths) / sizeof(*lengths));
//        } else{
//            CGContextSetLineDash(context, 0, 0, 0);
//        }
        CGContextSetLineWidth(context, 1);
//        [self.weexInstance chooseColor:_borderBottomColor lightSchemeColor:_lightSchemeBorderBottomColor darkSchemeColor:_darkSchemeBorderBottomColor invert:self.invertForDarkScheme scene:[self colorSceneType]]
        CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
        CGContextAddArc(context, 12, size.height-12, 12-1/2, M_PI-M_PI_4+(1>0?0:M_PI_4), M_PI_2, 1);
        CGContextMoveToPoint(context, 12, size.height-1/2);
        CGContextAddLineToPoint(context, size.width-12, size.height-1/2);
        CGContextAddArc(context, size.width-12, size.height-12, 12-1/2, M_PI_2, M_PI_4-(1 > 0?0:M_PI_4), 1);
        CGContextStrokePath(context);
//        _lastBorderRecords |= WBXComponentBorderRecordBottom;
//    } else {
//        _lastBorderRecords &= ~WBXComponentBorderRecordBottom;
//    }

    // Right
//    if (_borderRightWidth > 0) {
//        if(_borderRightStyle == WBXBorderStyleDashed || _borderRightStyle == WBXBorderStyleDotted){
//            CGFloat lengths[2];
            lengths[0] = lengths[1] = (YES ? 3 : 1) * 1;
            CGContextSetLineDash(context, 0, lengths, sizeof(lengths) / sizeof(*lengths));
//        } else{
//            CGContextSetLineDash(context, 0, 0, 0);
//        }
        CGContextSetLineWidth(context, 1);
#warning 需要根据颜色模式，执行背景颜色转换
//        [self.weexInstance chooseColor:_borderRightColor lightSchemeColor:_lightSchemeBorderRightColor darkSchemeColor:_darkSchemeBorderRightColor invert:self.invertForDarkScheme scene:[self colorSceneType]]
        CGContextSetStrokeColorWithColor(context,[UIColor redColor].CGColor);
        CGContextAddArc(context, size.width-12, size.height-12, 12-1/2, M_PI_4+(1>0?0:M_PI_4), 0, 1);
        CGContextMoveToPoint(context, size.width-1/2, size.height-12);
        CGContextAddLineToPoint(context, size.width-1/2, 12);
        CGContextAddArc(context, size.width-12, 12, 12-1/2, 0, -M_PI_4-(1 > 0?0:M_PI_4), 1);
        CGContextStrokePath(context);
//        _lastBorderRecords |= WBXComponentBorderRecordRight;
//    } else {
//        _lastBorderRecords &= ~WBXComponentBorderRecordRight;
//    }

    CGContextStrokePath(context);

    //clipRadius is beta feature
    //TO DO: remove _clipRadius property
//    if (_clipToBounds && _clipRadius) {
//        BOOL radiusEqual = _borderTopLeftRadius == _borderTopRightRadius && _borderTopRightRadius == _borderBottomRightRadius && _borderBottomRightRadius == _borderBottomLeftRadius;
        if (YES) {
            self.layer.mask = [self drawBorderRadiusMaskLayer:rect];
        }
//    }
}

- (CAShapeLayer *)drawBorderRadiusMaskLayer:(CGRect)rect
{
//    if ([self hasBorderRadiusMaskLayer]) {
//        WBXRoundedRect *borderRect = [[WBXRoundedRect alloc] initWithRect:rect topLeft:_borderTopLeftRadius topRight:_borderTopRightRadius bottomLeft:_borderBottomLeftRadius bottomRight:_borderBottomRightRadius];
//        WBXRadii *radii = borderRect.radii;
        UIBezierPath *bezierPath = [UIBezierPath wx_bezierPathWithRoundedRect:rect topLeft:12 topRight:12 bottomLeft:12 bottomRight:12];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.path = bezierPath.CGPath;
        return maskLayer;
//    }
//    return nil;
}

@end
