//
//  ViewController.h
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <UIKit/UIKit.h>

typedef void (^SafeAreaBlock)(CGFloat topSafeHeight,CGFloat bottomSafeHeight,CGFloat screenWidth,CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight);

@interface ViewController : UIViewController

@property (nonatomic, copy) SafeAreaBlock safeAreaBlock NS_DEPRECATED_IOS(9_0, 16_0, "请使用自动布局");

@end

