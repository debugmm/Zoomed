//
//  ViewController+Private.h
//  Zoomed
//
//  Created by jungao on 2020/11/13.
//

#import "ViewController.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const ViewDidLayoutSubviewsMethodName;
FOUNDATION_EXPORT NSString * const ObserveValueForKeyPathMethodName;

@interface ViewController ()

@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;

- (void)_privateViewDidLayoutSubviews;

- (void)_privateObserveValueForKeyPath:(NSString *)keyPath
                              ofObject:(id)object
                                change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                               context:(void *)context;

#pragma mark - helper
- (void)_privatePerformMethodListWithMethodName:(nonnull NSString *)methodNameString
                             parameters:(nullable NSArray *)parameters;

@end

NS_ASSUME_NONNULL_END
