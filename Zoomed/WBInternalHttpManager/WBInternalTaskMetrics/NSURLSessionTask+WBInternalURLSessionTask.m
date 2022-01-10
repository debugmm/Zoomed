//
//  NSURLSessionTask+WBInternalURLSessionTaskExtension.m
//  BaseLibs
//
//  Created by jungao on 2020/8/4.
//

#import "NSURLSessionTask+WBInternalURLSessionTask.h"
#import "NSArray+WBInternalArray.h"
#import "WBInternalTaskMetrics.h"

#import "NSString+WBInternalString.h"
#import "WBInternalTaskMetrics+Private.h"

#import "WBInternalHttpDNSManager.h"

#import <objc/runtime.h>

NSString * const WBInternalkTaskMetricsKey = @"wbinternal.task.metrics.key";
NSString * const WBIkTaskMetricsKey = @"wbi.task.metrics.key";
NSString * const WBInternalNEKey = @"cn";
NSString * const WBInternalTaskIdentifierKey = @"wbi.task.identifier.key";
NSString * const WBInternalUsingHttpDNSKey = @"wbi.task.using.httpdns.key";
NSString * const WBInternalHttpDNSResultKey = @"wbi.task.httpdns.result.key";

#define WBInternalMS (1000)

@implementation NSURLSessionTask (WBInternalURLSessionTask)

- (nullable NSString *)internalTaskIdentifier
{
    return objc_getAssociatedObject(self, (__bridge const void * _Nonnull)WBInternalTaskIdentifierKey);
}

