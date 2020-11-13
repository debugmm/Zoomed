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

+ (instancetype)testNavigationControllerWithTitle:(nonnull NSString *)title
{
    TestViewController *root = [[TestViewController alloc] init];
    root.title = title;
    NavigationController *nvc = [[NavigationController alloc] initWithRootViewController:root];
    return nvc;
}

@end
