//
//  WBInternalHttpDNSManager.m
//  AFNetworking iOS
//
//  Created by jungao on 2020/7/11.
//  Copyright © 2020 Weibo. All rights reserved.
//

#import "WBInternalHttpDNSManager.h"
#import "NSString+WBInternalString.h"
#import "NSArray+WBInternalArray.h"

#import "NSURLSessionTask+WBInternalURLSessionTask.h"

@interface WBInternalHttpDNSResult()
@property (nonatomic, assign, readwrite) NSInteger resolveStatus;
@property (nonatomic, assign, readwrite) NSInteger resolveType;
@property (nonatomic, copy, nullable, readwrite) NSArray *ips;
@property (nonatomic, copy, readwrite, nullable) NSString *domainNameIPLookupFrom;
@property (nonatomic, copy, readwrite, nullable) NSString *net_ip;
@property (nonatomic, copy, readwrite, nullable) NSDictionary<NSString *,NSString *> *cer_chain_md5;
@end

//NSString * const WBIABTUsingHttpDNSKey = @"feature_httpdns_ios_enable";

@interface WBInternalHttpDNSManager ()

//httpdns解析回调block
@property (nonatomic, copy, readwrite, nullable) WBInternalHttpDNSResolveBlock resolveBlock;

@end

@implementation WBInternalHttpDNSManager

- (instancetype)init
{
    self = [super init];
    if (!self) return self;
    self.resolveBlock = nil;
    return self;
}

- (BOOL)checkUsingHttpDNS
{
    //默认支持
    BOOL usingHttpDNS = YES;
    if (usingHttpDNS)
    {
        [self configWBIHttpDNSResolveBlock];
    }
    return usingHttpDNS;
}

- (void)configWBIHttpDNSResolveBlock
{
    //feature_httpdns_ios_enable
    if (self.resolveBlock) return;
    //配置dns解析回调block
    [self setResolveBlock:^(NSString * _Nonnull host, WBInternalHttpDNSResultBlock  _Nonnull resultBlock)
        {
    //        WBHttpDnsEntity *entity = [WBHttpDns getIPSourceByDomain:host];
    //        if (!entity ||
    //            !entity.ips ||
    //            ![entity.ips isKindOfClass:[NSArray class]] ||
    //            entity.ips.count < 1)
    //        {
    //            resultBlock(nil);
    //            return;
    //        }
    //        180.149.139.248,
    //        180.149.153.187,
    //        49.7.40.131,
    //        49.7.40.133
            NSArray *ipv4s = @[@"180.149.139.248"];
            WBInternalHttpDNSResult *httpDNSResult = [[WBInternalHttpDNSResult alloc] initWithStatus:BDHttpDnsResolveOK resolveType:BDHttpDnsResolveFromDns ips:ipv4s];
            httpDNSResult.domainNameIPLookupFrom = @"sina_httpdns";//entity.ip_source;
            httpDNSResult.net_ip = @"218.30.113.42";//entity.net_ip;
            httpDNSResult.cer_chain_md5 = nil;//entity.ip_cer_md5;
            resultBlock(httpDNSResult);
    //        id<WeiboNetCoreSDKCubeProtocol> httpDNS = [[WeiboCube sharedCube] instanceWithProtocol:@protocol(WeiboNetCoreSDKCubeProtocol)];
    //        if (!httpDNS)
    //        {
    //            resultBlock(nil);
    //            return;
    //        }
    //        id<WBHttpDNSResult> dnsResult = [httpDNS getIPSourceByDomain:host];
    //        if (!dnsResult || !dnsResult.ips || ![dnsResult.ips isKindOfClass:[NSArray class]] || dnsResult.ips.count == 0)
    //        {
    //            resultBlock(nil);
    //            return;
    //        }
    //        WBInternalHttpDNSResult *httpDNSResult = [[WBInternalHttpDNSResult alloc] initWithStatus:BDHttpDnsResolveOK resolveType:BDHttpDnsResolveFromDns ipv4s:dnsResult.ips ipv6s:nil];
    //        httpDNSResult.domainNameIPLookupFrom = dnsResult.ip_source;
    //        httpDNSResult.net_ip = dnsResult.net_ip;
    //        httpDNSResult.cer_chain_md5 = dnsResult.ip_cer_md5;
    //        resultBlock(httpDNSResult);
        }];
}

@end

@implementation WBInternalHttpDNSResult

- (instancetype)initWithStatus:(NSInteger)resolveStatus
                   resolveType:(NSInteger)resolveType
                           ips:(nonnull NSArray *)ips
{
    self = [super init];
    if (!self) return self;
    self.resolveStatus = resolveStatus;
    self.resolveType = resolveType;
    self.ips = ips;
    return self;
}

- (BOOL)validHttpDNSResult
{
    if (self.resolveStatus != BDHttpDnsResolveOK) return NO;
    if (self.resolveType == BDHttpDnsResolveNone) return NO;
    if (self.resolveType == BDHttpDnsResolveFromHttpDnsExpiredCache) return NO;
    if ([NSArray isEmptyArray:self.ips]) return NO;
    return YES;
}

- (BOOL)tryIPReplaceURLHost:(NSURL **)url
{
    BOOL result = NO;
    //IPs为空
    if ([NSArray isEmptyArray:self.ips]) return result;
    NSURL *currentURL = *url;
    NSString *urlString = currentURL.absoluteString;
    NSString *host = currentURL.host;
    if ([host containsString:@"]"])
    {
        host = [host stringByReplacingOccurrencesOfString:@"]" withString:@""];
        host = [host stringByReplacingOccurrencesOfString:@"[" withString:@""];
    }
    NSString *ip = host;
    ip = [self getNextIPFromIPs:self.ips host:host];
    //如果ip == host，表明已经尝试了所有ip
    if ([ip isEqualToString:host]) return result;
    result = YES;
    //处理ipv6替换逻辑
    host = currentURL.host;
    if ([NSString isIPV6:ip])
    {
        ip = [NSString stringWithFormat:@"%@%@%@",@"[",ip,@"]"];
    }
    if ([NSString isEmptyString:host] ||
        [NSString isEmptyString:ip])
    {
        return NO;
    }
    //IPv6时，url.host只返回ip值，不返回[]。
    //因此需要重新添加[]
    if ([NSString isIPV6:host] &&
        ![host containsString:@"]"])
    {
        host = [NSString stringWithFormat:@"%@%@%@",@"[",host,@"]"];
    }
    urlString = [urlString stringByReplacingOccurrencesOfString:host
                                                     withString:ip];
    *url = [NSURL URLWithString:urlString];
    return result;
}

- (nullable NSString *)getNextIPFromIPs:(nonnull NSArray *)ips
                                   host:(nonnull NSString *)host
{
    NSString *ip = nil;
    if ([ips containsObject:host])
    {
        NSInteger index = [ips indexOfObject:host];
        index++;
        if (index < ips.count)
        {
            ip = [ips objectAtIndex:index];
        }
    }
    else
    {
        ip = [ips firstObject];
    }
    return ip;
}

- (nullable NSURL *)replaceURLHost:(nonnull NSURL *)url
                            byHost:(nonnull NSString *)host
{
    if (!url) return nil;
    NSString *ipHost = url.host;
    if ([NSString isIPV6:ipHost] )
    {
        ipHost = [NSString stringWithFormat:@"[%@]",url.host];
    }
    NSString *urlString = [url.absoluteString stringByReplacingOccurrencesOfString:ipHost withString:host];
    return [NSURL URLWithString:urlString];
}

@end
