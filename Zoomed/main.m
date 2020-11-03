//
//  main.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ScreenBoundsPrint.h"

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    [ScreenBoundsPrint screenBoundsPrint:@"main"];
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
