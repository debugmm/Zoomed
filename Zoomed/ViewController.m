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
//#import "UIImageView+ContentScaleFactor.h"
#import "PrivateImage.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UILabel *textLabel;
//test view
@property (nonatomic, strong) UIView *topLineView;
@property (nonatomic, strong) UIView *bottomLineView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self viewsLayoutInit];
//    self.view.safeAreaInsets
    [self addObserver:self forKeyPath:@"view.safeAreaInsets" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    self.textLabel.text = [ScreenBoundsPrint screenInfo];
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
//    [self.view addSubview:self.textLabel];
//    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//    }];
    [self.view addSubview:self.topLineView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.button];
    [self.view addSubview:self.bottomLineView];

    self.button.backgroundColor = [UIColor yellowColor];
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(16);
    }];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.centerX.equalTo(self.view.mas_centerX);
    }];

//    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
//    CGRect tabBarFrame = self.tabBarController.tabBar.frame;
//    CGRect tabBarBounds = self.tabBarController.tabBar.bounds;
//    NSLog(@"statusBarFrame:x:%f,y:%f,w:%f,h:%f",statusBarFrame.origin.x,statusBarFrame.origin.y,statusBarFrame.size.width,statusBarFrame.size.height);
//    NSLog(@"tabBarFrame:x:%f,y:%f,w:%f,h:%f",tabBarFrame.origin.x,tabBarFrame.origin.y,tabBarFrame.size.width,tabBarFrame.size.height);
//    CGFloat h = 40;
//    CGFloat w = statusBarFrame.size.width;
//    CGRect topLineViewFrame = CGRectMake(0, statusBarFrame.origin.y+statusBarFrame.size.height, w, h);
////    CGFloat screenH = [UIScreen mainScreen].bounds.size.height;
//    CGFloat tabbarY = tabBarFrame.origin.y;
//    CGRect bottomLineViewFrame = CGRectMake(0, tabbarY-h, w, h);
//
//    self.topLineView.frame = topLineViewFrame;
//    self.bottomLineView.frame = bottomLineViewFrame;

//    [self.topLineView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.height.mas_equalTo(45);
//        make.leading.trailing.equalTo(self.view);
//    }];
//    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.height.mas_equalTo(45);
//        make.leading.trailing.equalTo(self.view);
//    }];
}

#pragma mark - buttons actions
- (void)buttonAction:(UIButton *)sender
{
//    [self.imageView setImageWithURL:[NSURL URLWithString:@"https://wx3.sinaimg.cn/large/49535fefly1fj72buwho5j21hc0u00xy.jpg"]];
    NSLog(@"imageview:%@",self.imageView);
    NSLog(@"image:%@",self.imageView.image);
    NSLog(@"imageview.traitCollection.displayScale:%f",self.imageView.traitCollection.displayScale);
}

#pragma mark -
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context
{
    NSLog(@"keyPath:%@",keyPath);
    NSLog(@"object:%@",object);
    NSLog(@"change:%@",change);
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    UIEdgeInsets safeAreaInset = ((NSValue *)[change objectForKey:NSKeyValueChangeNewKey]).UIEdgeInsetsValue;
    CGFloat top = safeAreaInset.top;
    CGFloat bottom = safeAreaInset.bottom;

    CGRect topLineViewFrame = self.topLineView.frame;
    if (topLineViewFrame.origin.y != top)
    {
        topLineViewFrame = CGRectMake(0, top, w, 40);
        self.topLineView.frame = topLineViewFrame;
    }
    CGRect bottomLineViewFrame = self.bottomLineView.frame;
    if (bottomLineViewFrame.origin.y != (h-bottom-40))
    {
        bottomLineViewFrame = CGRectMake(0, h-bottom-40, w, 40);
        self.bottomLineView.frame = bottomLineViewFrame;
    }
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
        _imageView.image = [UIImage imageNamed:self.tabBarItem.title];
    }
    return _imageView;
}

- (UIButton *)button
{
    if (!_button)
    {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_button setTitle:@"加载图片" forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_button setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    }
    return _button;
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

@end
