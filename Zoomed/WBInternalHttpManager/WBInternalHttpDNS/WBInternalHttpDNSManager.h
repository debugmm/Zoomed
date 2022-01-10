//
//  WBInternalHttpDNSManager.h
//  AFNetworking iOS
//
//  Created by jungao on 2020/7/11.
//  Copyright © 2020 Weibo. All rights reserved.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

NS_ASSUME_NONNULL_BEGIN

@class WBInternalHttpDNSResult;
@class WBInternalTaskTransactionMetrics;

//采用http dns服务解析的域名（比如：www.weibo.cn）
typedef void (^WBInternalHttpDNSResultBlock)(WBInternalHttpDNSResult * _Nullable result);
//内部采用统一的异步方式回调
typedef void (^WBInternalHttpDNSResolveBlock)(NSString * host,WBInternalHttpDNSResultBlock resultBlock);

@interface WBInternalHttpDNSManager : NSObject

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (BOOL)checkUsingHttpDNS;

#pragma mark - property
@property (nonatomic, copy, nullable, readonly) WBInternalHttpDNSResolveBlock resolveBlock;

@end

//将HTTPDNS解析结果，转成内部对象表示
@interface WBInternalHttpDNSResult : NSObject

- (instancetype)initWithStatus:(NSInteger)resolveStatus
                   resolveType:(NSInteger)resolveType
                           ips:(NSArray *)ips;

/// 校验结果是否有效，可以使用
/// YES：结果有效可用
/// NO：结果无效，不应该使用
- (BOOL)validHttpDNSResult;

#pragma mark -
/// 使用ip替换url的host
/// @param url url
- (BOOL)tryIPReplaceURLHost:(NSURL *_Nonnull*_Nonnull)url;

- (nullable NSURL *)replaceURLHost:(NSURL *)url
                            byHost:(NSString *)host;

#pragma mark - property
//httpdns解析返回状态
@property (nonatomic, assign, readonly) NSInteger resolveStatus;
//httpdns解析返回的数据的来源类型
@property (nonatomic, assign, readonly) NSInteger resolveType;
//httpdns解析的ip地址列表
//这个列表，按照可靠度做的排序（从第一个到最后一个）
//[ips firstObject]
@property (nonatomic, copy, readonly) NSArray<NSString *> *ips;

//domain name lookup from source
//域名解析到的ip地址，来源：缓存 or 非缓存
@property (nonatomic, copy, readonly, nullable) NSString *domainNameIPLookupFrom;
@property (nonatomic, copy, readonly, nullable) NSString *net_ip;

/// ########################
/// 以下新增字段，只有iOS端使用它
/// ########################
/// {
/// ip : cer_chain_md5
/// }
/// key，IP地址
/// value，根据证书链方式采用英文逗号分割，各个证书下的主题(subject)下的通用名称，拼接生成的字符串MD5值。
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *,NSString *> *cer_chain_md5;

@end

/**
 * Httpdns解析状态码
 */
typedef NS_ENUM(NSInteger, WBInternalHttpDNSResolveStatus) {
    // 解析成功
    BDHttpDnsResolveOK = 0,
    // 输入参数错误
    BDHttpDnsInputError,
    // 由于cache未命中导致的解析失败，仅在解析时指定cache only标志时有效
    BDHttpDnsResolveErrCacheMiss,
    //  dns解析失败
    BDHttpDnsResolveErrDnsResolve,
};

/**
 * Httpdns解析结果来源
 */
typedef NS_ENUM(NSInteger, WBInternalHttpDNSResolveType) {
    // 没有有效的解析结果
    BDHttpDnsResolveNone = 0,
    // 解析结果来自httpdns cache
    BDHttpDnsResolveFromHttpDnsCache,
    // 解析结果来自过期的httpdns cache
    BDHttpDnsResolveFromHttpDnsExpiredCache,
    // 解析结果来自dns cache
    BDHttpDnsResolveFromDnsCache,
    // 解析结果来自dns解析
    BDHttpDnsResolveFromDns,
};

NS_ASSUME_NONNULL_END

