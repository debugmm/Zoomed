//
//  UIView+Border.h
//  Zoomed
//
//  Created by jungao on 2021/11/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (Border)

- (void)drawBoardDottedLine:(double)width
                      lenth:(double)lenth
                      space:(double)space
               cornerRadius:(double)cornerRadius
                      color:(UIColor*)color;

@end

NS_ASSUME_NONNULL_END
