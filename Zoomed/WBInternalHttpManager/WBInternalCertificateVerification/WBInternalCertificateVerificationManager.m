//
//  WBInternalCertificateVerificationManager.m
//  WeiboTechs
//
//  Created by jungao on 2020/10/22.
//

#import "WBInternalCertificateVerificationManager.h"
#import "NSString+WBInternalString.h"
#import "WBInternalHttpDNSManager.h"
#import "NSURLSessionTask+WBInternalURLSessionTask.h"
#import <AssertMacros.h>

static BOOL WBInternalServerTrustIsValid(SecTrustRef serverTrust) {
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

@interface WBInternalCertificateVerificationManager ()

/// 是否缓存了证书MD5值（当前默认：NO）
@property (nonatomic, assign, readwrite) BOOL cacheCerMD5;

@end

@implementation WBInternalCertificateVerificationManager

- (nullable id)certificateVerification:(NSURLSession * _Nonnull)session
                                  task:(NSURLSessionTask * _Nonnull)task
                             challenge:(NSURLAuthenticationChallenge * _Nonnull)challenge
                     completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    //1. 获取space.host、获取request.header.host。
    //2. 如果space.host不是IP，直接采用域名校验证书。
    //  （这种情况表明：请求时采用LocalDNS方式执行），并且采用AFN证书校验流程。

    //3. 如果space.host是ip，使用request.header.host执行域名校验。
    //  （这种情况表明：使用了HttpDNS拿到的IP发起请求），采用自定义证书校验流程。
    //3.1. 使用request.header.host执行证书校验，是基于性能考虑，推测可能是请求公司自有服务器。
    //3.2. 因为后面需要执行的操作更多。

    //4. 如果3失败，开始域名校对流程：
    //4.1. 根据task.internalIdentifier、ip，获取HttpDNS返回的域名证书md5。
    //4.2. APP计算证书通用名称链条md5值。
    //    （获取证书链整个每个证书的通用名称，并把它们连接起来，计算md5值）。
    //4.3. 比较APP计算的md5与httpdns库返回的md5如果不相等，则直接失败即可，不需要走下面的流程（采用AFN证书校验失败处理流程）。
    //4.4. 如果相等，则生成证书验证通过。
    NSLog(@"cer verification,task:%@,identifier:%@,usingHttpDNS:%ld,httpDNSResult:%@",task,task.internalTaskIdentifier,task.usingHttpDNS,task.httpDNSResult);
    id result = @(NSURLSessionAuthChallengePerformDefaultHandling);
    //不是服务端证书验证，走AFN验证流程
    if ([NSString isEmptyString:challenge.protectionSpace.authenticationMethod] ||
        ![challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        return result;
    }
    NSString *challengeHost = challenge.protectionSpace.host;
    //通过LocalDNS发起的请求，走AFN域名-证书校验流程
    if (![NSString isIPHost:challengeHost])
    {
        return result;
    }
    //IP直连的请求，先检查ip否是公司自有服务器（如果是，那么应该是可以通过的，因为证书配置成了通用证书）
    NSString *requestHost = [task.currentRequest valueForHTTPHeaderField:@"HOST"];
    if (![NSString isEmptyString:requestHost] &&
        ![NSString isIPHost:requestHost])
    {
        if ([self evaluateServerTrust:challenge.protectionSpace.serverTrust
                            forDomain:requestHost])
        {
            //验证通过，可以建立安全连接，并发送请求通信
            [self trustChallenge:challenge completionHandler:completionHandler];
            //自定义处理，不走AFN处理流程
            return nil;
        }
    }
    //请求的IP非公司自有服务器，证书可能是第三方服务证书
    //获取httpdns.cer_md5
    WBInternalHttpDNSResult *httpDNSResult = task.httpDNSResult;
    if (!httpDNSResult) return [self httpDNSResultStorageError];
    /// ################################
    /// 如果未来需要提升cer_chain_md5计算性能
    /// 可以采用NSCache类实现缓存策略
    /// ################################
    //计算证书链通用名称md5值
    NSString *cer_chain_md5;
    if (httpDNSResult.cer_chain_md5 &&
        httpDNSResult.cer_chain_md5.count > 0 &&
        ![NSString isEmptyString:challengeHost])
    {
        cer_chain_md5 = [httpDNSResult.cer_chain_md5 objectForKey:challengeHost];
    }
    NSString *recalculateCerChainMD5 = [self certificateChainCommonNameMD5With:challenge.protectionSpace.serverTrust];
    if ([NSString isEmptyString:cer_chain_md5] ||
        ![cer_chain_md5 isEqualToString:recalculateCerChainMD5])
    {
        //证书链通用名称md5值不相等
        return [self certificateCommonNameChainDigestValueError];
    }
    //验证通过，可以建立安全连接，并发送请求通信
    [self trustChallenge:challenge completionHandler:completionHandler];
    //自定义处理，不走AFN处理流程
    return nil;
}

#pragma mark -
- (BOOL)evaluateServerTrust:(SecTrustRef)serverTrust
                  forDomain:(NSString *)domain
{
    NSMutableArray *policies = [NSMutableArray array];
    if (![NSString isIPHost:domain])
    {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateSSL(true, (__bridge CFStringRef)domain)];
    }
    else
    {
        [policies addObject:(__bridge_transfer id)SecPolicyCreateBasicX509()];
    }
    SecTrustSetPolicies(serverTrust, (__bridge CFArrayRef)policies);
    return WBInternalServerTrustIsValid(serverTrust);
}

