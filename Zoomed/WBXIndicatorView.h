//
//  WBXIndicatorView.h
//  Zoomed
//
//  Created by jungao on 2021/11/30.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger,WBXPointIndicatorAlignStyle)
{
    WBXPointIndicatorAlignCenter,    // point indicator align center
    WBXPointIndicatorAlignLeft,      // point indicator align left
    WBXPointIndicatorAlignRight,     // point indicator align right
};

NS_ASSUME_NONNULL_BEGIN

@interface WBXIndicatorView : UIView

@property (nonatomic, assign)   NSInteger   pointCount;         // total count point of point indicator
@property (nonatomic, assign)   NSInteger   currentPoint;       // current light index of point at point indicator
@property (nonatomic, strong)   UIColor *pointColor;        // normal point color of point indicator
@property (nonatomic, strong)   UIColor *lightColor;        // highlight point color of point indicator
@property (nonatomic, assign)   WBXPointIndicatorAlignStyle  alignStyle;    //align style of point indicator
@property (nonatomic, assign)   CGFloat pointSize;          // point size of point indicator
@property (nonatomic, assign)   CGFloat pointSpace;         // point space of point indicator

@end

NS_ASSUME_NONNULL_END
