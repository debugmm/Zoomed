//
//  WBInternalURLProtocol.m
//  Weibo
//
//  Created by jungao on 2020/7/7.
//  Copyright © 2020 Sina. All rights reserved.
//

#import "WBInternalURLProtocol.h"
#import "WBInternalAFNetworking.h"


//key define
NSString * const WBInternalURLProtocolHandledKey = @"wb.internal.urlprotocol.handled.key";

@interface WBInternalURLProtocol () <NSURLSessionDelegate,NSStreamDelegate>{
    NSInputStream *inputStream;
    NSRunLoop *curRunLoop;
}

@end

@implementation WBInternalURLProtocol

+ (BOOL)canInitWithTask:(NSURLSessionTask *)task
{
    //不处理跳转
    NSString *originURLString = task.originalRequest.URL.absoluteString;
    NSString *currentURLString = task.currentRequest.URL.absoluteString;
    if (![originURLString isEqualToString:currentURLString]) return NO;
    //循环处理
    if ([self propertyForKey:WBInternalURLProtocolHandledKey inRequest:task.currentRequest]) return NO;
    return YES;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request
{
    
    return request;
}

- (instancetype)initWithTask:(NSURLSessionTask *)task cachedResponse:(NSCachedURLResponse *)cachedResponse client:(id<NSURLProtocolClient>)client
{
    return [super initWithTask:task cachedResponse:cachedResponse client:client];
}

- (void)startLoading
{
//    NSMutableURLRequest *request = [self.request mutableCopy];
    // 表示该请求已经被处理，防止无限循环

    //设置标记，防止被重复拦截，引发dead-loop
    NSMutableURLRequest *mutableRequest = [[self request] mutableCopy];
    [WBInternalURLProtocol setProperty:@(YES) forKey:WBInternalURLProtocolHandledKey inRequest:mutableRequest];
    [self startRequest:mutableRequest];

    //模拟HTTPS-IP直连:api.weibo.cn - 180.149.139.248
//    NSString *host = self.request.URL.host;
//    NSString *urlString = self.request.URL.absoluteString;
//    urlString = [urlString stringByReplacingOccurrencesOfString:host withString:@"180.149.139.248"];
//    NSMutableURLRequest *newRequest = [self.request mutableCopy];
//    [newRequest setURL:[NSURL URLWithString:urlString]];
//    [newRequest setValue:host forHTTPHeaderField:@"host"];
//    [WBInternalURLProtocol setProperty:@(YES) forKey:WBInternalURLProtocolHandledKey inRequest:newRequest];
//
//    WBInternalAFHTTPSessionManager *m = [WBInternalAFHTTPSessionManager manager];
////    m.securityPolicy.allowInvalidCertificates = YES;
//    m.securityPolicy.validatesDomainName = NO;
//
//    NSURLSessionDataTask *task = [m dataTaskWithRequest:newRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
//        NSLog(@"");
//    }];
//    [task resume];

//    NSURLSession *s = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:nil];
//
//    NSURLSessionDataTask *task = [s dataTaskWithRequest:mutableRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSLog(@"");
//    }];
//    [task resume];
}

- (void)stopLoading
{

}

-(void)asiRequest
{
    
//    WBInternalASIHTTPRequest *request = [WBInternalASIHTTPRequest requestWithURL:nil];
//    request.delegate = self;
//    [request startAsynchronous];
}

/*** 使用CFHTTPMessage转发请求*/
- (void)startRequest:(NSURLRequest *)curRequest {
    // 添加http post请求所附带的数据
    CFStringRef requestBody = CFSTR("");
    CFDataRef bodyData = CFStringCreateExternalRepresentation(kCFAllocatorDefault, requestBody,kCFStringEncodingUTF8, 0);
    if (curRequest.HTTPBody) {
        bodyData = (__bridge_retained CFDataRef) curRequest.HTTPBody;
    }
    CFStringRef url = (__bridge CFStringRef) [curRequest.URL absoluteString];
    CFURLRef requestURL = CFURLCreateWithString(kCFAllocatorDefault, url, NULL);
    // 原请求所使用的方法，GET或POST
    CFStringRef requestMethod = (__bridge_retained CFStringRef) curRequest.HTTPMethod;
    // 根据请求的url、方法、版本创建CFHTTPMessageRef对象
    CFHTTPMessageRef cfrequest = CFHTTPMessageCreateRequest(kCFAllocatorDefault, requestMethod, requestURL,kCFHTTPVersion1_1);CFHTTPMessageSetBody(cfrequest, bodyData);
    // copy原请求的header信息
    NSDictionary *headFields = curRequest.allHTTPHeaderFields;
    for (NSString *header in headFields) {
        CFStringRef requestHeader = (__bridge CFStringRef) header;
        CFStringRef requestHeaderValue = (__bridge CFStringRef) [headFields valueForKey:header];
        CFHTTPMessageSetHeaderFieldValue(cfrequest, requestHeader, requestHeaderValue);

    }
    // 创建CFHTTPMessage对象的输入流
    CFReadStreamRef readStream = CFReadStreamCreateForHTTPRequest(kCFAllocatorDefault, cfrequest);
    inputStream = (__bridge_transfer NSInputStream *) readStream;
    // 设置SNI host信息，关键步骤
    NSString *host = [curRequest.allHTTPHeaderFields objectForKey:@"host"];
    if (!host) {
        host = curRequest.URL.host;
    }
    [inputStream setProperty:NSStreamSocketSecurityLevelNegotiatedSSL forKey:NSStreamSocketSecurityLevelKey];
    NSDictionary *sslProperties = [[NSDictionary alloc] initWithObjectsAndKeys:host, (__bridge id) kCFStreamSSLPeerName,nil];
    [inputStream setProperty:sslProperties forKey:(__bridge_transfer NSString *) kCFStreamPropertySSLSettings];
    [inputStream setDelegate:self];
    if (!curRunLoop)
        // 保存当前线程的runloop，这对于重定向的请求很关键
        curRunLoop = [NSRunLoop currentRunLoop];
    // 将请求放入当前runloop的事件队列
    [inputStream scheduleInRunLoop:curRunLoop forMode:NSRunLoopCommonModes];
    [inputStream open];
    CFRelease(cfrequest);
    CFRelease(requestURL);
    CFRelease(url);
    cfrequest = NULL;
    CFRelease(bodyData);
    CFRelease(requestBody);
    CFRelease(requestMethod);
}

- (void)ccStartRequest
{

}

#pragma mark - NSURLSessionDelegate
- (void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSLog(@"");
}

- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSLog(@"");
}

@end
