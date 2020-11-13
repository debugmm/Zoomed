//
//  ViewController.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "ViewController.h"
#import "Masonry.h"
#import "AFNetworking.h"
#import "UIImageView+AFNetworking.h"
#import "ScreenBoundsPrint.h"
#import <objc/runtime.h>
#import "PrivateImage.h"

NSString * const ViewSafeAreaInsetsKeyPath = @"view.safeAreaInsets";
NSString * const ViewDidLayoutSubviewsMethodName = @"viewDidLayoutSubviews";
NSString * const ObserveValueForKeyPathMethodName = @"observeValueForKeyPath:ofObject:change:context:";

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UILabel *textLabel;
//test view
@property (nonatomic, strong) UIView *topSeparateLineView;
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;
@property (nonatomic, strong) UIView *bottomSeparateLineView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self _viewsLayoutInit];
//    self.view.safeAreaInsets
    if (@available(iOS 11.0, *))
    {
        [self addObserver:self forKeyPath:ViewSafeAreaInsetsKeyPath options:NSKeyValueObservingOptionNew context:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.textLabel.text = [ScreenBoundsPrint screenInfo];
}

- (void)dealloc
{
    if (@available(iOS 11.0, *)) {
        [self removeObserver:self forKeyPath:ViewSafeAreaInsetsKeyPath];
    }
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
- (void)_viewsLayoutInit
{
//    [self.view addSubview:self.textLabel];
//    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//    }];
    [self.view addSubview:self.topSeparateLineView];
    [self.view addSubview:self.topLineView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.bottomLineView];
    [self.view addSubview:self.bottomSeparateLineView];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(16);
    }];
    [self.topSeparateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(1.0);
    }];
    [self.bottomSeparateLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view.mas_bottomMargin);
        make.leading.trailing.equalTo(self.view);
        make.height.mas_equalTo(1.0);
    }];
}

#pragma mark - _privateViewDidLayoutSubviews
- (void)_privateViewDidLayoutSubviews {
    if (@available(iOS 11.0, *))
    {
    }
    else
    {
        // Fallback on earlier versions
        if (self.safeAreaBlock)
        {
            CGFloat topLayoutLength = self.topLayoutGuide.length;
            CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
            NSLog(@"topLayoutLength:%f,bottomLayoutLength:%f",topLayoutLength,bottomLayoutLength);
            CGFloat w = [UIScreen mainScreen].bounds.size.width;
            CGFloat h = [UIScreen mainScreen].bounds.size.height;
            CGFloat top = topLayoutLength;
            CGFloat bottom = bottomLayoutLength;
            self.safeAreaBlock(top, bottom, w, h, 0, 0);
        }
        [self _privatePerformMethodListWithMethodName:ViewDidLayoutSubviewsMethodName parameters:nil];
    }
}

#pragma mark - privateObserveValueForKeyPath
- (void)_privateObserveValueForKeyPath:(NSString *)keyPath
                              ofObject:(id)object
                                change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                               context:(void *)context
{
    NSLog(@">>>>>>");
    NSLog(@"keyPath:%@",keyPath);
    NSLog(@"object:%@",object);
    NSLog(@"change:%@",change);

    if (@available(iOS 11.0, *))
    {
        if (self.safeAreaBlock &&
            [keyPath isEqualToString:ViewSafeAreaInsetsKeyPath])
        {
            CGFloat w = [UIScreen mainScreen].bounds.size.width;
            CGFloat h = [UIScreen mainScreen].bounds.size.height;
            UIEdgeInsets safeAreaInset = ((NSValue *)[change objectForKey:NSKeyValueChangeNewKey]).UIEdgeInsetsValue;
            CGFloat top = safeAreaInset.top;
            CGFloat bottom = safeAreaInset.bottom;
            self.safeAreaBlock(top, bottom, w, h, 0, 0);
        }
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

#pragma mark - helper
- (void)_privatePerformMethodListWithMethodName:(nonnull NSString *)methodNameString
                                     parameters:(nullable NSArray *)parameters
{
    //读取子类ViewDidLayoutSubviews方法，并执行
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList([self class], &methodCount);
    for (unsigned int i=1; i<methodCount; i++)
    {
        Method method = methodList[i];
        //viewDidLayoutSubviews
        NSString *methodName = NSStringFromSelector(method_getName(method));
        if ([methodName isEqualToString:methodNameString])
        {
            [self _privatePerformSelector:method_getName(method) withObjects:parameters];
        }
    }
}

//可以传多个参数的方法
- (id)_privatePerformSelector:(SEL)selector withObjects:(nullable NSArray *)parameters
{
    // 方法签名(方法的描述)
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        //可以抛出异常也可以不操作。
    }
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;

    //设置参数
    NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    if (parameters && parameters.count > 0)
    {
        paramsCount = MIN(paramsCount, parameters.count);
        for (NSInteger i = 0; i < paramsCount; i++)
        {
            id object = parameters[i];
            if ([object isKindOfClass:[NSNull class]]) continue;
            [invocation setArgument:&object atIndex:i + 2];
        }
    }
    // 调用方法
    [invocation invoke];
    // 获取返回值
    id returnValue = nil;
    if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}

#pragma mark -
- (UILabel *)textLabel
{
    if (!_textLabel)
    {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.font = [UIFont systemFontOfSize:15];
        _textLabel.numberOfLines = 0;
    }
    return _textLabel;
}

- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleToFill;
        _imageView.image = [UIImage imageNamed:self.title];
    }
    return _imageView;
}

- (UIView *)topSeparateLineView
{
    if (!_topSeparateLineView)
    {
        _topSeparateLineView = [[UIView alloc] init];
        _topSeparateLineView.backgroundColor = [UIColor blueColor];
    }
    return _topSeparateLineView;
}

- (UIView *)topLineView
{
    if (!_topLineView)
    {
        _topLineView = [[UIView alloc] init];
        _topLineView.backgroundColor = [UIColor greenColor];
    }
    return _topLineView;
}

- (UIView *)bottomLineView
{
    if (!_bottomLineView)
    {
        _bottomLineView = [[UIView alloc] init];
        _bottomLineView.backgroundColor = [UIColor redColor];
    }
    return _bottomLineView;
}

- (UIView *)bottomSeparateLineView
{
    if (!_bottomSeparateLineView)
    {
        _bottomSeparateLineView = [[UIView alloc] init];
        _bottomSeparateLineView.backgroundColor = [UIColor blueColor];
    }
    return _bottomSeparateLineView;
}

@end
