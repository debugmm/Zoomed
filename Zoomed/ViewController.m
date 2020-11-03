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

@interface ViewController ()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *button;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self viewsLayoutInit];
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
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.button];

    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.equalTo(self.view).offset(10);
        make.trailing.equalTo(self.view).offset(-10);
        make.bottomMargin.equalTo(self.view.mas_bottomMargin).offset(-10);
//        make.height
    }];
    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.topMargin.equalTo(self.view.mas_topMargin).offset(10);
        make.topMargin.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(10);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - buttons actions
- (void)buttonAction:(UIButton *)sender
{
    [self.imageView setImageWithURL:[NSURL URLWithString:@"https://wx3.sinaimg.cn/large/49535fefly1fj72buwho5j21hc0u00xy.jpg"]];
}

#pragma mark -
- (UIImageView *)imageView
{
    if (!_imageView)
    {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
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

@end
