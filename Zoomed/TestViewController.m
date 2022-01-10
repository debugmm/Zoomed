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
#import "WBInternalHttpManager.h"
#import "WBInternalTask.h"
#import "WBInternalDataTask.h"

#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <string.h>
#include <arpa/inet.h>

#import "Person.h"
#import "Person+Private.h"

#import <sys/param.h>
#import <sys/mount.h>

#import <NetworkExtension/NEHotspotNetwork.h>
#import <CoreLocation/CoreLocation.h>

#import <SystemConfiguration/CaptiveNetwork.h>

#import "Zoomed-Swift.h"

#import <AssertMacros.h>

#import "fishhook.h"
#include <dlfcn.h>
#include <dns_sd.h>

/// ip
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <sys/socket.h>
#include <resolv.h>
#include <dns.h>
#import <sys/sysctl.h>
#import <netinet/in.h>
#import <mach/mach.h>
#import <mach/task.h>
#import <net/if.h>
#import "UIView+Border.h"

#import "WBXIndicatorView.h"

#import "RoutingHTTPServer.h"

#import "WBXSliderView.h"

#import "WebViewController.h"

#define IOS_CELLULAR    @"pdp_ip0" //蜂窝网络
#define IOS_WIFI        @"en0" //Wi-Fi
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

/// define
/// pa，为path abtest key缩写
NSString * const WBIABTInterceptPathKey = @"ios_nn_";
NSString * const WBIABTInterceptPathEmptyValue = @"ios_nn";

@interface WBILogInfo : NSObject

@property (nonatomic, strong, nullable) NSMutableDictionary<NSString *,id> *logInfo;

@end
@implementation WBILogInfo

- (instancetype)init
{
    self = [super init];
    if (!self) return nil;
    self.logInfo = [[NSMutableDictionary alloc] init];
    return self;
}

@end

typedef void (^TestNilBlock)(void);

static dispatch_group_t url_session_manager_completion_group() {
    static dispatch_group_t af_url_session_manager_completion_group;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        af_url_session_manager_completion_group = dispatch_group_create();
    });

    return af_url_session_manager_completion_group;
}


static BOOL AFServerTrustIsValid(SecTrustRef serverTrust) {
    BOOL isValid = NO;
    SecTrustResultType result;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    __Require_noErr_Quiet(SecTrustEvaluate(serverTrust, &result), _out);
#pragma clang diagnostic pop

    isValid = (result == kSecTrustResultUnspecified || result == kSecTrustResultProceed);

_out:
    return isValid;
}

#pragma mark - dns

static DNSServiceErrorType(*orig_DNSServiceGetAddrInfo)(DNSServiceRef *,DNSServiceFlags,uint32_t,DNSServiceProtocol,const char *,DNSServiceGetAddrInfoReply,void *);

DNSServiceErrorType my_DNSServiceGetAddrInfo(DNSServiceRef *sdRef, DNSServiceFlags flags, uint32_t interfaceIndex, DNSServiceProtocol protocol, const char *hostname, DNSServiceGetAddrInfoReply callBack, void *context){
//    RRTask *task = [[RRNetWorkManager shareWorkManager] currentTask];
    //还在想办法解决   RRTask 和  该 DNS 的对应关系

    //DNS 解析开始
    if(context){
//        id con = (__bridge id)(context);
//        AddrInfoReply  *reply = [[AddrInfoReply alloc]init];
//        reply->info =  callBack;
//        objc_setAssociatedObject(con, "AddrInfoReply", reply, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        return orig_DNSServiceGetAddrInfo(sdRef,flags,interfaceIndex,protocol,hostname,callBack,context);;
    }
    return orig_DNSServiceGetAddrInfo(sdRef,flags,interfaceIndex,protocol,hostname,callBack,context);;
}

//static int (*origin_getaddrinfo)(const char * __restrict, const char * __restrict,const struct addrinfo * __restrict, struct addrinfo ** __restrict);
//int my_getaddrinfo(const char *a, const char *b, const struct addrinfo *c, struct addrinfo **d)
//{
//    //DNS解析开始
//    int result = origin_getaddrinfo(a,b,c,d);
//    //DNS解析结束
//    return result;
//}

#pragma mark -

@interface TestViewController () <NSURLSessionDataDelegate,NSURLSessionStreamDelegate,CLLocationManagerDelegate>
@property (nonatomic, strong) UIButton *buttonA;
@property (nonatomic, strong) UIButton *buttonB;
@property (nonatomic, strong) UIButton *buttonC;
@property (nonatomic, strong) UIButton *buttonD;
@property (nonatomic, strong) UIButton *buttonE;
@property (nonatomic, strong) UIButton *buttonF;
@property (nonatomic, strong) WBXIndicatorView *indicatorView;
@property (nonatomic, strong) WBXSliderView *slider;

@property (nonatomic, strong) UIImageView *imageV;
@property (readwrite, nonatomic, strong) NSOperationQueue *operationQueue;

@property (nonatomic, copy) TestNilBlock tnilBlock;
@property (nonatomic, copy) TestNilBlock bnilBlock;

@property (nonatomic, strong) NSMutableString *as;
@property (nonatomic, strong) NSMutableString *bs;

@property (nonatomic, strong) Person *pa;
@property (nonatomic, strong) Person *pb;

@property (nonatomic, strong) UITextField *textfield;

@property (nonatomic, strong) WBInternalHttpManager *httpManager;

@property (nonatomic, strong) NSOperationQueue *oQueue;

@property (nonatomic, strong) NSMapTable *mapTable;

@property (nonatomic, strong) NSMutableArray<Person *> *persions;
@property (nonatomic, strong) dispatch_queue_t cachedOperationQueue;

@property (nonatomic, strong) WBInternalDataTask *dataTask;

@property (nonatomic, strong) NSURLSessionDataTask *sessionDataTask;

@property (nonatomic, strong) NEHotspotNetwork *wifiInfo;

@property (nonatomic, strong) NSMutableDictionary <NSString *,WBILogInfo *> *logInfo;

@property (nonatomic, strong) NSURLSession *session;

@property (nonatomic, strong) NSURLSessionStreamTask *streamTask;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSUserDefaults *u;

@property (nonatomic, strong) NSFileHandle *fileHandle;

@property (nonatomic, strong) NSSet <NSData *> *defaultPinnedCertificates;

@property (nonatomic, strong) UISwitch *switchView;

@property (nonatomic, strong) RoutingHTTPServer *httpServer;

@end

@implementation TestViewController

//+ (void)load
//{
//    static dispatch_once_t rebind;
//    dispatch_once(&rebind, ^{
////        void *lib = dlopen("/usr/lib/system/libsystem_info.dylib", RTLD_NOW);//libsystem_info.dylib libsystem_dnssd.dylib
////        orig_DNSServiceGetAddrInfo = dlsym(lib, "DNSServiceGetAddrInfo");
////        int result = rebind_symbols((struct rebinding[1]){{"DNSServiceGetAddrInfo",my_DNSServiceGetAddrInfo},},1);
//
//        origin_getaddrinfo = dlsym(RTLD_DEFAULT, "getaddrinfo");//dlsym(lib, "getaddrinfo");
//        struct rebinding getaddrinfoRebinding;//{"getaddrinfo", my_getaddrinfo, (void*)&origin_getaddrinfo};// {"getaddrinfo", my_getaddrinfo, (void*)&origin_getaddrinfo}
//        getaddrinfoRebinding.name = "getaddrinfo";
//        getaddrinfoRebinding.replacement = my_getaddrinfo;
//        getaddrinfoRebinding.replaced = (void *)&origin_getaddrinfo;
//        struct rebinding rebs[1] = {getaddrinfoRebinding};
//        int result = rebind_symbols(rebs, 1);
////        int result = rebind_symbols((struct rebinding[1]){getaddrinfoRebinding}, 1);
//        NSLog(@"");
////        dlclose(lib);
//    });
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.wifiInfo = [[NEHotspotNetwork alloc] init];

    NSInteger ccc = -1001;
    NSLog(@">>>%ld",ccc);

    [self viewsLayoutInit];
    [self dataInit];
    self.cachedOperationQueue = dispatch_queue_create("wbi.cached.network.status.listener.operation.queue", DISPATCH_QUEUE_CONCURRENT);
    self.persions = [[NSMutableArray alloc] init];
    self.logInfo = [[NSMutableDictionary alloc] init];
    ///
    [Person sharedManager].age = 21;
    [Person sharedManager].name = @"a";
    [Person sharedManager].height = 0;

    NSLog(@"baifen p:%p,%zx",self,self);
    NSTimeInterval timeInterval = [NSDate date].timeIntervalSince1970 * 1000;
    NSString *timeString = [NSString stringWithFormat:@"%.0f",timeInterval];
    NSLog(@"timeString:%@",timeString);
    NSLog(@"[NSThread currentThread]:%p",[NSThread currentThread]);
    //
