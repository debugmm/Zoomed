//
//  AppDelegate.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "ScreenBoundsPrint.h"

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
    [self.window makeKeyAndVisible];
    [ScreenBoundsPrint screenBoundsPrint:@"application:didFinishLaunchingWithOptions"];
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
