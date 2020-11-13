//
//  ViewController.h
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <UIKit/UIKit.h>

typedef void (^SafeAreaBlock)(CGFloat topSafeHeight,CGFloat bottomSafeHeight,CGFloat screenWidth,CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight);

@interface ViewController : UIViewController

@property (nonatomic, copy) SafeAreaBlock safeAreaBlock;

@end

