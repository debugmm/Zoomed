//
//  NavigationController.m
//  Zoomed
//
//  Created by jungao on 2020/11/13.
//

#import "NavigationController.h"
#import "TestViewController.h"

@interface NavigationController ()

@end

@implementation NavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (instancetype)testNavigationController
{
    TestViewController *root = [[TestViewController alloc] init];
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:root];
    return nvc;
}

@end
