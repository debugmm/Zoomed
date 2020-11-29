//
//  TestViewController.m
//  Zoomed
//
//  Created by jungao on 2020/11/13.
//

#import "TestViewController.h"
#import "ViewController+Private.h"
#import "NavigationController.h"
#import "Masonry.h"
#import "AViewController.h"
#import "AFNetworking.h"

@interface TestViewController () <NSURLSessionDataDelegate>
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIImageView *imageV;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self viewsLayoutInit];

    __weak typeof(self) weakSelf = self;
    self.safeAreaBlock = ^(CGFloat topSafeHeight, CGFloat bottomSafeHeight, CGFloat screenWidth, CGFloat screenHeight,CGFloat vcViewWidth,CGFloat vcViewHeight) {
        NSLog(@"topSafeHeight:%f,bottomSafeHeight:%f,screenWidth:%f,screenHeight:%f,vcViewWidth:%f,vcViewHeight:%f",topSafeHeight,bottomSafeHeight,screenWidth,screenHeight,vcViewWidth,vcViewHeight);
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
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

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
    [self.view addSubview:self.button];
    self.button.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.imageV];

    [self.button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.centerX.equalTo(self.view.mas_centerX);
    }];
    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
}

#pragma mark - buttons actions
- (void)buttonAction:(UIButton *)sender
{
//    AViewController *a = [[AViewController alloc] init];
//    a.title = self.title;
//    a.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:a animated:YES];
    ///
    AFHTTPSessionManager *mg = [AFHTTPSessionManager manager];
    //配置responseSerializer
    AFJSONResponseSerializer *json = [AFJSONResponseSerializer serializer];
    AFXMLParserResponseSerializer *xml = [AFXMLParserResponseSerializer serializer];
    AFPropertyListResponseSerializer *plist = [AFPropertyListResponseSerializer serializer];
    AFImageResponseSerializer *imageR = [AFImageResponseSerializer serializer];
    NSArray<AFHTTPResponseSerializer *> *responseSerializers = @[
                                json,
                                xml,
                                plist,
                                imageR
                                ];
    AFCompoundResponseSerializer *compoundResponseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];

    mg.responseSerializer = compoundResponseSerializer;
    [mg GET:@"https://wx3.sinaimg.cn/webp180/006B10qVly1ggibdcpdfqj32c0340qv6.jpg" parameters:nil headers:nil progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"");
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"responseObject");
            self.imageV.image = responseObject;
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"error:%@",error);
        }];
    ///
    //确定请求路径
//     NSURL *url = [NSURL URLWithString:@"https://wx3.sinaimg.cn/webp180/006B10qVly1ggibdcpdfqj32c0340qv6.jpg"];
////     创建可变请求对象
//     NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
////     设置请求方法
//     requestM.HTTPMethod = @"GET";
//    [requestM addValue:@"image/webp" forHTTPHeaderField:@"Accept"];
////     设置请求体
////     requestM.HTTPBody = [@"username=520&pwd=520&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
////     创建会话对象，设置代理
//     /**
//      第一个参数：配置信息
//      第二个参数：设置代理
//      第三个参数：队列，如果该参数传递nil 那么默认在子线程中执行
//      */
//     NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
//                                  delegate:self delegateQueue:self.operationQueue];
//     //创建请求 Task
//     NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:requestM];
//     //发送请求
//     [dataTask resume];
}

#pragma mark - NSURLSessionDataDelegate
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
    NSLog(@"didReceiveResponse");
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
 willCacheResponse:(NSCachedURLResponse *)proposedResponse
 completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
{
    completionHandler(proposedResponse);
}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
    NSLog(@"didReceiveData");
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

- (UIImageView *)imageV
{
    if (!_imageV)
    {
        _imageV = [[UIImageView alloc] init];
    }
    return _imageV;
}

- (NSOperationQueue *)operationQueue
{
    if (!_operationQueue)
    {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

@end
