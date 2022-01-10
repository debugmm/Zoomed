//
//  WBXIndicatorView.m
//  Zoomed
//
//  Created by jungao on 2021/11/30.
//

#import "WBXIndicatorView.h"

@implementation WBXIndicatorView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.pointSize = 5;
        self.pointColor = [UIColor colorWithRed:0xff/255.0f green:0xff/255.0f blue:0xff/255.0f alpha:0.5f];
        self.lightColor = [UIColor colorWithRed:0xff/255.0f green:0xd5/255.0f blue:0x45/255.0f alpha:1.0f];
        self.alignStyle = WBXPointIndicatorAlignCenter;
        self.userInteractionEnabled = NO;
        self.pointCount = 100;
        self.currentPoint = 0;
        self.pointSpace = 1;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.alignStyle == WBXPointIndicatorAlignCenter)
    {
        CGFloat startX = 0.0f, centerX = self.frame.size.width / 2.0f;
        if (self.pointCount % 2)
        {
            startX = centerX - (self.pointSize + self.pointSpace) * (int)(self.pointCount / 2.0f) - self.pointSize / 2.0f;
        }
        else
        {
            startX = centerX - (self.pointSize + self.pointSpace) * (int)(self.pointCount / 2.0f) +  self.pointSpace / 2.0f;
        }

        CGContextRef context=UIGraphicsGetCurrentContext();
        CGContextBeginPath(context);

        for (int i = 0; i < self.pointCount; i++)
        {
            if (self.currentPoint == i)
            {
                CGContextSetFillColorWithColor(context, self.lightColor.CGColor);
                CGContextAddEllipseInRect(context, CGRectMake(startX, (self.frame.size.height - self.pointSize) / 2.0f, self.pointSize, self.pointSize));
                CGContextFillPath(context);
            }
            else
            {
                CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
                CGContextAddEllipseInRect(context, CGRectMake(startX, (self.frame.size.height - self.pointSize) / 2.0f, self.pointSize, self.pointSize));
                CGContextFillPath(context);
            }
            startX += self.pointSize + self.pointSpace;
        }
    }
    else if (self.alignStyle == WBXPointIndicatorAlignRight)
    {
        CGFloat startX = self.frame.size.width - self.pointSize * self.pointCount - self.pointSpace * (self.pointCount - 1) - 10;   //10 right margin
        CGContextRef context=UIGraphicsGetCurrentContext();
        CGContextBeginPath(context);

        for(int i = 0; i < self.pointCount; i++)
        {
            if (self.currentPoint == i)
            {
                CGContextSetFillColorWithColor(context, self.lightColor.CGColor);
                CGContextAddEllipseInRect(context, CGRectMake(startX, (self.frame.size.height - self.pointSize) / 2.0f, self.pointSize, self.pointSize));
                CGContextFillPath(context);
            }
            else
            {
                CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
                CGContextAddEllipseInRect(context, CGRectMake(startX, (self.frame.size.height - self.pointSize) / 2.0f, self.pointSize, self.pointSize));
                CGContextFillPath(context);
            }
            startX += self.pointSize + self.pointSpace;
        }
    }
    else if (self.alignStyle == WBXPointIndicatorAlignLeft)
    {
        CGFloat startX = 10.0f;   //10 left margin
        CGContextRef context=UIGraphicsGetCurrentContext();
        CGContextBeginPath(context);
        for(int i = 0; i < self.pointCount; i++)
        {
            if (self.currentPoint == i)
            {
                CGContextSetFillColorWithColor(context, self.lightColor.CGColor);
                CGContextAddEllipseInRect(context, CGRectMake(startX, (self.frame.size.height - self.pointSize) / 2.0f, self.pointSize, self.pointSize));
                CGContextFillPath(context);
            }
            else
            {
                CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
                CGContextAddEllipseInRect(context, CGRectMake(startX, (self.frame.size.height - self.pointSize) / 2.0f, self.pointSize, self.pointSize));
                CGContextFillPath(context);
            }
            startX += self.pointSize + self.pointSpace;
        }
    }
}

@end
