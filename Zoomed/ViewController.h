//
//  ViewController.h
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <UIKit/UIKit.h>

typedef void (^SafeAreaBlock)(CGFloat topSafeHeight,CGFloat bottomSafeHeight,CGFloat screenWidth,CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight);

@interface ViewController : UIViewController

@property (nonatomic, strong) UILabel *textLabel;

/// 在这个block实现安全区附近的UIView布局
/// 任何继承ViewController的子类，如果复写了如下任何一个方法：
/// viewDidLayoutSubviews、viewSafeAreaInsetsDidChange
/// 子类实现时未调用父类方法，SafeAreaBlock属性将不被执行
@property (nonatomic, copy) SafeAreaBlock safeAreaBlock API_DEPRECATED("请使用自动布局框架实现UI自动布局", ios(9.0,20.0));

@end

