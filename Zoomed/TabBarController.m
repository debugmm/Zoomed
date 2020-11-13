//
//  TabBarController.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "TabBarController.h"
#import "TestViewController.h"

@interface TabBarController ()

@end

@implementation TabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self viewsLayoutInit];
}

#pragma mark -
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - views layout init
- (void)viewsLayoutInit
{
    ViewController *v1 = [[TestViewController alloc] init];
    v1.tabBarItem.title = @"checked";
    v1.tabBarItem.image = [UIImage imageNamed:@"checked"];

    ViewController *v2 = [[TestViewController alloc] init];
    v2.tabBarItem.title = @"identity";
    v2.tabBarItem.image = [UIImage imageNamed:@"identity"];

    ViewController *v3 = [[TestViewController alloc] init];
    v3.tabBarItem.title = @"location";
    v3.tabBarItem.image = [UIImage imageNamed:@"location"];

    ViewController *v4 = [[TestViewController alloc] init];
    v4.tabBarItem.title = @"refresh";
    v4.tabBarItem.image = [UIImage imageNamed:@"refresh"];

    self.viewControllers = @[v1,v2,v3,v4];
}

@end