//    self.streamTask = [self.session streamTaskWithHostName:@"2400:89c0:1013:3::17" port:443];// 2400:89c0:1013:3::17

    NSString *patchLog = @"UserLinkPageStartTime715,330,750__act    performance__dat1623311700_idYRLs9HkBNNCxqZBHC10q_indexlogstash-mweibo-client-performance-2021.06.10_score- _type_docagent_device_typeiPhone10,2agent_os_typeiphoneagent_os_versionos13.5agent_weibo_version11.6.1aid01A6fLjlTf2cPSveCPbObt-sq9ywsFGGTcBmfrz28RWizUmyo.client_from10B6193010create_time1,623,311,684,917error_branchidB61_storyPublishfid102803from10B6193010geoip.city长沙geoip.country中国geoip.isp电信geoip.province湖南gray_typeoriginalhostlogservice-tcp-7d4877cf48-z82drip175.8.66.50launchid10000365-xnet_time0network_typewifinetworktypewifiprogramnamemweibo_client_performancesubtypepatch_resultsuccesstrueuicode10000511uid2002886285025ul_hid77DEA3D3E1F8-41B2-90DD-62C7BF84C57Ful_sidC53FD917-ECD7-4A8C-96D1-91DBCBFFCB7Fwm3333_2001";
    NSData *data = [patchLog dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"patchLog.size:%lu",data.length);

    /// locationManager
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 1;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;//kCLLocationAccuracyBest;// kCLLocationAccuracyHundredMeters;

//    [WBIDNSOverHttps handleTLSWithAllowInsecure:YES];
    self.defaultPinnedCertificates = [self.class certificatesInBundle:[NSBundle mainBundle]];

    [self configHttpServer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleDarkContent;
}

- (BOOL)prefersStatusBarHidden
{
    return NO;
}

#pragma mark - http server
- (void)configHttpServer
{
    NSDictionary *bundleInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [bundleInfo objectForKey:@"CFBundleShortVersionString"];
    if (!appVersion) {
        appVersion = [bundleInfo objectForKey:@"CFBundleVersion"];
    }
    NSString *serverHeader = [NSString stringWithFormat:@"%@/%@",
                              [bundleInfo objectForKey:@"CFBundleName"],
                              appVersion];
    [self.httpServer setDefaultHeader:@"Server" value:serverHeader];

    [self setupRoutes];
    [self.httpServer setPort:443];
    
    [self.httpServer setDocumentRoot:NSTemporaryDirectory()];//[@"~/Sites" stringByExpandingTildeInPath]];

    NSError *error;
    if (![self.httpServer start:&error]) {
        NSLog(@"Error starting HTTP server: %@", error);
    }
}

- (void)setupRoutes {
    [self.httpServer get:@"/hello" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response respondWithString:@"Hello!"];
    }];

    [self.httpServer get:@"/hello/:name" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response respondWithString:[NSString stringWithFormat:@"Hello %@!", [request param:@"name"]]];
    }];

    [self.httpServer get:@"{^/page/(\\d+)}" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response respondWithString:[NSString stringWithFormat:@"You requested page %@",
                                     [[request param:@"captures"] objectAtIndex:0]]];
    }];

    [self.httpServer post:@"/widgets" withBlock:^(RouteRequest *request, RouteResponse *response) {
        // Create a new widget, [request body] contains the POST body data.
        // For this example we're just going to echo it back.
        [response respondWithData:[request body]];
    }];

    //dns-query
    [self.httpServer get:@"/dns-query" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response respondWithString:@"dns-query"];
    }];
    [self.httpServer post:@"/dns-query" withBlock:^(RouteRequest *request, RouteResponse *response) {
        [response respondWithData:[request body]];
    }];

    // Routes can also be handled through selectors
    [self.httpServer handleMethod:@"GET" withPath:@"/selector" target:self selector:@selector(handleSelectorRequest:withResponse:)];
}

- (void)handleSelectorRequest:(RouteRequest *)request withResponse:(RouteResponse *)response {
    [response respondWithString:@"Handled through selector"];
}

#pragma mark - kvo

#pragma mark - views layout init
- (void)viewsLayoutInit
{
    self.buttonA.backgroundColor = [UIColor yellowColor];
    self.buttonB.backgroundColor = [UIColor orangeColor];
    self.buttonC.backgroundColor = [UIColor greenColor];
    self.buttonD.backgroundColor = [UIColor yellowColor];
    self.buttonE.backgroundColor = [UIColor orangeColor];
    self.buttonF.backgroundColor = [UIColor greenColor];
    self.indicatorView.backgroundColor = [UIColor blueColor];
    self.slider.minimumTrackTintColor = [UIColor greenColor];
    self.slider.maximumTrackTintColor = [UIColor yellowColor];

    [self.view addSubview:self.buttonA];
    [self.view addSubview:self.buttonB];
    [self.view addSubview:self.buttonC];
    [self.view addSubview:self.buttonD];
    [self.view addSubview:self.buttonE];
    [self.view addSubview:self.buttonF];
    [self.view addSubview:self.switchView];
    [self.view addSubview:self.indicatorView];
    [self.view addSubview:self.slider];

    self.textLabel.backgroundColor = [UIColor greenColor];
//    [self.view addSubview:self.imageV];
//    [self.view addSubview:self.textfield];
//    self.textfield.enabled = NO;

    [self.buttonA mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.leading.equalTo(self.view.mas_leading).offset(0);
        make.width.equalTo(self.view.mas_width).dividedBy(2.0);
    }];
    [self.buttonB mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_topMargin);
        make.trailing.equalTo(self.view.mas_trailing).offset(0);
        make.width.equalTo(self.view.mas_width).dividedBy(2.0);
    }];
    [self.buttonC mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.buttonB.mas_bottom).offset(20);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];

    [self.buttonD mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.buttonC.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];
    [self.buttonE mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.buttonD.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];
    [self.buttonF mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.buttonE.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(100);
    }];
    [self.switchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.buttonF.mas_bottom).offset(10);
        make.width.mas_equalTo(50);
        make.height.mas_equalTo(50);
    }];
    [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.switchView.mas_bottom).offset(10);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(20);
    }];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.indicatorView.mas_bottom).offset(10);
        make.width.mas_equalTo(300);
        make.height.mas_equalTo(15);
    }];
//    [self.imageV mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.center.equalTo(self.view);
//    }];
//    [self.textfield mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.equalTo(self.view).offset(10);
//        make.trailing.equalTo(self.view).offset(-10);
//        make.top.equalTo(self.button.mas_bottom).offset(15);
////        make.bottom.equalTo(self.bottomLineView.mas_top).offset(0);
//    }];
}

