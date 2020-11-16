//
//  BViewController.m
//  Zoomed
//
//  Created by jungao on 2020/11/16.
//

#import "BViewController.h"
#import "ViewController+Private.h"

@interface BViewController ()

@end

@implementation BViewController

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

@end
