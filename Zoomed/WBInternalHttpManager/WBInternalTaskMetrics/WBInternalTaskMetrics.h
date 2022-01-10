//
//  WBInternalTaskMetrics.h
//  BaseLibs
//
//  Created by jungao on 2020/8/14.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif

NS_ASSUME_NONNULL_BEGIN
@class WBInternalTaskTransactionMetrics;

@interface WBInternalTaskMetrics : NSObject
#pragma mark - properties
//task通过这个id，来确定是否属于自己的统计值
@property (nonatomic, copy, readonly) NSString *identifier;

#pragma mark - date times
@property (nonatomic, copy, readonly, nullable) NSDate *fetchStartDate;
@property (nonatomic, copy, readonly, nullable) NSDate *domainLookupStartDate;
@property (nonatomic, copy, readonly, nullable) NSDate *domainLookupEndDate;
@property (nonatomic, copy, readonly, nullable) NSDate *connectStartDate;
@property (nonatomic, copy, readonly, nullable) NSDate *secureConnectionStartDate;
@property (nonatomic, copy, readonly, nullable) NSDate *secureConnectionEndDate;
@property (nonatomic, copy, readonly, nullable) NSDate *connectEndDate;
@property (nonatomic, copy, readonly, nullable) NSDate *requestStartDate;
@property (nonatomic, copy, readonly, nullable) NSDate *requestEndDate;
@property (nonatomic, copy, readonly, nullable) NSDate *responseStartDate;
@property (nonatomic, copy, readonly, nullable) NSDate *responseEndDate;
@property (nonatomic, copy, readonly, nullable) NSDate *fetchEndDate;

#pragma mark - transaction characteristics
@property(nonatomic, copy, readonly, nullable) NSString *remoteAddress;
@property(nonatomic, assign, readonly) BOOL reusedConnection;
//是否通过代理链接，获取资源
@property (nonatomic, assign, readonly) BOOL proxyConnection;

@end

NS_ASSUME_NONNULL_END