- (void)dataInit
{
    self.mapTable = [[NSMapTable alloc] initWithKeyOptions:NSMapTableStrongMemory
                                              valueOptions:NSMapTableStrongMemory
                                                  capacity:1];
    self.oQueue = [[NSOperationQueue alloc] init];
    self.oQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
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

    self.tnilBlock = ^{
        NSLog(@"init tnilBlock");
    };
    self.bnilBlock = self.tnilBlock;

    self.as = [[NSMutableString alloc] initWithString:@"as"];
    self.bs = self.as;
}

//int * intPointV(void)
//{
//    int a = 1;
//    return &a;
//}

- (void)getSignalStrength{

    NSInteger majorVersion = [NSProcessInfo processInfo].operatingSystemVersion.majorVersion;
    if (majorVersion <= 12)
    {
        UIApplication *app = [UIApplication sharedApplication];
        UIView *statusBar = [[app valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
        NSArray *subviews = [[[app valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
        NSString *dataNetworkItemView = nil;
        for (id subview in subviews) {
            if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
                dataNetworkItemView = subview;
                break;
            }
        }
        int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
        NSLog(@"signal %d", signalStrength);
    }

/// 
    if (@available(iOS 14.0, *)) {
        [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
            NSLog(@">>signalStrength %f,SSID %@",currentNetwork.signalStrength,currentNetwork.SSID);
        }];
    } else {
        // Fallback on earlier versions
    }
}

#pragma mark - buttons actions
- (void)buttonActionA:(UIButton *)sender
{
    /// 设置DoH
    [WBIDNSOverHttps configAllLinkInAppDoH];
}

- (void)buttonActionB:(UIButton *)sender
{
    [WBIDNSOverHttps configAllLinkInAppDoHNormal];
}

- (void)buttonActionC:(UIButton *)sender
{
    [WBIDNSOverHttps configAllLinkInAppDoHAndLocalDNS];
}

- (void)buttonActionD:(UIButton *)sender
{
//    [self localDNSResolve];
    [self wifiInfo];
}

- (void)buttonActionE:(UIButton *)sender
{
//    [self localDNSResolveGethostbyname];
    [self ipInfo];

}

- (void)buttonActionF:(UIButton *)sender
{
//    [self localDNSResolveByCFHostStartInfoResolution];
//    NSURL *url = nil;
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
//    NSLog(@"");
//    WebViewController *webVC = [[WebViewController alloc] init];
//    [self.navigationController pushViewController:webVC animated:YES];
//    NSLog(@"local dns ip info:%@",[self wbt_getDNSServers]);
    [self getdnssvraddrs];
}

- (void)checkChanged:(UISwitch *)sender
{
    [self testSessionTaskBackgroundState];
//    NSString *decodeBase64 = [self base64Dencode:@"AAABAAABAAAAAAABDDFjaHVpZGluZ3lpbgNjb20AAEEAAQAAKQIAAAAAAABTAAwATwAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"];
    NSLog(@"");
}

#pragma mark - localDNS
/// 可以通过清空缓存，以及配置文件，走localdns查询
- (void)localDNSResolveByCFHostStartInfoResolution
{
    Boolean result,bResolved;
    CFHostRef hostRef;
    CFArrayRef addresses = NULL;

    CFStringRef hostNameRef = CFStringCreateWithCString(kCFAllocatorDefault, "api.weibo.cn", kCFStringEncodingASCII);

    hostRef = CFHostCreateWithName(kCFAllocatorDefault, hostNameRef);
    CFStreamError *er = nil;
    if (hostRef)
    {
        result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, er);
        if (result == TRUE)
        {
            addresses = CFHostGetAddressing(hostRef, &result);
        }
    }

    bResolved = result == TRUE ? true : false;
    NSMutableArray * ips = [NSMutableArray array];

    if(bResolved)
    {
        struct sockaddr_in* remoteAddr;
        for(int i = 0; i < CFArrayGetCount(addresses); i++)
        {
            CFDataRef saData = (CFDataRef)CFArrayGetValueAtIndex(addresses, i);
            remoteAddr = (struct sockaddr_in*)CFDataGetBytePtr(saData);

            if(remoteAddr != NULL)
            {
                //获取IP地址
                char ip[16];
                strcpy(ip, inet_ntoa(remoteAddr->sin_addr));
                [ips addObject:[NSString stringWithCString:ip]];
            }
        }
    }
    CFRelease(hostNameRef);
    CFRelease(hostRef);
    NSLog(@"ips:%@",ips);
    NSLog(@"er:%@",er);
}

- (void)localDNSResolveGethostbyname
{
    NSMutableArray * ips = [NSMutableArray array];
    NSString *domain = @"api.weibo.cn";
    struct hostent *hostent = gethostbyname(domain.UTF8String);
    if(hostent == NULL)
    {
            return;
    }

    char **pptr;
    char str[32];

    for(pptr=hostent->h_addr_list; *pptr!=NULL; pptr++)
    {
         NSString * ipStr = [NSString stringWithCString:inet_ntop(hostent->h_addrtype, *pptr, str, sizeof(str)) encoding:NSUTF8StringEncoding];
         [ips addObject:ipStr?:@""];
    }
    NSLog(@"ips:%@",ips);
}

- (void)localDNSResolve
{
    NSString *domain = @"api.weibo.cn";
    struct addrinfo hints;
    memset(&hints, 0, sizeof(hints));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    struct addrinfo *addrs, *addr;

    int getResult = getaddrinfo([domain UTF8String], NULL, &hints, &addrs);
    if (getResult || addrs == nil)
    {
        NSLog(@"Warn: DNS with domain:%@ failed:%d", domain, getResult);
        return;
    }

    addr = addrs;
    NSMutableArray *result = [NSMutableArray array];
    for (addr = addrs; addr; addr = addr->ai_next)
    {
        char host[NI_MAXHOST];
        memset(host, 0, NI_MAXHOST);
        getnameinfo(addr->ai_addr, addr->ai_addrlen, host, sizeof(host), NULL, 0, NI_NUMERICHOST);
        if (strlen(host) != 0)
        {
            [result addObject:[NSString stringWithUTF8String:host]];
        }
    }
    freeaddrinfo(addrs);
    NSLog(@"Info: DNS with domain:%@ -> %@", domain, result);
//    return result;

//    NSString *domain = @"api.weibo.cn";
//    struct addrinfo* ai = NULL;
//    struct addrinfo* curr = NULL;
//    struct addrinfo hints = {0};
//    //char ipstr[16];
//    bzero(&hints, sizeof(hints));
//    hints.ai_family = AF_UNSPEC;
//    hints.ai_socktype = SOCK_STREAM;
//
//    long start = time(NULL);
//    int ret = getaddrinfo(domain.cString, "80", &hints, &ai);
//    NSLog(@"");
//
//    if (ret != 0 || ai == NULL)
//    {
//        if(ai != NULL)
//        {
//            freeaddrinfo(ai);
//            ai = NULL;
//        }
//        NSLog(@"getaddrinfo: %s\n",gai_strerror(ret));
//        return;
//    }
//    if(ai->ai_addr == NULL)
//    {
//        freeaddrinfo(ai);
//        ai = NULL;
//        NSLog(@"");
//        return;
//    }
//
//    for (curr = ai; curr != NULL; curr = curr->ai_next)
//    {
//        if (PF_INET != curr->ai_family && PF_INET6 != curr->ai_family)
//        {
//            continue;
//        }
//
//        struct sockaddr_in* addr_in = (struct sockaddr_in*)curr->ai_addr;
//        struct in_addr convertAddr;
//
//        // In Indonesia, if there is no ipv6's ip, operators return 0.0.0.0.
//        if (INADDR_ANY == addr_in->sin_addr.s_addr || INADDR_NONE == addr_in->sin_addr.s_addr) {
//            continue;
//        }
//
//        convertAddr.s_addr = addr_in->sin_addr.s_addr;
//        const char* ip = socket_address(convertAddr).ip();
//
//        if (!socket_address(ip, 0).valid()) {
//            continue;
//        }
//
//        //inet_ntop(AF_INET, &(((struct sockaddr_in *)(curr->ai_addr))->sin_addr), ipstr, 16);
//
////        ip_entity* ip_entity_tmp = new ip_entity();
////        ip_entity_tmp->ip = ip;
////        ip_entity_tmp->ttl = 60;
////        ip_entity_tmp->priority = 0;
////        ip_entity_tmp->expiration_time_in_mills_ = ip_entity_tmp->ttl + time(NULL);
////        entity.ttl = max(entity.ttl,ip_entity_tmp->ttl);
////        entity.ip_entity_list->push_back(ip_entity_tmp);
////        LOGD("system_host_resolver,ip:%s\n", ip);
////
////        entity.fill_type = FROM_SYSTEM;
////        success = true;
//    }
//
////    if(!success){
////        record_error_log(domain,"[system]can't resolve ip!");
////    }
//
//    freeaddrinfo(ai);
//    ai = NULL;
}

#pragma mark - convert path to ab
- (void)printABPaths
{
    NSArray<NSString *> *originPaths = [[self pathsString] componentsSeparatedByString:@","];
    NSMutableArray<NSString *> *paths = [originPaths mutableCopy];
    NSMutableArray<NSString *> *abs = [[NSMutableArray alloc] init];
    NSMutableDictionary<NSString *,NSString *> *abPaths = [[NSMutableDictionary alloc] init];
    for (NSString *path in originPaths) {
        NSString *abPath = [self convertPathToABTKey:path];
        [paths removeObject:path];
        [abs addObject:abPath];
        [abPaths setObject:abPath forKey:path];
    }
    NSLog(@"paths:%@",paths);
    NSLog(@"abs:%@",abs);
    NSLog(@"abPaths:%@",abPaths);
}

- (nonnull NSString *)convertPathToABTKey:(nonnull NSString *)path
{
    if ([self isEmptyString:path]) return @"";
    NSMutableString *abtkey = [[NSMutableString alloc] init];
    [abtkey appendString:WBIABTInterceptPathKey];
    NSArray<NSString *> *paths = [path componentsSeparatedByString:@"/"];
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![self isEmptyString:obj] &&
            ![obj isEqualToString:@"!"])
        {
            [abtkey appendFormat:@"%@_",obj];
        }
    }];
    /// 移除最后一个_
    path = [abtkey substringWithRange:NSMakeRange(0, abtkey.length -1)];
    if ([path isEqualToString:WBIABTInterceptPathEmptyValue]) return @"";
    return path;
}

