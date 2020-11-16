//
//  UIViewController+PrivateCategory.h
//  Zoomed
//
//  Created by jungao on 2020/11/16.
//

#import <UIKit/UIKit.h>

//typedef void (^SafeAreaBlock)(CGFloat topSafeHeight,CGFloat bottomSafeHeight,CGFloat screenWidth,CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight);

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (PrivateCategory)

/// 在这个block实现安全区附近的UIView布局
//@property (nonatomic, copy) SafeAreaBlock safeAreaBlock NS_DEPRECATED_IOS(9_0, 16_0, "请使用自动布局");

@end

NS_ASSUME_NONNULL_END
