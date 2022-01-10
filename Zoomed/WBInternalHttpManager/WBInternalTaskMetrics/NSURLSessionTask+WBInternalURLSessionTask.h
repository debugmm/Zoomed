//
//  NSURLSessionTask+WBInternalURLSessionTaskExtension.h
//  BaseLibs
//
//  Created by jungao on 2020/8/4.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * const WBInternalkTaskMetricsKey;
FOUNDATION_EXPORT NSString * const WBIkTaskMetricsKey;

@class WBInternalTaskMetrics;
@class WBInternalHttpDNSResult;

@interface NSURLSessionTask (WBInternalURLSessionTask)
//内部标识，某个task是唯一的，同时也是在所有session中，都是唯一的
@property (nonatomic, copy, nullable) NSString *internalTaskIdentifier;
//此session task是否使用Http DNS做DNS查询
@property (nonatomic, assign) BOOL usingHttpDNS;
//此session task采用HTTPDNS查询后，缓存的查询结果
@property (nonatomic, strong, nullable) WBInternalHttpDNSResult *httpDNSResult;

@property (nonatomic, strong, nullable) NSURLSessionTaskMetrics *taskMetrics API_AVAILABLE(ios(10.0));
//采用ip直连，生成的度量信息
@property (nonatomic, strong, nullable) WBInternalTaskMetrics *wbinternalTaskMetrics;

#pragma mark - date times
//task开始时间
@property (nonatomic, strong, readonly, nullable) NSDate *fetchStartDate;
//dns查找开始时间
@property (nonatomic, strong, readonly, nullable) NSDate *domainLookupStartDate;
//dns查找结束时间
@property (nonatomic, strong, readonly, nullable) NSDate *domainLookupEndDate;
//链接建立开始（链接，即：一个完整的https链接，也是tcp链接建立的开始）
@property (nonatomic, strong, readonly, nullable) NSDate *connectStartDate;
//SSL安全层链接建立开始（tcp链接建立结束）
@property (nonatomic, strong, readonly, nullable) NSDate *secureConnectionStartDate;
//SSL安全层链接建立结束
@property (nonatomic, strong, readonly, nullable) NSDate *secureConnectionEndDate;
//链接建立结束（链接，即：一个完整的https链接，完成）
@property (nonatomic, strong, readonly, nullable) NSDate *connectEndDate;
//Request请求开始
@property (nonatomic, strong, readonly, nullable) NSDate *requestStartDate;
//Request结束
@property (nonatomic, strong, readonly, nullable) NSDate *requestEndDate;
//响应开始
@property (nonatomic, strong, readonly, nullable) NSDate *responseStartDate;
//响应结束
@property (nonatomic, strong, readonly, nullable) NSDate *responseEndDate;
@property (nonatomic, copy, readonly, nullable) NSDate * fetchEndDate;

#pragma mark - transaction characteristics
@property(nonatomic, copy, readonly, nullable) NSString *remoteAddress;
//链接是否复用
@property (nonatomic, assign, readonly) BOOL reusedConnection;
//是否通过代理链接，获取资源
@property (nonatomic, assign, readonly) BOOL proxyConnection;

#pragma mark - converted log
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *,id> *cronet_log;
@property (nonatomic, copy, readonly, nullable) NSDictionary<NSString *,NSNumber *> *cronet_start_end;

@end

NS_ASSUME_NONNULL_END
