//
//  WBHttpDnsConfiguration.h
//  HttpDns
//
//  Created by lizhi7 on 2017/12/5.
//  Copyright © 2017年 zhenhua21. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 sdkVersion sdkKey sdkMasterSecret sdkConfigData绑定的，一组互相协同关联，一个填写其他的必须填写
 */
@interface WBHttpDnsConfiguration : NSObject

@property (nonatomic, strong) NSString *uid;

@property (nonatomic, strong) NSString *localConfigFilePath;

@property (nonatomic, strong) NSString *sdkVersion;

@property (nonatomic, strong) NSString *sdkKey;

@property (nonatomic, strong) NSString *sdkMasterSecret;

@property (nonatomic, strong) NSString *sdkConfigData;

@property (nonatomic, assign) BOOL enableIPv6;

@property (nonatomic, assign) BOOL enableLocalStore;

@property (nonatomic, assign) BOOL enableConnectTimeout;

@property (nonatomic, assign) BOOL enableDetectIPv6;

//是否启用多域名接口
@property (nonatomic, assign) BOOL enableMultiHostPreload;
//是否禁用d接口上传localdns解析结果
@property (nonatomic, assign) BOOL disabledLocalDnsForNetworkRequest;
//是否启用全量缓存更新, 任意域名缓存更新都触发全量缓存更新
@property (nonatomic, assign) BOOL enableAutoTriggerMultiHostUpdate;
//
@property (nonatomic, assign) BOOL enableLocalDnsAsynchronousLookup;

@property (nonatomic, assign) BOOL enableErrorLogRecord;

//是否开启获取BSSID。
@property (nonatomic, assign) BOOL enableBssidInfo;
//是否开启获取SIM。
@property (nonatomic, assign) BOOL enableSimInfo;
//是否开启LocalReason共享指针线程锁。
@property (nonatomic, assign) BOOL enableLocalReasonStringLock;
//是否开启IPv6探测结果上报。
@property (nonatomic, assign) BOOL enableDetectIPv6Result;

@property (nonatomic, copy) NSString * (^blockGpsCallback)(void);
@property (nonatomic, copy) NSString * (^blockUidCallback)(void);
@property (nonatomic, copy) void (^blockLogCallback)(NSDictionary * dictionary);

@end
