//
//  WBInternalHttpManager+Private.h
//  WeiboTechs
//
//  Created by jungao on 2020/11/28.
//

#import "WBInternalHttpManager.h"

@class WBInternalAFHTTPSessionManager;
@class WBInternalAFHTTPRequestSerializer;
@class WBInternalTask;
@class WBInternalHttpDNSManager;
@class WBInternalCertificateVerificationManager;

NS_ASSUME_NONNULL_BEGIN

typedef void (^WBISuccessBlock)(NSURLSessionTask * _Nullable task, id _Nullable responseObject);
//失败回调block
typedef void (^WBIFailureBlock)(NSURLSessionTask * _Nullable task, NSError * _Nullable error);

@interface WBInternalHttpManager ()

- (instancetype)init NS_UNAVAILABLE;

#pragma mark - resumeTask Request
- (void)resumeTask:(WBInternalTask *)task;

#pragma mark - Download Request
- (void)resumeDownloadWithWBIVolatileCachedDownloadTask:(WBInternalVolatileCachedDownloadTask *)task;

#pragma mark - property
//http session
@property (nonatomic, strong) WBInternalAFHTTPSessionManager *httpSessionManager;
//http Request Serializer
@property (nonatomic, strong) NSDictionary<NSString *,WBInternalAFHTTPRequestSerializer *> *requestSerializers;

//request parameters cached
@property (nonatomic, strong) NSCache<NSString *,id> *requestParametersCached;

@property (nonatomic, strong) WBInternalHttpDNSManager *httpDNSManager;
@property (nonatomic, strong) WBInternalCertificateVerificationManager *cerVerificationManager;

@end

NS_ASSUME_NONNULL_END
