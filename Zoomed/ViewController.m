//
//  ViewController.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import "ViewController.h"
#import "Masonry.h"
#import "AFNetworking.h"
//#import "UIImageView+AFNetworking.h"
#import "ScreenBoundsPrint.h"
#import <objc/runtime.h>
#import "PrivateImage.h"
#import "PrivateConstString.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;

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
    self.safeAreaBlock = nil;
}

#pragma mark -
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *))
    {
    }
    else
    {
        if (self.safeAreaBlock)
        {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            CGFloat topLayoutLength = self.topLayoutGuide.length;
            CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
#pragma clang diagnostic pop
            CGFloat w = [UIScreen mainScreen].bounds.size.width;
            CGFloat h = [UIScreen mainScreen].bounds.size.height;
            CGFloat top = topLayoutLength;
            CGFloat bottom = bottomLayoutLength;
            NSLog(@"topLayoutGuide top:%f,bottomLayoutGuide bottom:%f",top,bottom);
            self.safeAreaBlock(top, bottom, w, h, 0, 0);
        }
    }
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    if (@available(iOS 11.0, *))
    {
        if (self.safeAreaBlock)
        {
            CGFloat w = [UIScreen mainScreen].bounds.size.width;
            CGFloat h = [UIScreen mainScreen].bounds.size.height;
            UIEdgeInsets safeAreaInset = self.view.safeAreaInsets;
            CGFloat top = safeAreaInset.top;
            CGFloat bottom = safeAreaInset.bottom;
            NSLog(@"safeAreaInsets top:%f,bottom:%f",top,bottom);
            self.safeAreaBlock(top, bottom, w, h, 0, 0);
        }
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
    [self.view addSubview:self.textLabel];
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.leading.equalTo(self.view).offset(10);
        make.trailing.equalTo(self.view).offset(-10);
//        make.topMargin.equalTo(self.view).offset(10);
//        make.bottomMargin.equalTo(self.view).offset(10);
    }];
    [self.view addSubview:self.topSeparateLineView];
    [self.view addSubview:self.topLineView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.bottomLineView];
    [self.view addSubview:self.bottomSeparateLineView];

//    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//        make.width.height.mas_equalTo(16);
//    }];
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
