//
//  ViewController.h
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <UIKit/UIKit.h>

typedef void (^SafeAreaBlock)(CGFloat topSafeHeight,CGFloat bottomSafeHeight,CGFloat screenWidth,CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight);

@interface ViewController : UIViewController

/// 在这个block实现安全区附近的UIView布局
@property (nonatomic, copy) SafeAreaBlock safeAreaBlock NS_DEPRECATED_IOS(9_0, 16_0, "请使用自动布局");


/// 继承自ViewController的类，在实现这个方法的时候，必须先调用父方法
/// [super viewDidLayoutSubviews];
- (void)viewDidLayoutSubviews;

///  继承自ViewController的类，在实现这个方法的时候，必须先调用父方法
/// [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
/// @param keyPath keyPath
/// @param object object
/// @param change change
/// @param context context
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context;

@end

