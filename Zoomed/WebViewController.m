//
//  WebViewController.m
//  Zoomed
//
//  Created by jungao on 2021/12/23.
//

#import "WebViewController.h"

#import "Masonry.h"
#import <WebKit/WebKit.h>

@interface WebViewController ()

@property (nonatomic, strong, nullable) WKWebView *webView;
@property (nonatomic, strong) UIButton *buttonA;
@property (nonatomic, strong) UIButton *buttonB;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.webView];
    [self.view addSubview:self.buttonA];
    [self.view addSubview:self.buttonB];

    [self.buttonA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.leading.equalTo(self.view.mas_leading).offset(0);
        make.width.equalTo(self.view.mas_width).dividedBy(2.0);
    }];

    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.bottomMargin.left.equalTo(self.view);
        make.top.equalTo(self.buttonA.mas_bottom).offset(10);
    }];

    [self.buttonB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.trailing.equalTo(self.view.mas_trailing).offset(0);
        make.width.equalTo(self.view.mas_width).dividedBy(2.0);
    }];

    self.buttonA.backgroundColor = [UIColor yellowColor];
    self.webView.backgroundColor = [UIColor lightGrayColor];
    self.buttonB.backgroundColor = [UIColor orangeColor];
}

#pragma mark - buttons actions
- (void)buttonActionA:(UIButton *)sender
{
    /// reload
    NSURL *url = [NSURL URLWithString:@"https://apps.apple.com"];
    NSURLRequest *r = [[NSURLRequest alloc] initWithURL:url];
    [self.webView loadRequest:r];
}

- (void)buttonActionB:(UIButton *)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - property
- (WKWebView *)webView
{
    if (!_webView)
    {
        _webView = [[WKWebView alloc] init];
    }
    return _webView;
}

- (UIButton *)buttonA
{
    if (!_buttonA)
    {
        _buttonA = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonA addTarget:self action:@selector(buttonActionA:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonA setTitle:@"A按钮" forState:UIControlStateNormal];
        [_buttonA setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonA setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    }
    return _buttonA;
}

- (UIButton *)buttonB
{
    if (!_buttonB)
    {
        _buttonB = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonB addTarget:self action:@selector(buttonActionB:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonB setTitle:@"B按钮" forState:UIControlStateNormal];
        [_buttonB setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonB setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    }
    return _buttonB;
}

@end
