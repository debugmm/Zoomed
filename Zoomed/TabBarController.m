//
//  TabBarController.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "TabBarController.h"
#import "TestViewController.h"
#import "NavigationController.h"

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
    NavigationController *v1 = [NavigationController testNavigationControllerWithTitle:@"checked"];//[[TestViewController alloc] init];
    v1.tabBarItem.title = @"checked";
    v1.tabBarItem.image = [UIImage imageNamed:@"checked"];

//    v1.tabBarItem.imageInsets = UIEdgeInsetsMake(20, 0, 20, 0);

//    NavigationController *v2 = [NavigationController testNavigationControllerWithTitle:@"identity"];//[[TestViewController alloc] init];
//    v2.tabBarItem.title = @"identity";
//    v2.tabBarItem.image = [UIImage imageNamed:@"identity"];
//
//    NavigationController *v3 = [NavigationController testNavigationControllerWithTitle:@"location"];//[[TestViewController alloc] init];
//    v3.tabBarItem.title = @"location";
//    v3.tabBarItem.image = [UIImage imageNamed:@"location"];
//
//    NavigationController *v4 = [NavigationController testNavigationControllerWithTitle:@"refresh"];//[[TestViewController alloc] init];
//    v4.tabBarItem.title = @"refresh";
//    v4.tabBarItem.image = [UIImage imageNamed:@"refresh"];

    self.viewControllers = @[v1];//@[v1,v2,v3,v4];
}

@end