- (NSString *)pathsString
{
    NSString *p = @"/2/page/get_bottom_panel,!/shop/wbpub_store_trend,pay/receipt,!/shop/wbpub_store_itemdesc,/2/stories/music_favorite,direct_messages/clear_public,guest/destroy,stories/segment_create,question/public_answer_check,/2/statuses/negative_filter,groups/update,qtcode/create,video/tiny_collection_list,video/playlist_delete,video/playlist_clear,search/followers,stories/challenge_search,account/car_update,gifimg/getmanagepkglist,/2/!/groupchat/destroy,video/see_later/list,users/attention,groupchat/admin_manage,stories/segment_delete,groups/members,stories/skin,statuses/tag_lists,stories/setting_get,!/account/block_word/delete,!/media/playlist_items/update_playlists,article/editable_check,/2/!/multimedia/dispatch,stories/like_set,/2/client/publisher_auth,!/place/delete_manyou_history,2/friendships/create_batch_all,article/history_cover,!/client/applet,video/redpacket,video/tiny_video_reward_user_list,groupchat/check_valid,users/verify_nickname,!/account/car_destroy,!/stories/bgm_favorite_create,health/weibo/checkin,article/edit_show,/2/groupchat/search,2/!/account/video_update_cover,!/groupchat/apply_admin,article/modify,video/see_later/add,/2/groupchat/query_active,video/tiny_profile_del_video_attitude,question/public_ask_send,!/users/write_play_time,guest/recommend_interesttags,stories/ars,/2/like/triple,!/groupchat/update_guest,video/tiny_profile_set_attitude_privacy,direct_messages/children_fangroup,client/share_cover,stories/like_unset,/2/!/fangle/create,!/multimedia/user/see_later/list_cluster,tag/delete,stories/share_weibo,!/shop/wbpub_store_addstore,direct_messages/set_props,!/groupchat/share,!/shop/cart_addgoods,video/tiny_music_header,/2/!/direct_messages/set_settings,!/multimedia/user/friendlike/block_friend,sdk/thumbtack_sticker_customize_add,friendships/bilateral,!/media/playlists/delete,!/groupchat/query_guest,captcha/sendcode,/2/messageflow/feedback,blocks/create,account/settings,!/multimedia/user/friendlike/unblock_friend,!/groupchat/sync_status_update,/2/!/messageblock/set_block_user,/2/client/chatpanel,!/media/basic_info/get,tag/recommend_user,!/multimedia/user/video/delete,stories/setting_set,/2/!/groupchat/batch_apply_check,friendships/top_create,!/stories/bgm_favorite_destroy,guest/recommend_interestusers,video/playlist_update,taobao/pushurl,!/st_videos/tiny/effect/update_prop_collection,health/user_set,reward/status_switch,users/callback_cover,statuses/article_delete,stories/content_check_valid";

    return p;
}

#pragma mark - DNS over Https

#pragma mark - 测试网络请求，app退到后台情况
- (void)testSessionTaskBackgroundState
{
//    dispatch_async(dispatch_get_main_queue(), ^{
    NSString *urlstring = @"https://apps.apple.com/cn/app/%E5%BE%AE%E5%8D%9A/id350962117";//@"https://127.0.0.1/dns-query";// 5.5.5.5 https://apps.apple.com @"";
        NSLog(@"异步调用网络请求开始");
        NSLog(@"fetch_start:%@",[NSDate date]);
        self.sessionDataTask = [self.session dataTaskWithURL:[NSURL URLWithString:urlstring]];
        [self.sessionDataTask resume];
//    });
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSLog(@"异步调用网络请求开始");
//        NSLog(@"fetch_start:%@",[NSDate date]);
//        NSString *urlstring = @"https://apps.apple.com/cn/app/%E5%BE%AE%E5%8D%9A/id350962117";
//        self.sessionDataTask = [self.session dataTaskWithURL:[NSURL URLWithString:urlstring]];
//        [self.sessionDataTask resume];
//    });
}

#pragma mark -
- (BOOL)isIPV6:(nonnull NSString *)ipv6
{
    return ([ipv6 containsString:@":"]);
}

#pragma mark - delete userdefault temp plist files
- (void)simulateUserdefaultMultiThreadOperation
{
    [self.operationQueue addOperationWithBlock:^{
        [self operationUserDefaults];
    }];
}

- (void)operationUserDefaults
{
    for (NSInteger i = 0; i < 100000; i++) {
        NSString *ppath = [self userdefaultPlistPath];
        NSData *pd = [NSData dataWithContentsOfFile:ppath];//[@"a" dataUsingEncoding:NSUTF8StringEncoding];//
        if (!pd)
        {
            NSLog(@"pd error");
            pd = [@"a" dataUsingEncoding:NSUTF8StringEncoding];
        }
        NSString *iKey = [NSString stringWithFormat:@"abcd%ld",i];
        [self.u setObject:pd forKey:iKey];

        BOOL syncResult = [self.u synchronize];
        if (!syncResult)
        {
            NSLog(@"syncResult:%d",syncResult);
        }
        NSLog(@"u sync count:%ld",i);
    }
}

