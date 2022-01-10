//
//  WBHttpDns.h
//  HttpDns
//
//  Created by lizhi7 on 2017/12/5.
//  Copyright © 2017年 zhenhua21. All rights reserved.
//
//  Require: SystemConfiguration、CoreTelephony、CoreLocation、libresolv、libz
//  Requrie: Allow Http request

#import <Foundation/Foundation.h>

#import "WBHttpDnsConfiguration.h"

//IP 地址来源 Entity。
@interface WBHttpDnsEntity : NSObject
@property (nonatomic, strong) NSArray      * ips;
@property (nonatomic, copy)   NSString     * ip_source;
@property (nonatomic, copy)   NSString     * net_ip;
@property (nonatomic, copy)   NSDictionary * ip_cer_md5; // key=ip,value=cer_md5
@end

//
@interface WBHttpDns : NSObject

/**
 初始化wb_dns
 */
+ (void)init;

/**
 初始化_dns用configuration信息

 @param configuration 配置信息
 */
+ (void)initWithConfiguration:(WBHttpDnsConfiguration *)configuration;

/**
 预加载进行域名的解析,调用必须在init之后

 @param domains 需要提前解析的域名数组,数组是NSString对象
 */
+ (void)preload:(NSArray *)domains;

/**
 * 监听网络状态变化, 无网时清缓存。有网时探测 IPv6。
 */
+ (void)startListenNetworkStatus;

/**
 * 取消监听网络状态变化。
 */
+ (void)stopListenNetworkStatus;

/**
 通过域名进行获取相应的IP数组

 @param domain 域名
 @return 返回一组IP地址的NSString对象
 */
+ (NSArray *)getIPByDomain:(NSString *)domain;

/**
 * 通过域名进行获取相应的IP裸实体对象
 * @param   domain 域名
 * @return  返回包含一组IP地址的WBHttpDnsEntity对象。参数非法时返回nil。
 */
+ (WBHttpDnsEntity *)getIPSourceByDomain:(NSString *)domain;

/**
 *  获取IPv6探测信息。
 *  @return  返回@{@"ipv6_detect_result": @"0/1", @"ipv6_detect_error_info": @"error"}。
 */
+ (NSDictionary *)detectIPv6Result;

@end
