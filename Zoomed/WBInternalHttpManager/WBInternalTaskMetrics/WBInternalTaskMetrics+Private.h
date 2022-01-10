//
//  WBInternalTaskMetrics+Private.h
//  BaseLibs
//
//  Created by jungao on 2020/8/14.
//

#import "WBInternalTaskMetrics.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,WBInternalRequestStatus)
{
    SUCCESS = 0,
    IO_PENDING = 1,
    CANCELED = 2,
    FAILED = 3
};

@interface WBInternalTaskMetrics ()

#pragma mark - properties
//task通过这个id，来确定是否属于自己的统计值
@property (nonatomic, copy, readwrite) NSString *identifier;

#pragma mark - date times
@property (nonatomic, copy, readwrite, nullable) NSDate * fetchStartDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *domainLookupStartDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *domainLookupEndDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *connectStartDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *secureConnectionStartDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *secureConnectionEndDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *connectEndDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *requestStartDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *requestEndDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *responseStartDate;
@property (nonatomic, copy, readwrite, nullable) NSDate *responseEndDate;
@property (nonatomic, copy, readwrite, nullable) NSDate * fetchEndDate;

#pragma mark - transaction characteristics
@property (nonatomic, copy, readwrite, nullable) NSString *remoteAddress;
@property (nonatomic, assign, readwrite) BOOL reusedConnection;
//是否通过代理链接，获取资源
@property (nonatomic, assign, readwrite) BOOL proxyConnection;
@property (nonatomic, assign) WBInternalRequestStatus requestStatus;

//domain name lookup from source
//域名解析到的ip地址，来源：缓存 or 非缓存
@property (nonatomic, copy, nullable) NSString *domainNameIPLookupFrom;
@property (nonatomic, copy, nullable) NSString *net_ip;

@end

NS_ASSUME_NONNULL_END