- (void)setInternalTaskIdentifier:(NSString * _Nullable)internalTaskIdentifier
{
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(WBInternalTaskIdentifierKey), internalTaskIdentifier, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (nullable WBInternalHttpDNSResult *)httpDNSResult
{
    return objc_getAssociatedObject(self, (__bridge const void * _Nonnull)WBInternalHttpDNSResultKey);
}

- (void)setHttpDNSResult:(WBInternalHttpDNSResult * _Nullable)httpDNSResult
{
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(WBInternalHttpDNSResultKey), httpDNSResult, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
- (BOOL)usingHttpDNS
{
    return objc_getAssociatedObject(self, (__bridge const void * _Nonnull)WBInternalUsingHttpDNSKey);
}

- (void)setUsingHttpDNS:(BOOL)usingHttpDNS
{
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(WBInternalUsingHttpDNSKey), @(usingHttpDNS), OBJC_ASSOCIATION_COPY_NONATOMIC);
}

#pragma mark -
- (nullable NSURLSessionTaskMetrics *)taskMetrics
API_AVAILABLE(ios(10.0)){
    return objc_getAssociatedObject(self, (__bridge const void * _Nonnull)WBInternalkTaskMetricsKey);
}

- (void)setTaskMetrics:(NSURLSessionTaskMetrics *)taskMetrics
API_AVAILABLE(ios(10.0)){
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(WBInternalkTaskMetricsKey), taskMetrics, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (nullable WBInternalTaskMetrics *)wbinternalTaskMetrics
{
    return objc_getAssociatedObject(self, (__bridge const void * _Nonnull)WBIkTaskMetricsKey);
}

- (void)setWbinternalTaskMetrics:(WBInternalTaskMetrics *)wbinternalTaskMetrics
{
    objc_setAssociatedObject(self, (__bridge const void * _Nonnull)(WBIkTaskMetricsKey), wbinternalTaskMetrics, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

#pragma mark -
- (nullable NSDate *)fetchStartDate
{
    return [self fetchStartDateMetrics];//[self dateMetricsForKey:@"fetchStartDate"];
}

- (nullable NSDate *)fetchEndDate
{
    return [self fetchEndDateMetrics];
}

- (nullable NSDate *)domainLookupStartDate
{
    return [self domainLookupDateForKey:@"domainLookupStartDate"];
}

- (nullable NSDate *)domainLookupEndDate
{
    return [self domainLookupDateForKey:@"domainLookupEndDate"];
}

- (nullable NSDate *)connectStartDate
{
    return [self dateMetricsForKey:@"connectStartDate"];
}

- (nullable NSDate *)secureConnectionStartDate
{
    return [self dateMetricsForKey:@"secureConnectionStartDate"];
}

- (nullable NSDate *)secureConnectionEndDate
{
    return [self dateMetricsForKey:@"secureConnectionEndDate"];
}

- (nullable NSDate *)connectEndDate
{
    return [self dateMetricsForKey:@"connectEndDate"];
}

- (nullable NSDate *)requestStartDate
{
    return [self dateMetricsForKey:@"requestStartDate"];
}

- (nullable NSDate *)requestEndDate
{
    return [self dateMetricsForKey:@"requestEndDate"];
}

- (nullable NSDate *)responseStartDate
{
    return [self dateMetricsForKey:@"responseStartDate"];
}

- (nullable NSDate *)responseEndDate
{
    return [self dateMetricsForKey:@"responseEndDate"];
}

#pragma mark -
- (BOOL)reusedConnection
{
    return [self boolMetricsForKey:@"reusedConnection"];
}

- (BOOL)proxyConnection
{
    return [self boolMetricsForKey:@"proxyConnection"];
}

- (nullable NSString *)remoteAddress
{
    return [self stringMetricsForKey:@"remoteAddress"];
}

#pragma mark - helper
- (nullable id)objectMetricsForKey:(nonnull NSString *)key
{
    if (@available(iOS 10.0, *))
    {
        return [[self taskTransactionMetrics] valueForKey:key];
    }
    return nil;
}

- (nullable id)wbObjectMetricsForKey:(nonnull NSString *)key
{
    WBInternalTaskMetrics *metrics = [self wbTaskTransactionMetrics];
    if (metrics)
    {
        return [metrics valueForKey:key];
    }
    return nil;
}

#pragma mark -
- (nullable NSDate *)dateMetricsForKey:(nonnull NSString *)key
{
    if (@available(iOS 10.0, *))
    {
        NSDate *date = (NSDate *)[[self taskTransactionMetrics] valueForKey:key];
        return date;
    }
    NSDate *wbDate = [self wbDateMetricsForKey:key];
    return wbDate;
}

- (nullable NSDate *)wbDateMetricsForKey:(nonnull NSString *)key
{
    WBInternalTaskMetrics *metrics = [self wbTaskTransactionMetrics];
    if (metrics)
    {
        return (NSDate *)[metrics valueForKey:key];
    }
    return nil;
}

- (nullable NSDate *)domainLookupDateForKey:(nonnull NSString *)key
{
    NSDate *wbDate = [self wbDateMetricsForKey:key];
    if (wbDate) return wbDate;
    if (@available(iOS 10.0, *))
    {
        NSDate *date = (NSDate *)[[self taskTransactionMetrics] valueForKey:key];
        return date;
    }
    return nil;
}

- (nullable NSDate *)fetchEndDateMetrics
{
    if (@available(iOS 10.0, *))
    {
        NSDate *endDateA = [self taskInterval].endDate;
        return endDateA;
    }
    NSDate *endDateB = [self wbDateMetricsForKey:@"fetchEndDate"];
    return endDateB;
}

- (nullable NSDate *)fetchStartDateMetrics
{
    if (@available(iOS 10.0, *))
    {
        NSDate *startDateA = [self taskInterval].startDate;
        return startDateA;
    }
    NSDate *startDateB = [self wbDateMetricsForKey:@"fetchStartDate"];
    return startDateB;
}

#pragma mark -
- (nullable NSNumber *)wbBoolMetricsForKey:(nonnull NSString *)key
{
    WBInternalTaskMetrics *metrics = [self wbTaskTransactionMetrics];
    if (metrics)
    {
        return ((NSNumber *)[metrics valueForKey:key]);
    }
    return nil;
}

- (BOOL)boolMetricsForKey:(nonnull NSString *)key
{
    NSNumber *mb = nil;
    if (@available(iOS 10.0, *))
    {
        NSNumber *number = (NSNumber *)[[self taskTransactionMetrics] valueForKey:key];
        return number.boolValue;
    }
    mb = [self wbBoolMetricsForKey:key];
    return mb.boolValue;
}

#pragma mark -
- (nullable NSString *)stringMetricsForKey:(nonnull NSString *)key
{
    //remoteAddress
    NSString *remoteAddress = [self wbObjectMetricsForKey:key];
    if (![NSString isEmptyString:remoteAddress]) return remoteAddress;
    if (@available(iOS 13.0, *))
    {
        remoteAddress = [self objectMetricsForKey:key];
    }
    return remoteAddress;
}

#pragma mark -
- (nullable NSURLSessionTaskTransactionMetrics *)taskTransactionMetrics
API_AVAILABLE(ios(10.0)){
    if (!self.taskMetrics) return nil;
    if ([NSArray isEmptyArray:self.taskMetrics.transactionMetrics]) return nil;
    NSURLSessionTaskTransactionMetrics *metrics = [self.taskMetrics.transactionMetrics firstObject];
    return metrics;
}

- (nullable WBInternalTaskMetrics *)wbTaskTransactionMetrics
{
    return self.wbinternalTaskMetrics;
}

- (nullable NSDateInterval *)taskInterval
API_AVAILABLE(ios(10.0)){
    return [self taskMetrics].taskInterval;
}

#pragma mark - logs convert
//cronet_finish
//cronet_start
- (nullable NSDictionary<NSString *,NSNumber *> *)cronet_start_end
{
    NSDate *startDate = [self fetchStartDate];
    if (!startDate) return nil;
    NSDate *endDate = [self fetchEndDate];
    if (!endDate) return nil;
    return @{
             @"cronet_start":@(startDate.timeIntervalSince1970),
             @"cronet_finish":@(endDate.timeIntervalSince1970)
            };
}

- (nullable NSDictionary<NSString *,id> *)cronet_log
{
    //从进入cronet网络库，到开始dns查询的时间
    NSTimeInterval cronet_dl = 0;
    NSDate *fetchStartDate = [self fetchStartDate];
    NSDate *domainLookupStartDate = [self domainLookupStartDate];
    if (fetchStartDate && domainLookupStartDate)
    {
        cronet_dl = domainLookupStartDate.timeIntervalSinceReferenceDate - fetchStartDate.timeIntervalSinceReferenceDate;
        if (cronet_dl < 0) cronet_dl = fetchStartDate.timeIntervalSinceReferenceDate - domainLookupStartDate.timeIntervalSinceReferenceDate;
        if (cronet_dl < 0) cronet_dl = 0;
    }
    cronet_dl = round(cronet_dl * WBInternalMS);//毫秒
    //dns耗时
    NSTimeInterval dl = 0;
    NSDate *domainLookupEndDate = [self domainLookupEndDate];
    if (domainLookupStartDate && domainLookupEndDate)
    {
        dl = domainLookupEndDate.timeIntervalSinceReferenceDate - domainLookupStartDate.timeIntervalSinceReferenceDate;
    }
    dl = round(dl * WBInternalMS);//毫秒
    //服务器IP
    NSString *host_ip = [self remoteAddress];
    if ([NSString isEmptyString:host_ip]) host_ip = @"";
    //内部等待时间
    NSTimeInterval lw = 0;
    //错误码
    NSString *ne = @"";
    NSNumber *statusN = (NSNumber *)[self wbObjectMetricsForKey:@"requestStatus"];
    ne = [NSString stringWithFormat:@"%@%ld",WBInternalNEKey,statusN.integerValue];
    //读取下行数据耗时
    NSTimeInterval rb = 0;
    NSDate *responseStartDate = [self responseStartDate];
    NSDate *responseEndDate = [self responseEndDate];
    if (responseStartDate && responseEndDate)
    {
        rb = responseEndDate.timeIntervalSinceReferenceDate - responseStartDate.timeIntervalSinceReferenceDate;
    }
    rb = round(rb * WBInternalMS);//毫秒
    //读取服务器返回header时间，cronet没有执行计算，设置默认值0
    NSTimeInterval rh = 0;
    //socket链接时间
    NSTimeInterval sc = 0;
    NSDate *connectionStartDate = [self connectStartDate];
    NSDate *connectionEndDate = [self connectEndDate];
    if (connectionStartDate && connectionEndDate)
    {
        sc = connectionEndDate.timeIntervalSinceReferenceDate - connectionStartDate.timeIntervalSinceReferenceDate;
    }
    sc = round(sc * WBInternalMS);//毫秒
    //是否复用链接
    BOOL schBool = [self reusedConnection];
    NSString *schString = @"false";
    if (schBool) schString = @"true";
    //socket-uuid
    NSString *socket_uuid = @"";
    //发送上行数据耗时
    NSTimeInterval sr = 0;
    NSDate *requestStartDate = [self requestStartDate];
    NSDate *requestEndDate = [self requestEndDate];
    if (requestStartDate && requestEndDate)
    {
        sr = requestEndDate.timeIntervalSinceReferenceDate - requestStartDate.timeIntervalSinceReferenceDate;
    }
    sr = round(sr * WBInternalMS);//毫秒
    //ssh链接耗时
    NSTimeInterval ssc = 0;
    NSDate *secStartDate = [self secureConnectionStartDate];
    NSDate *secEndDate = [self secureConnectionEndDate];
    if (secStartDate && secEndDate)
    {
        ssc = secEndDate.timeIntervalSinceReferenceDate - secStartDate.timeIntervalSinceReferenceDate;
    }
    ssc = round(ssc * WBInternalMS);
    //等待服务器响应时间
    NSTimeInterval ws = 0;
    if (requestEndDate && responseStartDate)
    {
        ws = responseStartDate.timeIntervalSinceReferenceDate - requestEndDate.timeIntervalSinceReferenceDate;
    }
    ws = round(ws * WBInternalMS);
    //从服务器响应到开始读取数据中间间隔
    NSTimeInterval ws_rb = 0;
    //ip_source
    NSString *ipsource = self.wbinternalTaskMetrics.domainNameIPLookupFrom;
    if ([NSString isEmptyString:ipsource]) ipsource = @"";

    NSDictionary *dict = @{
        @"cronet_dl":@(cronet_dl),
        @"cronet_dl_int":@(cronet_dl),
        @"dl":@(dl),
        @"host_ip":host_ip,
        @"lw":@(lw),
        @"ne":ne,
        @"rb":@(rb),
        @"rh":@(rh),
        @"sc":@(sc),
        @"sch":schString,
        @"socket_uuid":socket_uuid,
        @"sr":@(sr),
        @"ssc":@(ssc),
        @"ws":@(ws),
        @"ws_rb":@(ws_rb),
        @"ip_source":ipsource
    };
    return dict;
}

@end