- (NSString *)userdefaultPlistPath
{
    NSString *preferencesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences"];
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString *plistTempFileName = [NSString stringWithFormat:@"%@%@",bundleId,@".plist"];
    NSString *ppath = [preferencesPath stringByAppendingPathComponent:plistTempFileName];

    return ppath;
}

#pragma mark -
- (void)deleteUserDefaultTempPlistFiles
{
    NSString *preferencesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL fileExist = [fm fileExistsAtPath:preferencesPath isDirectory:&isDirectory];
    fileExist = (fileExist && isDirectory);
    if (!fileExist) return;
    NSURL *preferencesURL = [NSURL fileURLWithPath:preferencesPath];
    if (!preferencesURL) return;

    /// 获取userdefault plist文件名称
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    NSString *plistTempFileTag = [NSString stringWithFormat:@"%@%@",bundleId,@".plist."];

    /// 遍历文件列表
    NSInteger totalFiles = 0;
    NSInteger reserveFiles = 0;
    NSInteger deletedFailedFiles = 0;
    NSInteger errorCode = 0;

    unsigned long long totalFileSize = 0;
    unsigned long long deletedFileSize = 0;

    NSMutableDictionary *logDict = [[NSMutableDictionary alloc] init];

    NSDirectoryEnumerationOptions enumerationOptions = NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles;
    /// 开始遍历
    NSDirectoryEnumerator<NSURL *> *directoryEnumerator = [fm enumeratorAtURL:preferencesURL includingPropertiesForKeys:@[NSURLIsDirectoryKey,NSURLFileSizeKey] options:enumerationOptions errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
        return YES;
    }];
    for (NSURL *fileURL in directoryEnumerator)
    {
        @autoreleasepool
        {
            if (!fileURL || ![fileURL isKindOfClass:[NSURL class]]) break;

            /// 文件总数
            totalFiles++;

            NSNumber *isDirectory = nil;
            [fileURL getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
            NSNumber *ldeletedFileSize = nil;
            [fileURL getResourceValue:&ldeletedFileSize forKey:NSURLFileSizeKey error:nil];
            [fileURL removeAllCachedResourceValues];

            if (ldeletedFileSize)
            {
                totalFileSize += ldeletedFileSize.unsignedLongLongValue;
            }

            /// 不需要删除的
            if ((isDirectory && isDirectory.boolValue) ||
                ![fileURL.absoluteString containsString:plistTempFileTag])
            {
                /// 记录保留的plist文件名称
                NSString *reserveFileName = fileURL.lastPathComponent;
                if (reserveFileName)
                {
                    [logDict setObject:reserveFileName forKey:[NSString stringWithFormat:@"reserve_file_%ld",reserveFiles]];
                }
                reserveFiles++;
                continue;
            }

            /// 删除临时文件
            NSError *ler = nil;
            [fm removeItemAtURL:fileURL error:&ler];

            if (ldeletedFileSize && !ler)
            {
                deletedFileSize += ldeletedFileSize.unsignedLongLongValue;
            }
            if (ler)
            {
                deletedFailedFiles++;
                errorCode = ler.code;
            }
        }
    }

    /// 记录log
    [logDict setObject:@"preferences_temp_plist" forKey:@"sub_type"];
    [logDict setObject:[NSString stringWithFormat:@"%ld",totalFiles] forKey:@"total_files"];
    [logDict setObject:[NSString stringWithFormat:@"%ld",reserveFiles] forKey:@"reserve_files"];
    [logDict setObject:[NSString stringWithFormat:@"%ld",deletedFailedFiles] forKey:@"delete_failed_files"];
    [logDict setObject:[NSString stringWithFormat:@"%llu",totalFileSize] forKey:@"total_file_size"];
    [logDict setObject:[NSString stringWithFormat:@"%llu",deletedFileSize] forKey:@"deleted_file_size"];

    [logDict setObject:[NSString stringWithFormat:@"%ld",errorCode] forKey:@"delete_file_error_code"];

    NSLog(@"log:%@",logDict);
}

- (void)createTempPlistFiles
{
    static NSInteger tempPlistCount = 0;
    NSString *preferencesPath = [NSHomeDirectory() stringByAppendingPathComponent:@"Library/Preferences"];
    NSFileManager *fm = [NSFileManager defaultManager];
    BOOL isDirectory = NO;
    BOOL fileExist = [fm fileExistsAtPath:preferencesPath isDirectory:&isDirectory];
    fileExist = (fileExist && isDirectory);
    if (!fileExist) return;

    /// 获取userdefault plist文件名称
    NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
    for (NSInteger i = 0; i < 10000; i++) {
        tempPlistCount++;
        NSString *plistTempFileTag = [NSString stringWithFormat:@"%@/%@%@%ld",preferencesPath,bundleId,@".plist.test",tempPlistCount];
        [fm createFileAtPath:plistTempFileTag contents:[@"test preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist filetest preference dir temp plist file" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];

//        NSLog(@"create temp plist file result:%d",result);
//        NSLog(@"create temp plist file path:%@",plistTempFileTag);
    }
}

#pragma mark -
- (void)proxyInfo
{
    NSDictionary *d = CFBridgingRelease(CFNetworkCopySystemProxySettings());
    NSLog(@">>%@",d);
}

#pragma mark - disk
- (NSNumber *)freeDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    id obj = [fattributes objectForKey:NSFileSystemFreeSize];
    NSLog(@"freeDiskSpace:%@",obj);
    return obj;
}

- (NSNumber *)totalDiskSpace
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    id obj = [fattributes objectForKey:NSFileSystemSize];
    NSLog(@"totalDiskSpace:%@",obj);
    NSLog(@"home dir:%@",NSHomeDirectory());
    return obj;
}

- (long long)freeDiskSpaceInBytes
{
    struct statfs buf;
    long long freespace = -1;
    NSString *p = NSHomeDirectory();
    if(statfs(p.UTF8String, &buf) >= 0)
    {
        freespace = (long long)(buf.f_bsize * buf.f_bfree);/// f_bavail f_bfree
    }
    NSLog(@"freespace:%lld",freespace);
    NSLog(@"f_bsize:%u",buf.f_bsize);
    NSLog(@"f_fstypename:%s",buf.f_fstypename);
    NSLog(@"f_mntonname:%s",buf.f_mntonname);
    NSLog(@"f_mntfromname:%s",buf.f_mntfromname);
    return freespace;
}

#pragma mark -
- (void)testMapTable
{
    for (NSInteger i = 1; i < 1000000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"i:%ld",i);
            [self.oQueue addOperationWithBlock:^{
                [self.mapTable setObject:@(i) forKey:@(i)];
                NSLog(@"set %@",@(i));
            }];

        });
    }

    for (NSInteger i = 1; i < 1000000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"i:%ld",i);
            [self.oQueue addOperationWithBlock:^{
                NSLog(@"get %@",[self.mapTable objectForKey:@(i)]);
            }];
        });
    }

    for (NSInteger i = 1; i < 1000000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"i:%ld",i);
            [self.oQueue addOperationWithBlock:^{
                [self.mapTable removeObjectForKey:@(i)];
                NSLog(@"remove %@",@(i));
            }];

        });
    }
}

- (void)testSessionTask
{
    /// 确定请求路径
     NSURL *url = [NSURL URLWithString:@"https://wx3.sinaimg.cn/webp180/006B10qVly1ggibdcpdfqj32c0340qv6.jpg"];
    /// 创建可变请求对象
     NSMutableURLRequest *requestM = [NSMutableURLRequest requestWithURL:url];
    /// 设置请求方法
     requestM.HTTPMethod = @"GET";
    [requestM addValue:@"image/webp" forHTTPHeaderField:@"Accept"];
    /// 设置请求体
    /// requestM.HTTPBody = [@"username=520&pwd=520&type=JSON" dataUsingEncoding:NSUTF8StringEncoding];
    /// 创建会话对象，设置代理
     /**
      第一个参数：配置信息
      第二个参数：设置代理
      第三个参数：队列，如果该参数传递nil 那么默认在子线程中执行
      */
     NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:self delegateQueue:self.operationQueue];
     /// 创建请求 Task
     self.sessionDataTask = [session dataTaskWithRequest:requestM];
     /// 发送请求
     [self.sessionDataTask resume];
}

