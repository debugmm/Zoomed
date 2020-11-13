//
//  TestViewController.m
//  Zoomed
//
//  Created by jungao on 2020/11/13.
//

#import "TestViewController.h"
#import "ViewController+Private.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    __weak typeof(self) weakSelf = self;
    self.safeAreaBlock = ^(CGFloat topSafeHeight, CGFloat bottomSafeHeight, CGFloat screenWidth, CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight) {
        CGRect topLineViewFrame = weakSelf.topLineView.frame;
        if (topLineViewFrame.origin.y != topSafeHeight+1)
        {
            topLineViewFrame = CGRectMake(0, topSafeHeight+1, screenWidth, 40);
            weakSelf.topLineView.frame = topLineViewFrame;
        }
        CGRect bottomLineViewFrame = weakSelf.bottomLineView.frame;
        if (bottomLineViewFrame.origin.y != (screenHeight-bottomSafeHeight-40-1))
        {
            bottomLineViewFrame = CGRectMake(0, screenHeight-bottomSafeHeight-40-1, screenWidth, 40);
            weakSelf.bottomLineView.frame = bottomLineViewFrame;
        }
    };
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