- (nonnull NSString *)certificateChainCommonNameMD5With:(SecTrustRef)serverTrust
{
    CFIndex certificateCount = SecTrustGetCertificateCount(serverTrust);
    NSMutableString *commonNameChain = [[NSMutableString alloc] initWithCapacity:1];
    for (CFIndex i = 0; i < certificateCount; i++)
    {
            SecCertificateRef certificate = SecTrustGetCertificateAtIndex(serverTrust, i);
        //SecCertificateCopySubjectSummary
        CFStringRef commonNameRef = NULL;
        NSString *commonName = nil;
        if (@available(iOS 10.3, *))
        {
            SecCertificateCopyCommonName(certificate, &commonNameRef);
        }
        else
        {
            // Fallback on earlier versions
            commonNameRef = SecCertificateCopySubjectSummary(certificate);
        }
        if (commonNameRef != NULL) commonName = CFBridgingRelease(commonNameRef);
        if (i+1 == certificateCount)
        {
            [commonNameChain appendString:[NSString stringWithFormat:@"%@",commonName]];
        }
        else
        {
            [commonNameChain appendString:[NSString stringWithFormat:@"%@,",commonName]];
        }
    }
    NSString *chainMD5 = [NSString generateStringMD5:commonNameChain];
    return chainMD5;
}

- (void)trustChallenge:(NSURLAuthenticationChallenge * _Nonnull)challenge
     completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler
{
    NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengeUseCredential;
    NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
    completionHandler(disposition, credential);
}

#pragma mark - helper
- (nonnull NSError *)serverCertificateError
{
    // 服务器返回了无效证书，应该查看服务器是否配置了默认证书
    // 比如：nginx没有配置访问域名不存在时，默认的主机与证书配置问题
    return [[NSError alloc] initWithDomain:NSURLErrorDomain
                                      code:NSURLErrorServerCertificateNotYetValid
                                  userInfo:@{@"certificateKey":@"服务端未返回有效的证书"}];
}

- (nonnull NSError *)httpDNSResultStorageError
{
    //本地缓存的httpDNSResult结果有问题（需要排查存储httpDNSResult代码逻辑问题）
    return [[NSError alloc] initWithDomain:NSURLErrorDomain
                                      code:NSURLErrorUnknown
                                  userInfo:@{@"httpDNSResultStorageErrorKey":@"HttpDNSResultStorageError"}];
}

- (nonnull NSError *)httpDNSResultHostError
{
    //httpdns返回的数据有错误：返回了空的host
    //还需要将错误信息，通报给服务器
    return [[NSError alloc] initWithDomain:NSURLErrorDomain
                                      code:NSURLErrorUnknown
                                  userInfo:@{@"httpDNSResultHostErrorKey":@"HttpDNSResultHostEmpty"}];
}

- (nonnull NSError *)httpDNSHostCertificateInvalid
{
    //还需要将错误信息，通报给服务器
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:NSURLErrorServerCertificateUntrusted
                           userInfo:@{@"certificateKey":@"httpDNSHostCertificateInvalid"}];
}

- (nonnull NSError *)httpDNSHostNoInTrustHosts
{
    //还需要将错误信息，通报给服务器
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:NSURLErrorServerCertificateUntrusted
                           userInfo:@{@"httpDNSHostNoInTrustHostsKey":@"httpDNSHostNoInTrustHosts"}];
}

- (nonnull NSError *)certificateCommonNameChainDigestValueError
{
    //还需要将错误信息，通报给服务器
    return [NSError errorWithDomain:NSURLErrorDomain
                               code:NSURLErrorServerCertificateUntrusted
                           userInfo:@{@"certificateCommonNameChainDigestValueErrorKey":@"certificateCommonNameChainDigestValueError"}];
}

@end