- (void)testMutableClass
{
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i < 100000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"a address:%p",a);
            NSLog(@"set value:%@",@(i));
            [a addObject:@(i)];
        });
    }

    for (NSInteger i = 1; i < 100000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"a address:%p",a);
            NSLog(@"remove value:%@",@(i));
            [a removeObject:@(i)];
        });
    }

    for (NSInteger i = 1; i < 100000; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"a address:%p",a);
            NSLog(@"get value:%@",[a objectAtIndex:i]);
        });
    }
}

- (void)testIsKindOf
{
    NSString *originContent = self.textLabel.text;
    BOOL result = [self isCPureInt:self.textfield.text];
    NSString *content = @"^[0－9]*$";
    content = [NSString stringWithFormat:@"%@\n%@测试结果:%d",originContent,content,result];
    self.textLabel.text = content;

    NSString *a = @"a";
    NSString *b = [[NSString alloc] initWithString:@"b"];
    NSString *c = [[NSString alloc] initWithFormat:@"c"];
    NSString *d = [[NSString alloc] initWithData:[NSData data] encoding:NSUTF8StringEncoding];
    NSLog(@"a:%@\nb:%@\nc:%@\nd:%@",a,b,c,d);

    if ([a isKindOfClass:[NSString class]]) NSLog(@"a isKindOf NSString class");
    if ([b isKindOfClass:[NSString class]]) NSLog(@"b isKindOf NSString class");
    if ([c isKindOfClass:[NSString class]]) NSLog(@"c isKindOf NSString class");
    if ([d isKindOfClass:[NSString class]]) NSLog(@"d isKindOf NSString class");
}

#pragma mark -
- (void)testSessionTaskA
{
//    NSString *urlstring = @"https://api.weibo.cn/2/!/groupchat/member_banned?gsid=_2A25y5FWbDeRxGeBO71EW9i_IyT2IHXVvsO5TrDV6PUJbkdANLVLWkWpNShYN-XdJfMtaxiE4rdXdwkMXCwUo8OfM&wm=3333_2001&launchid=10000365--x&b=0&from=10AC193010&c=iphone&networktype=wifi&v_p=86&skin=default&v_f=1&s=8b4d8ee5&lang=zh_CN&sflag=1&ua=x86_64__weibo__10.12.1__iphone__os14.2&ft=0&aid=01A_3gSy64uPgi9hcGygc28VtuNjAzkXTMrQSIub94OOVdtnE.&id=4546545846063627&operation=query&ul_ctime=1608603938384&cum=BAFB89FC";
    NSString *urlstring = @"https://apps.apple.com/cn/app/%E5%BE%AE%E5%8D%9A/id350962117";
    self.dataTask = [self.httpManager getWithURL:urlstring success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
        NSLog(@"success:%@",self.textfield);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
        NSLog(@"failure:%@",self.textfield);
     }];
    ///
}

- (void)testHttpManager
{
//https://api.weibo.cn/2/!/groupchat/member_banned?gsid=_2A25y5FWbDeRxGeBO71EW9i_IyT2IHXVvsO5TrDV6PUJbkdANLVLWkWpNShYN-XdJfMtaxiE4rdXdwkMXCwUo8OfM&wm=3333_2001&launchid=10000365--x&b=0&from=10AC193010&c=iphone&networktype=wifi&v_p=86&skin=default&v_f=1&s=8b4d8ee5&lang=zh_CN&sflag=1&ua=x86_64__weibo__10.12.1__iphone__os14.2&ft=0&aid=01A_3gSy64uPgi9hcGygc28VtuNjAzkXTMrQSIub94OOVdtnE.&id=4546545846063627&operation=query&ul_ctime=1608603938384&cum=BAFB89FC

//http://api.weibo.cn/2/!/groupchat/member_banned?gsid=_2A25y5FWbDeRxGeBO71EW9i_IyT2IHXVvsO5TrDV6PUJbkdANLVLWkWpNShYN-XdJfMtaxiE4rdXdwkMXCwUo8OfM&wm=3333_2001&launchid=10000365--x&b=0&from=10AC193010&c=iphone&networktype=wifi&v_p=86&skin=default&v_f=1&s=8b4d8ee5&lang=zh_CN&sflag=1&ua=x86_64__weibo__10.12.1__iphone__os14.2&ft=0&aid=01A_3gSy64uPgi9hcGygc28VtuNjAzkXTMrQSIub94OOVdtnE.&id=4546545846063627&operation=query&ul_ctime=1608604032041&cum=03911E67
    NSString *urlstring = @"https://api.weibo.cn/2/!/groupchat/member_banned?gsid=_2A25y5FWbDeRxGeBO71EW9i_IyT2IHXVvsO5TrDV6PUJbkdANLVLWkWpNShYN-XdJfMtaxiE4rdXdwkMXCwUo8OfM&wm=3333_2001&launchid=10000365--x&b=0&from=10AC193010&c=iphone&networktype=wifi&v_p=86&skin=default&v_f=1&s=8b4d8ee5&lang=zh_CN&sflag=1&ua=x86_64__weibo__10.12.1__iphone__os14.2&ft=0&aid=01A_3gSy64uPgi9hcGygc28VtuNjAzkXTMrQSIub94OOVdtnE.&id=4546545846063627&operation=query&ul_ctime=1608603938384&cum=BAFB89FC";

    for (NSInteger i = 1; i < 100; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"i:%ld",i);
            [self.oQueue addOperationWithBlock:^{
                [self.httpManager getWithURL:urlstring success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
                    NSLog(@"success");
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    NSLog(@"failure");
                 }];
            }];
        });
    }

    for (NSInteger i = 1; i < 100; i++) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSLog(@"i:%ld",i);
            [self.oQueue addOperationWithBlock:^{
                [self.httpManager getWithURL:urlstring success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
                    NSLog(@"success");
                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
                    NSLog(@"failure");
                 }];
            }];
        });
    }


//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        for (NSInteger i = 1; i < 3; i++) {
//            NSLog(@"i:%ld",i);
//            [self.oQueue addOperationWithBlock:^{
//                [self.httpManager getWithURL:urlstring success:^(NSURLSessionDataTask * _Nullable task, id  _Nullable responseObject) {
//                    NSLog(@"success");
//                } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
//                    NSLog(@"failure");
//                 }];
//            }];
//        }
//    });
}

#pragma mark -
- (void)jumpPage
{
    AViewController *a = [[AViewController alloc] init];
    a.title = self.title;
    a.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:a animated:YES];
}

- (void)testPure
{
    NSString *originContent = self.textLabel.text;
    BOOL result = [self isEPureInt:self.textfield.text];
    NSString *content = @"^[0-9]*$";
    content = [NSString stringWithFormat:@"%@\n%@测试结果:%d",originContent,content,result];
    self.textLabel.text = content;
}

#pragma mark -
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [manager stopUpdatingLocation];
}

