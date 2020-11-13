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
    [self viewsLayoutInit];
//    self.view.safeAreaInsets
//    [self addObserver:self forKeyPath:@"view.safeAreaInsets" options:NSKeyValueObservingOptionNew context:nil];
    self.view.backgroundColor = [UIColor whiteColor];
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

- (void) viewDidLayoutSubviews {
    CGFloat topLayoutLength = self.topLayoutGuide.length;
    CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
    NSLog(@"topLayoutLength:%f,bottomLayoutLength:%f",topLayoutLength,bottomLayoutLength);
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    CGFloat top = topLayoutLength;
    CGFloat bottom = bottomLayoutLength;

    CGRect topLineViewFrame = self.topLineView.frame;
    if (topLineViewFrame.origin.y != top+1)
    {
        topLineViewFrame = CGRectMake(0, top+1, w, 40);
        self.topLineView.frame = topLineViewFrame;
    }
    CGRect bottomLineViewFrame = self.bottomLineView.frame;
    if (bottomLineViewFrame.origin.y != (h-bottom-40-1))
    {
        bottomLineViewFrame = CGRectMake(0, h-bottom-40-1, w, 40);
        self.bottomLineView.frame = bottomLineViewFrame;
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
- (void)viewsLayoutInit
{
//    [self.view addSubview:self.textLabel];
//    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//    }];
    [self.view addSubview:self.topSeparateLineView];
    [self.view addSubview:self.topLineView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.button];
    [self.view addSubview:self.bottomLineView];
    [self.view addSubview:self.bottomSeparateLineView];

    self.button.backgroundColor = [UIColor yellowColor];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.width.height.mas_equalTo(16);
    }];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.centerX.equalTo(self.view.mas_centerX);
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
    NSLog(@">>>>>>");
    NSLog(@"keyPath:%@",keyPath);
    NSLog(@"object:%@",object);
    NSLog(@"change:%@",change);
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = [UIScreen mainScreen].bounds.size.height;
    UIEdgeInsets safeAreaInset = ((NSValue *)[change objectForKey:NSKeyValueChangeNewKey]).UIEdgeInsetsValue;
    CGFloat top = safeAreaInset.top;
    CGFloat bottom = safeAreaInset.bottom;

    CGRect topLineViewFrame = self.topLineView.frame;
    if (topLineViewFrame.origin.y != top+1)
    {
        topLineViewFrame = CGRectMake(0, top+1, w, 40);
        self.topLineView.frame = topLineViewFrame;
    }
    CGRect bottomLineViewFrame = self.bottomLineView.frame;
    if (bottomLineViewFrame.origin.y != (h-bottom-40-1))
    {
        bottomLineViewFrame = CGRectMake(0, h-bottom-40-1, w, 40);
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
