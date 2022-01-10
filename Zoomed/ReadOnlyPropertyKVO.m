//
//  ReadOnlyPropertyKVO.m
//  Zoomed
//
//  Created by jungao on 2021/1/19.
//

#import "ReadOnlyPropertyKVO.h"

#import "Person.h"

@implementation ReadOnlyPropertyKVO

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    static ReadOnlyPropertyKVO *_s;
    dispatch_once(&once, ^{
        _s = [[[self class] alloc] init];
    });
    return _s;
}

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    [[Person sharedManager] addObserver:self forKeyPath:@"height" options:NSKeyValueObservingOptionNew context:nil];
    return self;
}

- (void)dealloc
{
    [[Person sharedManager] removeObserver:self forKeyPath:@"height"];
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey,id> *)change
                       context:(void *)context
{
    NSLog(@"keyPath:%@,object:%@,change:%@",keyPath,object,change);
}

@end