#pragma mark - wifi info
- (NSDictionary *)wifiInfo
{
    NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
    NSDictionary *SSIDInfo = nil;
    for (NSString *interfaceName in interfaceNames) {
        SSIDInfo = CFBridgingRelease(
                                     CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
        BOOL isNotEmpty = (SSIDInfo.count > 0);
        if (isNotEmpty)
        {
            break;
        }
    }
    return SSIDInfo;
}

//+ (NSDictionary *)ipInfo
//{
//    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
//
//    // retrieve the current interfaces - returns 0 on success
//    struct ifaddrs *interfaces;
//    if(!getifaddrs(&interfaces)) {
//        // Loop through linked list of interfaces
//        struct ifaddrs *interface;
//        for(interface=interfaces; interface; interface=interface->ifa_next) {
//            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
//                continue; // deeply nested code harder to read
//            }
//            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
//            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
//            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
//                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
//                NSString *type = nil;
//                if(addr->sin_family == AF_INET) {
//                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv4;
//                    }
//                } else {
//                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
//                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
//                        type = IP_ADDR_IPv6;
//                    }
//                }
//                if(type) {
//                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
//                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
//                }
//            }
//        }
//        // Free memory
//        freeifaddrs(interfaces);
//    }
//    return [addresses count] ? addresses : nil;
//}

- (NSString *)wbt_getDNSServers
{
    NSMutableString *addresses = [[NSMutableString alloc] init] ;
    res_state res = malloc(sizeof(struct __res_state));
    int result = res_ninit(res);

    if (result == 0)
    {
        for (int i=0; i<res->nscount; i++)
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res->nsaddr_list[i].sin_addr)];
            [addresses appendFormat:@"%@ ",s];
        }
    }
    else
    {
        [addresses appendString:@"none"];
    }
    res_ndestroy(res);
    free(res);
    return addresses;
}

- (void)getdnssvraddrs
{
    struct __res_state stat = {0};
    res_ninit(&stat);
    union res_sockaddr_union addrs[MAXNS] = {0};
    int count = res_getservers(&stat, addrs, MAXNS);
    for (int i = 0; i < count; ++i) {
        if (AF_INET == addrs[i].sin.sin_family) {
            char addr[INET_ADDRSTRLEN];
            const char *aa = inet_ntop(AF_INET, &addrs[i].sin.sin_addr, addr, INET_ADDRSTRLEN);
            NSString *s = [NSString stringWithUTF8String:addr];
            NSString *bb = [NSString stringWithUTF8String:aa];
//            _dnssvraddrs.push_back(socket_address(addrs[i].sin));
            NSLog(@"ipv4 s:%@,bb:%@",s,bb);
        } else if (AF_INET6 == addrs[i].sin.sin_family) {
//            _dnssvraddrs.push_back(socket_address(addrs[i].sin6));
            char addr[INET6_ADDRSTRLEN];
            const char *aa = inet_ntop(AF_INET6, &addrs[i].sin6.sin6_addr, addr, INET6_ADDRSTRLEN);
            NSString *s = [NSString stringWithUTF8String:addr];
            NSString *bb = [NSString stringWithUTF8String:aa];
            NSLog(@"ipv6 s:%@,bb:%@",s,bb);
        }

    }

    res_ndestroy(&stat);
//    res_nclose(&stat);
}

#pragma mark - Stream Task
//- (void)URLSession:(NSURLSession *)session
//betterRouteDiscoveredForStreamTask:(NSURLSessionStreamTask *)streamTask
//{
//    NSLog(@"betterRouteDiscoveredForStreamTask");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.textLabel.text = [NSString stringWithFormat:@"%@\n\n\n\ndate:%@\n%@",self.textLabel.text,[NSDate date],@"betterRouteDiscoveredForStreamTask"];
//    });
//}
//
//- (void)URLSession:(NSURLSession *)session
//readClosedForStreamTask:(NSURLSessionStreamTask *)streamTask
//{
//    NSLog(@"readClosedForStreamTask");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.textLabel.text = [NSString stringWithFormat:@"%@\n\n\n\ndate:%@\n%@",self.textLabel.text,[NSDate date],@"readClosedForStreamTask"];
//    });
//}
//
//- (void)URLSession:(NSURLSession *)session
//writeClosedForStreamTask:(NSURLSessionStreamTask *)streamTask
//{
//    NSLog(@"writeClosedForStreamTask");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.textLabel.text = [NSString stringWithFormat:@"%@\n\n\n\ndate:%@\n%@",self.textLabel.text,[NSDate date],@"writeClosedForStreamTask"];
//    });
//}

#pragma mark - NSURLSessionDataDelegate
//- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
//{
//    NSLog(@"session level");
//    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeUseCredential;
//    NSURLCredential *credential = nil;
//    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
//    {
//        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
//    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.textLabel.text = [NSString stringWithFormat:@"%@\n\n\n\ndate:%@\ndisposition:%ld\ncredential:%@",self.textLabel.text,[NSDate date],disposition,credential];
//    });
//
//    completionHandler(disposition,credential);
//}
//
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSLog(@"task level");

    NSMutableArray *policies = [NSMutableArray array];
    NSString *domain = challenge.protectionSpace.host;
//    SecTrustRef serverTrust = challenge.protectionSpace.serverTrust;
//    if (self.validatesDomainName) {
    [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
//    } else {
//        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
//    }

    SecTrustSetPolicies(challenge.protectionSpace.serverTrust, (__bridge CFArrayRef)policies);
    BOOL result = AFServerTrustIsValid(challenge.protectionSpace.serverTrust);

    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeUseCredential;
    NSURLCredential *credential = nil;
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    }
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.textLabel.text = [NSString stringWithFormat:@"%@\n\n\n\ndate:%@\ndisposition:%ld\ncredential:%@",self.textLabel.text,[NSDate date],disposition,credential];
//    });
    completionHandler(disposition,credential);
}
//
//- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics
//{
//    NSLog(@"");
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.textLabel.text = [NSString stringWithFormat:@"%@\n\n\n\ndate:%@\nmetrics:%@",self.textLabel.text,[NSDate date],metrics];
//    });
//}
//
- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition disposition))completionHandler
{
//    NSLog(@"didReceiveResponse:%@",response);
    completionHandler(NSURLSessionResponseAllow);
}
//
//- (void)URLSession:(NSURLSession *)session
//          dataTask:(NSURLSessionDataTask *)dataTask
// willCacheResponse:(NSCachedURLResponse *)proposedResponse
// completionHandler:(void (^)(NSCachedURLResponse *cachedResponse))completionHandler
//{
//    completionHandler(proposedResponse);
//}

- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)dataTask
    didReceiveData:(NSData *)data
{
//    UIImage *image = [UIImage imageWithData:data];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        self.imageV.image = image;
//    });
//    NSError *er = nil;
    id response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];//[NSJSONSerialization JSONObjectWithData:data options:0 error:&er];
    NSLog(@"didReceiveData:%@",response);
}

- (void)URLSession:(NSURLSession *)session
              task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error
{
    NSLog(@"fetch_end:%@",[NSDate date]);
    NSLog(@"didCompleteWithError:%@",error);
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didFinishCollectingMetrics:(NSURLSessionTaskMetrics *)metrics
{
    NSLog(@"");
    NSURLSessionTaskTransactionMetrics *cc = [metrics.transactionMetrics firstObject];
    NSLog(@"metrics :%@",metrics);
    NSTimeInterval dnsStartT = cc.domainLookupStartDate.timeIntervalSinceReferenceDate * 1000;
    NSTimeInterval dnsEndT = cc.domainLookupEndDate.timeIntervalSinceReferenceDate * 1000;
    NSTimeInterval dnsT = dnsEndT - dnsStartT;
    NSLog(@"dns:%.0f",dnsT);
    NSLog(@"domainResolutionProtocol:%d",cc.domainResolutionProtocol);
}

#pragma mark - ip
- (NSDictionary *)ipInfo
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
//    if (@available(iOS 15.0, *)) return addresses;

    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type = nil;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    NSLog(@"%@",addresses);
    return [addresses count] ? addresses : nil;
}

