//
//  AppDelegate.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "AppDelegate.h"
#import "TabBarController.h"
#import "ScreenBoundsPrint.h"
#import "ViewController.h"

@interface AppDelegate ()
{
    UIWindow *_window;
}

@property (nonatomic, strong, readwrite) UIWindow *window;

@end

@implementation AppDelegate
@synthesize window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window.rootViewController = [[ViewController alloc] init];
    CGFloat scale = [UIScreen mainScreen].scale;
    CGFloat h = [UIScreen mainScreen].nativeBounds.size.height / scale;
    CGFloat w = [UIScreen mainScreen].nativeBounds.size.width / scale;
//    self.window.bounds = CGRectMake(0, 0, w, h);

    [self.window makeKeyAndVisible];
    [ScreenBoundsPrint screenBoundsPrint:@"application:didFinishLaunchingWithOptions"];
    NSLog(@"window:%@",self.window);
    return YES;
}

#pragma mark - property
- (UIWindow *)window
{
    if (!_window)
    {
        _window = [[UIWindow alloc] init];
    }
    return _window;
}

@end
