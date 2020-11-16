//
//  AViewController.m
//  Zoomed
//
//  Created by jungao on 2020/11/13.
//

#import "AViewController.h"
#import "Masonry.h"
#import "ViewController+Private.h"
#import "BViewController.h"

@interface AViewController ()
@property (nonatomic, strong) UIButton *button;
@end

@implementation AViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewsLayoutInit];

    __weak typeof(self) weakSelf = self;
    self.safeAreaBlock = ^(CGFloat topSafeHeight, CGFloat bottomSafeHeight, CGFloat screenWidth, CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight) {
        CGRect topLineViewFrame = weakSelf.topLineView.frame;
        if (topLineViewFrame.origin.y != topSafeHeight+1)
        {
            topLineViewFrame = CGRectMake(0, topSafeHeight+1, screenWidth, 40);
            weakSelf.topLineView.frame = topLineViewFrame;
        }
        CGRect bottomLineViewFrame = weakSelf.bottomLineView.frame;
        if (bottomLineViewFrame.origin.y != (screenHeight-bottomSafeHeight-40-1))
        {
            bottomLineViewFrame = CGRectMake(0, screenHeight-bottomSafeHeight-40-1, screenWidth, 40);
            weakSelf.bottomLineView.frame = bottomLineViewFrame;
        }
    };
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
//{
//    NSLog(@"class name:%@",NSStringFromClass([self class]));
//}

#pragma mark - views layout init
- (void)viewsLayoutInit
{
    [self.view addSubview:self.button];
    self.button.backgroundColor = [UIColor yellowColor];

    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
}

#pragma mark - buttons actions
- (void)buttonAction:(UIButton *)sender
{
    BViewController *a = [[BViewController alloc] init];
    a.title = self.title;
    a.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:a animated:YES];
}

#pragma mark - property
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
