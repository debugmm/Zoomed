//
//  ViewController+PrivateCategory.m
//  Zoomed
//
//  Created by jungao on 2020/11/13.
//

#import "ViewController+PrivateCategory.h"
#import "ViewController+Private.h"

@implementation ViewController (PrivateCategory)

- (void)viewDidLayoutSubviews
{
    if ([self respondsToSelector:@selector(_privateViewDidLayoutSubviews)])
    {
        [self _privateViewDidLayoutSubviews];
    }
    else
    {
        //读取子类实现的viewDidLayoutSubviews方法，并调用。
        [self _privatePerformMethodListWithMethodName:ViewDidLayoutSubviewsMethodName parameters:nil];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context
{
    if ([self respondsToSelector:@selector(_privateObserveValueForKeyPath:ofObject:change:context:)])
    {
        [self _privateObserveValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
    else
    {
        //读取子类实现的viewDidLayoutSubviews方法，并调用。
        NSMutableArray *parameters = [[NSMutableArray alloc] initWithCapacity:1];
        if (!keyPath) keyPath = (id)[NSNull null];
        [parameters addObject:keyPath];
        if (!object) object = [NSNull null];
        [parameters addObject:object];
        if (!change) change = (id)[NSNull null];
        [parameters addObject:change];
        if (!context) context = (void *)CFBridgingRetain([NSNull null]);
        [parameters addObject:CFBridgingRelease(context)];
        [self _privatePerformMethodListWithMethodName:ObserveValueForKeyPathMethodName parameters:parameters];
    }
}

@end