- (NSString *)socketConnectWithIPAddress:(NSString *)IPAdress port:(int)port
{
    NSData *addrData = [self addrDataWithIPAddress:IPAdress port:port];
    NSMutableString *tempMutableStr = [[NSMutableString alloc]init];
    long sumTime = 0;
    if (addrData != nil)
    {
        struct sockaddr *pSockAddr = (struct sockaddr *)[addrData bytes];
        int sockfd = socket(pSockAddr->sa_family, SOCK_STREAM, 0);
        if (sockfd == -1) { //创建socket失败
            [tempMutableStr appendString:[NSString stringWithFormat:@"%d: socket creation failed ",1]];
            close(sockfd);
        }

        int connectStatus = connect(sockfd,  (struct sockaddr *)[addrData bytes], (socklen_t)[addrData length]);
        if (connectStatus != 0) { //socket连接失败
            [tempMutableStr appendString:[NSString stringWithFormat:@"%d: socket connection failed ",1]];
            close(sockfd);
        }
        NSInteger interval  = 30;
        [tempMutableStr appendString:[NSString stringWithFormat:@"%d: time=%ldms ",
                                      1, (long)interval]];
        sumTime += interval;
        close(sockfd);
    }

    return [tempMutableStr copy];
}

- (NSData *)addrDataWithIPAddress:(NSString *)IPAdress port:(int)port
{
    NSData *addrData = nil;
    //设置地址
//    if ([WBNetworkDiagnoseTool isValidIPv4:IPAdress])
//    {
        struct sockaddr_in nativeAddr4;
        memset(&nativeAddr4, 0, sizeof(nativeAddr4));
        nativeAddr4.sin_len     = sizeof(nativeAddr4);
        nativeAddr4.sin_family  = AF_INET;
        nativeAddr4.sin_port    = htons(port);
        inet_pton(AF_INET, IPAdress.UTF8String, &nativeAddr4.sin_addr.s_addr);
        addrData = [NSData dataWithBytes:&nativeAddr4 length:sizeof(nativeAddr4)];
//    }
//    else if([WBNetworkDiagnoseTool isValidIPv6:IPAdress])
//    {
//        struct sockaddr_in6 nativeAddr6;
//        memset(&nativeAddr6, 0, sizeof(nativeAddr6));
//        nativeAddr6.sin6_len    = sizeof(nativeAddr6);
//        nativeAddr6.sin6_family = AF_INET6;
//        nativeAddr6.sin6_port   = htons(port);
//        inet_pton(AF_INET6, IPAdress.UTF8String, &nativeAddr6.sin6_addr);
//        addrData = [NSData dataWithBytes:&nativeAddr6 length:sizeof(nativeAddr6)];
//    }
//    else {
//        return nil;
//    }

    return addrData;
}

#pragma mark - cert
+ (NSSet *)certificatesInBundle:(NSBundle *)bundle {
    NSArray *paths = [bundle pathsForResourcesOfType:@"cer" inDirectory:@"."];

    NSMutableSet *certificates = [NSMutableSet setWithCapacity:[paths count]];
    for (NSString *path in paths) {
        NSData *certificateData = [NSData dataWithContentsOfFile:path];
        [certificates addObject:certificateData];
    }

    return [NSSet setWithSet:certificates];
}

#pragma mark - test
#pragma mark - base helper
- (BOOL)isEmptyString:(NSString *)string
{
    if (!string || ![string isKindOfClass:[NSString class]] || string.length < 1) return YES;
    return NO;
}

- (BOOL)isEPureInt:(nonnull NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
    // 编写正则表达式：只能是数字
    NSString *regex = @"^[0-9]*$";
    if (!string || string.length < 1) return NO;
    // 创建谓词对象并设定条件的表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}

- (BOOL)isCPureInt:(nonnull NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"." withString:@""];
    // 编写正则表达式：只能是数字
    NSString *regex = @"^[0-9]*$";
    if (!string || string.length < 1) return NO;
    // 创建谓词对象并设定条件的表达式
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}

#pragma mark - base64
- (NSString *)base64Encode:(NSString *)data
{
    if (!data)
    {
        return nil;
    }
    NSData *sData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSData *base64Data = [sData base64EncodedDataWithOptions:0];
    NSString *baseString = [[NSString alloc]initWithData:base64Data encoding:NSUTF8StringEncoding];
    return baseString;
}

- (NSString *)base64Dencode:(NSString *)data
{
    if (!data)
    {
        return nil;
    }
    NSData *sData = [[NSData alloc]initWithBase64EncodedString:data options:0];//NSDataBase64DecodingIgnoreUnknownCharacters
    NSString *dataString = [[NSString alloc]initWithData:sData encoding:NSUTF8StringEncoding];
    return dataString;
}

#pragma mark - property
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

- (UIButton *)buttonC
{
    if (!_buttonC)
    {
        _buttonC = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonC addTarget:self action:@selector(buttonActionC:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonC setTitle:@"C按钮" forState:UIControlStateNormal];
        [_buttonC setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonC setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    }
    return _buttonC;
}

- (UIButton *)buttonD
{
    if (!_buttonD)
    {
        _buttonD = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonD addTarget:self action:@selector(buttonActionD:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonD setTitle:@"D按钮" forState:UIControlStateNormal];
        [_buttonD setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonD setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    }
    return _buttonD;
}

- (UIButton *)buttonE
{
    if (!_buttonE)
    {
        _buttonE = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonE addTarget:self action:@selector(buttonActionE:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonE setTitle:@"E按钮" forState:UIControlStateNormal];
        [_buttonE setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonE setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    }
    return _buttonE;
}

- (UIButton *)buttonF
{
    if (!_buttonF)
    {
        _buttonF = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonF addTarget:self action:@selector(buttonActionF:) forControlEvents:UIControlEventTouchUpInside];
        [_buttonF setTitle:@"F按钮" forState:UIControlStateNormal];
        [_buttonF setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_buttonF setTitleColor:[UIColor blueColor] forState:UIControlStateHighlighted];
    }
    return _buttonF;
}

- (UISwitch *)switchView
{
    if (!_switchView)
    {
        _switchView = [[UISwitch alloc] init];
        _switchView.preferredStyle = UISwitchStyleCheckbox;
        [_switchView addTarget:self action:@selector(checkChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _switchView;
}

- (WBXIndicatorView *)indicatorView
{
    if (!_indicatorView)
    {
        _indicatorView = [[WBXIndicatorView alloc] init];
    }
    return _indicatorView;
}

- (WBXSliderView *)slider
{
    if(!_slider)
    {
        _slider = [[WBXSliderView alloc] init];
        _slider.minimumValue = 0;
        _slider.maximumValue = 100;
    }
    return _slider;
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
        _operationQueue.maxConcurrentOperationCount = 1;//NSOperationQueueDefaultMaxConcurrentOperationCount;
    }
    return _operationQueue;
}

- (UITextField *)textfield
{
    if (!_textfield)
    {
        _textfield = [[UITextField alloc] init];
        _textfield.textColor = [UIColor blackColor];
//        _textfield.borderStyle = UITextBorderStyleRoundedRect;
        _textfield.backgroundColor = [UIColor greenColor];
    }
    return _textfield;
}

- (WBInternalHttpManager *)httpManager
{
    if (!_httpManager)
    {
        _httpManager = [WBInternalHttpManager httpManager];
    }
    return _httpManager;
}

- (NSURLSession *)session
{
    if (!_session)
    {
        NSURLSessionConfiguration *c = [NSURLSessionConfiguration defaultSessionConfiguration];
        c.requestCachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        c.timeoutIntervalForRequest = 10;
        _session = [NSURLSession  sessionWithConfiguration:c delegate:self delegateQueue:self.operationQueue];
    }

    return _session;
}

- (NSURLSessionStreamTask *)streamTask
{
   if (!_streamTask)
   {
       _streamTask = [self.session streamTaskWithHostName:@"2400:89c0:1013:3::17" port:443];
   }
    return _streamTask;
}

- (RoutingHTTPServer *)httpServer
{
    if (!_httpServer)
    {
        _httpServer = [[RoutingHTTPServer alloc] init];
    }
    return _httpServer;
}

@end
