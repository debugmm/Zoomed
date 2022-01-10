//
//  WBInternalHttpManager.m
//  Weibo
//
//  Created by jungao on 2020/7/7.
//  Copyright © 2020 Sina. All rights reserved.
//

#import "WBInternalHttpManager.h"
#import "WBInternalHttpManager+Private.h"

#import "WBInternalAFNetworking.h"
#import "NSString+WBInternalString.h"
#import "NSURLSessionTask+WBInternalURLSessionTask.h"
//#import "NSURLSessionTask+WBInternalTaskPrivate.h"


#import "NSArray+WBInternalArray.h"


#import "WBInternalURLProtocol.h"

#import "WBInternalTaskMetrics+Private.h"

#import "WBInternalCertificateVerificationManager.h"
#import "WBInternalAFHTTPSessionManager+Private.h"

#import "WBInternalHttpDNSManager.h"

/// wbinternaltask
#import "WBInternalTask.h"
#import "WBInternalTask+Private.h"
#import "WBInternalDataTask.h"
#import "WBInternalUploadTask.h"
#import "WBInternalUploadTask+Private.h"
#import "WBInternalDownloadTask.h"
#import "WBInternalDownloadTask+Private.h"
#import "WBInternalVolatileCachedDownloadTask.h"
#import "WBInternalVolatileCachedDownloadTask+Private.h"

#import "WBInternalIdentifierGenerator.h"

/// http request log
//#import "WBInternalHttpLog.h"

//key define
NSString * const POSTRequestKey = @"post";
NSString * const GetRequestKey = @"get";
NSString * const HeadRequestKey = @"head";
NSString * const DeleteRequestKey = @"delete";
NSString * const UsingGetRequestSerializerKey = @"get";
NSString * const UsingFormURLEncodedKey = @"form-urlencoded";
//background id prefix
NSString * const BackgroundSessionConfigIdPrefix = @"wb.internal.background.session.";
//deprecated key define
NSString * const CronetLogKey = @"cronet_log";
NSString * const CronetStartEndKey = @"cronet_start_end";

/// ABTest Key define
NSString * const WBIABTPostAPIKey = @"feature_intercept_http_post_method_ios_enable";
NSString * const WBIABTGetAPIKey = @"feature_intercept_http_get_method_ios_enable";
NSString * const WBIABTPutAPIKey = @"feature_intercept_http_put_method_ios_enable";
NSString * const WBIABTDeleteAPIKey = @"feature_intercept_http_delete_method_ios_enable";
NSString * const WBIABTUploadAPIKey = WBIABTPostAPIKey;
NSString * const WBIABTDownloadAPIKey = WBIABTGetAPIKey;

NSString * const WBIABTInterceptPathKeyFormat = @"feature_%@_ios_enable";
//feature_groupchat_member_banned_ios_enable

NSString * const WBINewNetFrameworkKey = @"feature_new_network_ios_enable";
NSString * const WBINewNetFrameworkValue = @"1";

//标记使用http body发送请求内容
//NSString * const WBIUsingHttpBodyKey = @"usingHttpBody";
//NSString * const WBIUsingHttpBodyValue = @"YES";

#define WBInternalNanos (1000000000)

@implementation WBInternalHttpManager
+ (instancetype)httpManager
{
    NSURLSessionConfiguration *df = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSMutableArray *protocols = [[NSMutableArray alloc] init];
//    if (df.protocolClasses)
//    {
//        [protocols addObjectsFromArray:df.protocolClasses];
//    }
//    [protocols insertObject:[WBInternalURLProtocol class] atIndex:0];
//    df.protocolClasses = protocols;

    WBInternalHttpManager *httpManager = [[WBInternalHttpManager alloc] initWithBaseURL:nil sessionConfiguration:df];
    return httpManager;
}

+ (instancetype)httpManagerOfBackground
{
    NSString *bid = [NSString stringWithFormat:@"%@%f",BackgroundSessionConfigIdPrefix,([NSDate date].timeIntervalSinceReferenceDate * WBInternalNanos)];
    return [[WBInternalHttpManager alloc] initWithBaseURL:nil OfBackgroundManagerId:bid];
}

+ (instancetype)httpManagerOfEphemeral
{
    return [[WBInternalHttpManager alloc] initWithBaseURLOfEphemeral:nil];
}

#pragma mark -
- (instancetype)initWithBaseURL:(nullable NSURL *)url
{
    return [self initWithBaseURL:url sessionConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
}

- (instancetype)initWithBaseURL:(nullable NSURL *)url
          OfBackgroundManagerId:(nonnull NSString *)backgroundId
{
    if ([NSString isEmptyString:backgroundId]) return nil;
    return [self initWithBaseURL:url sessionConfiguration:[NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:backgroundId]];
}

- (instancetype)initWithBaseURLOfEphemeral:(nullable NSURL *)url
{
    return [self initWithBaseURL:url sessionConfiguration:[NSURLSessionConfiguration ephemeralSessionConfiguration]];
}

- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration
{
    self = [super init];
    if (!self) return nil;
    if (!configuration)
    {
        configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    }
    self.httpDNSManager = [[WBInternalHttpDNSManager alloc] init];
    self.cerVerificationManager = [[WBInternalCertificateVerificationManager alloc] init];
    self.httpSessionManager = [[WBInternalAFHTTPSessionManager alloc] initWithBaseURL:url sessionConfiguration:configuration];
    //配置serializer
    self.requestSerializers = @{GetRequestKey:[WBInternalAFHTTPRequestSerializer serializer],
                                POSTRequestKey:[WBInternalAFJSONRequestSerializer serializer]
                              };
    //配置responseSerializer
    WBInternalAFJSONResponseSerializer *json = [WBInternalAFJSONResponseSerializer serializer];
    WBInternalAFXMLParserResponseSerializer *xml = [WBInternalAFXMLParserResponseSerializer serializer];
    WBInternalAFPropertyListResponseSerializer *plist = [WBInternalAFPropertyListResponseSerializer serializer];
    NSArray<WBInternalAFHTTPResponseSerializer *> *responseSerializers = @[
                                json,
                                xml,
                                plist
                                ];
        WBInternalAFCompoundResponseSerializer *compoundResponseSerializer = [WBInternalAFCompoundResponseSerializer compoundSerializerWithResponseSerializers:responseSerializers];
    [self addAcceptableContentType:compoundResponseSerializer];
    self.httpSessionManager.responseSerializer = compoundResponseSerializer;
    if (@available(iOS 10, *))
    {
        [self.httpSessionManager setTaskDidFinishCollectingMetricsBlock:^(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLSessionTaskMetrics * _Nullable metrics) {
            task.taskMetrics = metrics;
        }];
    }

    __weak typeof(self) weakSelf = self;
    [self.httpSessionManager setAuthenticationChallengeHandler:^id _Nonnull(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, void (^ _Nonnull completionHandler)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable)) {
        return [weakSelf.cerVerificationManager certificateVerification:session
                                                                   task:task
                                                              challenge:challenge
                                                      completionHandler:completionHandler];
    }];

    [self.httpSessionManager setDataTaskDidReceiveResponseBlock:^NSURLSessionResponseDisposition(NSURLSession * _Nonnull session, NSURLSessionDataTask * _Nonnull dataTask, NSURLResponse * _Nonnull response) {
        return NSURLSessionResponseAllow;
    }];
    self.httpSessionManager.operationQueue.maxConcurrentOperationCount = 10;
    //默认开启httpdns功能
    [self enableHttpDNSFeature];
    return self;
}

#pragma mark -
- (void)addAcceptableContentType:(nonnull WBInternalAFHTTPResponseSerializer *)responseSerializer
{
    if (!responseSerializer) return;
    NSMutableSet<NSString *> *accecptTypes = [[NSMutableSet alloc] initWithCapacity:1];
    if (responseSerializer.acceptableContentTypes && responseSerializer.acceptableContentTypes.count > 0)
    {
        [accecptTypes setSet:responseSerializer.acceptableContentTypes];
    }
    [accecptTypes addObject:@"application/octet-stream"];
    responseSerializer.acceptableContentTypes = accecptTypes;
}

#pragma mark - properties
- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount
{
    self.httpSessionManager.operationQueue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}

- (NSInteger)maxConcurrentOperationCount
{
    return self.httpSessionManager.operationQueue.maxConcurrentOperationCount;
}

- (NSCache<NSString *,id> *)requestParametersCached
{
    if (!_requestParametersCached)
    {
        _requestParametersCached = [[NSCache alloc] init];
        _requestParametersCached.countLimit = 1000;
    }
    return _requestParametersCached;
}

#pragma mark - request methods
#pragma mark Get Request
- (nullable WBInternalDataTask *)getWithURL:(nonnull NSString *)URLString
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self getWithURL:URLString
                 parameters:nil
                    headers:nil
                   progress:nil
                    success:success
                    failure:failure];
}

- (nullable WBInternalDataTask *)getWithURL:(nonnull NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self getWithURL:URLString
                 parameters:parameters
                    headers:nil
                   progress:nil
                    success:success
                    failure:failure];
}

- (nullable WBInternalDataTask *)getWithURL:(nonnull NSString *)URLString
                                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self getWithURL:URLString
                 parameters:nil
                    headers:nil
                   progress:downloadProgress
                    success:success
                    failure:failure];
}

- (nullable WBInternalDataTask *)getWithURL:(nonnull NSString *)URLString
                                 parameters:(nullable id)parameters
                                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self getWithURL:URLString
                 parameters:parameters
                    headers:nil
                   progress:downloadProgress
                    success:success
                    failure:failure];
}

- (nullable WBInternalDataTask *)getWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"GET"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self getWithRequest:request
                       progress:downloadProgress
                        success:success
                        failure:failure];
}

#pragma mark -
- (nullable WBInternalDataTask *)getWithRequest:(NSURLRequest *)request
                                        success:(nullable WBIDataTaskSuccessBlock)success
                                        failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self getWithRequest:request
                       progress:nil
                        success:success
                        failure:failure];
}

- (nullable WBInternalDataTask *)getWithRequest:(NSURLRequest *)request
                                       progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                        success:(nullable WBIDataTaskSuccessBlock)success
                                        failure:(nullable WBIDataTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalDataTask *wbTask = [[WBInternalDataTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.downloadProgressBlock = downloadProgress;
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = GetRequest;
    wbTask.requestParameters = [self requestParameters:request];
    wbTask.httpManager = self;
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark - POST Request
- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self postWithURL:URLString
                  parameters:nil
                     headers:nil
                    progress:nil
                     success:success
                     failure:failure];
}

- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self postWithURL:URLString
                  parameters:parameters
                     headers:nil
                    progress:nil
                     success:success
                     failure:failure];
}

- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                    progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self postWithURL:URLString
                  parameters:parameters
                     headers:nil
                    progress:uploadProgress
                     success:success
                     failure:failure];
}

- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self postWithURL:URLString
                  parameters:parameters
                     headers:headers
                    progress:nil
                     success:success
                     failure:failure];
}

- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                    progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"POST"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self postWithRequest:request
                        progress:uploadProgress
                         success:success
                         failure:failure];
}

#pragma mark -
- (nullable WBInternalDataTask *)postWithRequest:(NSURLRequest *)request
                                         success:(nullable WBIDataTaskSuccessBlock)success
                                         failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self postWithRequest:request
                        progress:nil
                         success:success
                         failure:failure];
}

- (nullable WBInternalDataTask *)postWithRequest:(NSURLRequest *)request
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIDataTaskSuccessBlock)success
                                         failure:(nullable WBIDataTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalDataTask *wbTask = [[WBInternalDataTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.uploadProgressBlock = uploadProgress;
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = PostRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark - POST Multi Part
- (nullable WBInternalUploadTask *)postMultipartWithURL:(NSString *)URLString
                                             parameters:(nonnull NSDictionary *)parameters
                                                success:(nullable WBIUploadTaskSuccessBlock)success
                                                failure:(nullable WBIUploadTaskFailureBlock)failure
{
    return [self postMultipartWithURL:URLString
                           parameters:parameters
                              headers:nil
                             progress:nil
                              success:success
                              failure:failure];
}

- (nullable WBInternalUploadTask *)postMultipartWithURL:(NSString *)URLString
                                             parameters:(nonnull NSDictionary *)parameters
                                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                success:(nullable WBIUploadTaskSuccessBlock)success
                                                failure:(nullable WBIUploadTaskFailureBlock)failure
{
    return [self postMultipartWithURL:URLString
                           parameters:parameters
                              headers:nil
                             progress:uploadProgress
                              success:success
                              failure:failure];
}

- (nullable WBInternalUploadTask *)postMultipartWithURL:(NSString *)URLString
                                             parameters:(nonnull NSDictionary *)parameters
                                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                success:(nullable WBIUploadTaskSuccessBlock)success
                                                failure:(nullable WBIUploadTaskFailureBlock)failure
{
    if (!parameters || parameters.count < 1) return nil;
    NSDictionary *cachedParameters = [parameters copy];
    NSDictionary<NSString *,NSURL *> *files = [self divisionMultipartParameters:&parameters];
    NSMutableURLRequest *request = [self buildMultipartRequestWithURLString:URLString
                                                                 parameters:parameters
                                                  constructingBodyWithBlock:^(id<WBInternalAFMultipartFormData> formData)
    {
        if (!files || files.count < 1) return;
        [files enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSURL * _Nonnull obj, BOOL * _Nonnull stop) {
            [formData appendPartWithFileURL:obj
                                       name:key
                                      error:nil];
        }];
    } headers:headers];
    [self storeReuqestParameters:cachedParameters
                     withRequest:request];

    return [self postMultipartWithRequest:request
                                 progress:uploadProgress
                                  success:success
                                  failure:failure];
}

#pragma mark -
- (nullable WBInternalUploadTask *)postMultipartWithRequest:(NSURLRequest *)request
                                                   progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                    success:(nullable WBIUploadTaskSuccessBlock)success
                                                    failure:(nullable WBIUploadTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalUploadTask *wbTask = [[WBInternalUploadTask alloc] init];
    wbTask.originResumeRequest = [request mutableCopy];
    wbTask.uploadProgressBlock = uploadProgress;
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = PostMultiPartRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark - Upload Request
- (nullable WBInternalUploadTask *)uploadWithURL:(NSString *)URLString
                                        fromFile:(nonnull NSString *)filePath
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIUploadTaskSuccessBlock)success
                                         failure:(nullable WBIUploadTaskFailureBlock)failure
{
    return [self uploadWithURL:URLString
                    parameters:nil
                       headers:nil
                      fromFile:filePath
                      progress:uploadProgress
                       success:success
                       failure:failure];
}

- (nullable WBInternalUploadTask *)uploadWithURL:(NSString *)URLString
                                      parameters:(nullable id)parameters
                                        fromFile:(nonnull NSString *)filePath
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIUploadTaskSuccessBlock)success
                                         failure:(nullable WBIUploadTaskFailureBlock)failure
{
    return [self uploadWithURL:URLString
                    parameters:parameters
                       headers:nil
                      fromFile:filePath
                      progress:uploadProgress
                       success:success
                       failure:failure];
}

- (nullable WBInternalUploadTask *)uploadWithURL:(NSString *)URLString
                                      parameters:(nullable id)parameters
                                         headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                        fromFile:(nonnull NSString *)filePath
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIUploadTaskSuccessBlock)success
                                         failure:(nullable WBIUploadTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"POST"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters
                     withRequest:request];
    return [self uploadWithRequest:request
                          fromFile:filePath
                          progress:uploadProgress
                           success:success
                           failure:failure];
}

#pragma mark -
- (nullable WBInternalUploadTask *)uploadWithRequest:(NSURLRequest *)request
                                            fromFile:(nonnull NSString *)filePath
                                            progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                             success:(nullable WBIUploadTaskSuccessBlock)success
                                             failure:(nullable WBIUploadTaskFailureBlock)failure
{
    if (!request) return nil;
    if ([NSString isEmptyString:filePath]) return nil;
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalUploadTask *wbTask = [[WBInternalUploadTask alloc] init];
    wbTask.localFileURL = fileURL;
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.uploadProgressBlock = uploadProgress;
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = UploadRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark - Download Request
- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure
{
    return [self downloadWithURL:URLString
                      parameters:nil
                         headers:nil
                        progress:downloadProgressBlock
                     destination:destination
                         success:success
                         failure:failure];
}

- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                           headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure
{
    return [self downloadWithURL:URLString
                      parameters:nil
                         headers:headers
                        progress:downloadProgressBlock
                     destination:destination
                         success:success
                         failure:failure];
}

- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                        parameters:(nullable id)parameters
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure
{
    return [self downloadWithURL:URLString
                      parameters:parameters
                         headers:nil
                        progress:downloadProgressBlock
                     destination:destination
                         success:success
                         failure:failure];
}

- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                        parameters:(nullable id)parameters
                                                           headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"GET"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self downloadWithRequest:request
                            progress:downloadProgressBlock
                         destination:destination
                             success:success
                             failure:failure];
}

#pragma mark -
- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithRequest:(NSURLRequest *)request
                                                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                           destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                               success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                               failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalVolatileCachedDownloadTask *wbTask = [[WBInternalVolatileCachedDownloadTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.downloadProgressBlock = downloadProgressBlock;
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.destinationBlock = destination;
    wbTask.requestType = VolatileCachedDownloadRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

- (void)resumeDownloadWithWBIVolatileCachedDownloadTask:(WBInternalVolatileCachedDownloadTask *)task
{
    if (!task.resumeData)
    {
        [self resumeTask:task];
        return;
    }
    WBIVolatileCachedDownloadTaskSuccessBlock success = task.successBlock;
    __block NSURLSessionDownloadTask *dataTask = [self.httpSessionManager downloadTaskWithResumeData:task.resumeData
                                                                                            progress:task.downloadProgressBlock
                                                                                         destination:task.destinationBlock
                                                                                   completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error)
    {
        if (error)
        {
            task.resumeData = nil;
            [self resumeTask:task];
        }
        else
        {
            if (success)
            {
                success(dataTask, filePath);
            }
        }
    }];
    task.task = dataTask;
    [dataTask resume];
}

#pragma mark - extension Download Request
- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self downloadWithURL:URLString
                         headers:nil
                      parameters:nil
                        progress:nil
     taskDidReceiveResponseBlock:taskDidReceiveResponseBlock taskDidReceiveDataBlock:taskDidReceiveDataBlock
     resumeHttpHeaderFieldsBlock:nil
                         success:success
                         failure:failure];
}

- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                         resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self downloadWithURL:URLString
                         headers:nil
                      parameters:nil
                        progress:nil
     taskDidReceiveResponseBlock:taskDidReceiveResponseBlock taskDidReceiveDataBlock:taskDidReceiveDataBlock
     resumeHttpHeaderFieldsBlock:resumeHttpHeaderFieldsBlock
                         success:success
                         failure:failure];
}

- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                                            progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                         resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self downloadWithURL:URLString
                         headers:nil
                      parameters:nil
                        progress:downloadProgressBlock
     taskDidReceiveResponseBlock:taskDidReceiveResponseBlock taskDidReceiveDataBlock:taskDidReceiveDataBlock
     resumeHttpHeaderFieldsBlock:resumeHttpHeaderFieldsBlock
                         success:success
                         failure:failure];
}

- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                                          parameters:(nullable id)parameters
                                            progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                         resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self downloadWithURL:URLString
                         headers:nil
                      parameters:parameters
                        progress:downloadProgressBlock
     taskDidReceiveResponseBlock:taskDidReceiveResponseBlock taskDidReceiveDataBlock:taskDidReceiveDataBlock
     resumeHttpHeaderFieldsBlock:resumeHttpHeaderFieldsBlock
                         success:success
                         failure:failure];
}

- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                                             headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                          parameters:(nullable id)parameters
                                            progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                         resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"GET"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self downloadWithRequest:request
                            progress:downloadProgressBlock
         taskDidReceiveResponseBlock:taskDidReceiveResponseBlock
             taskDidReceiveDataBlock:taskDidReceiveDataBlock
         resumeHttpHeaderFieldsBlock:resumeHttpHeaderFieldsBlock
                             success:success
                             failure:failure];
}

#pragma mark -
- (nullable WBInternalDownloadTask *)downloadWithRequest:(NSURLRequest *)request
                             taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                                 taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                                                 success:(nullable WBIDataTaskSuccessBlock)success
                                                 failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self downloadWithRequest:request
                            progress:nil
         taskDidReceiveResponseBlock:taskDidReceiveResponseBlock
             taskDidReceiveDataBlock:taskDidReceiveDataBlock
         resumeHttpHeaderFieldsBlock:nil
                             success:success
                             failure:failure];
}

- (nullable WBInternalDownloadTask *)downloadWithRequest:(NSURLRequest *)request
                             taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                                 taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                             resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                                 success:(nullable WBIDataTaskSuccessBlock)success
                                                 failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self downloadWithRequest:request
                            progress:nil
         taskDidReceiveResponseBlock:taskDidReceiveResponseBlock
             taskDidReceiveDataBlock:taskDidReceiveDataBlock
         resumeHttpHeaderFieldsBlock:resumeHttpHeaderFieldsBlock
                             success:success
                             failure:failure];
}

- (nullable WBInternalDownloadTask *)downloadWithRequest:(NSURLRequest *)request
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                             taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                                 taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                             resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                                 success:(nullable WBIDataTaskSuccessBlock)success
                                                 failure:(nullable WBIDataTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalDownloadTask *wbTask = [[WBInternalDownloadTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.downloadProgressBlock = downloadProgressBlock;
    wbTask.taskDidReceiveResponseBlock = taskDidReceiveResponseBlock;
    wbTask.taskReceiveDataBlock = taskDidReceiveDataBlock;
    wbTask.resumeHttpHeaderFieldsBlock = resumeHttpHeaderFieldsBlock;
    wbTask.requestType = DownloadRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark - Others Request
- (nullable WBInternalDataTask *)deleteWithURL:(NSString *)URLString
                                       success:(nullable WBIDataTaskSuccessBlock)success
                                       failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self deleteWithURL:URLString
                    parameters:nil
                       headers:nil
                       success:success
                       failure:failure];
}

- (nullable WBInternalDataTask *)deleteWithURL:(NSString *)URLString
                                    parameters:(nullable id)parameters
                                       success:(nullable WBIDataTaskSuccessBlock)success
                                       failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self deleteWithURL:URLString
                    parameters:parameters
                       headers:nil
                       success:success
                       failure:failure];
}

- (nullable WBInternalDataTask *)deleteWithURL:(NSString *)URLString
                                    parameters:(nullable id)parameters
                                       headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                       success:(nullable WBIDataTaskSuccessBlock)success
                                       failure:(nullable WBIDataTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"DELETE"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self deleteWithRequest:request
                           success:success
                           failure:failure];
}

- (nullable WBInternalDataTask *)deleteWithRequest:(NSURLRequest *)request
                                           success:(nullable WBIDataTaskSuccessBlock)success
                                           failure:(nullable WBIDataTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalDataTask *wbTask = [[WBInternalDataTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = DeleteRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark -
- (nullable WBInternalDataTask *)putWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self putWithURL:URLString
                 parameters:parameters
                    headers:nil
                    success:success
                    failure:failure];
}

- (nullable WBInternalDataTask *)putWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"PUT"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self putWithRequest:request
                        success:success
                        failure:failure];
}

- (nullable WBInternalDataTask *)putWithRequest:(NSURLRequest *)request
                                        success:(nullable WBIDataTaskSuccessBlock)success
                                        failure:(nullable WBIDataTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalDataTask *wbTask = [[WBInternalDataTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = PUTRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark -
- (nullable WBInternalDataTask *)patchWithURL:(NSString *)URLString
                                   parameters:(nullable id)parameters
                                      success:(nullable WBIDataTaskSuccessBlock)success
                                      failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self patchWithURL:URLString
                   parameters:parameters
                      headers:nil
                      success:success
                      failure:failure];
}

- (nullable WBInternalDataTask *)patchWithURL:(NSString *)URLString
                                   parameters:(nullable id)parameters
                                      headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                      success:(nullable WBIDataTaskSuccessBlock)success
                                      failure:(nullable WBIDataTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"PATCH"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self patchWithRequest:request
                          success:success
                          failure:failure];
}

- (nullable WBInternalDataTask *)patchWithRequest:(NSURLRequest *)request
                                          success:(nullable WBIDataTaskSuccessBlock)success
                                          failure:(nullable WBIDataTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalDataTask *wbTask = [[WBInternalDataTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = PatchRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark -
- (nullable WBInternalDataTask *)headWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure
{
    return [self headWithURL:URLString
                  parameters:parameters
                     headers:nil
                     success:success
                     failure:failure];
}

- (nullable WBInternalDataTask *)headWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure
{
    NSURLRequest *request = [self buildRequestWithHTTPMethod:@"HEAD"
                                                   URLString:URLString
                                                  parameters:parameters
                                                     headers:headers];
    [self storeReuqestParameters:parameters withRequest:request];
    return [self headWithRequest:request
                         success:success
                         failure:failure];
}

- (nullable WBInternalDataTask *)headWithRequest:(NSURLRequest *)request
                                         success:(nullable WBIDataTaskSuccessBlock)success
                                         failure:(nullable WBIDataTaskFailureBlock)failure
{
    if (!request) return nil;
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:request];
    WBInternalDataTask *wbTask = [[WBInternalDataTask alloc] init];
    wbTask.originResumeRequest = [mRequest mutableCopy];
    wbTask.successBlock = success;
    wbTask.failureBlock = failure;
    wbTask.requestType = HeadRequest;
    wbTask.requestParameters = [self requestParameters:request];
    [self dnsResolveDispatch:mRequest
                      wbTask:wbTask];
    return wbTask;
}

#pragma mark - resume task
- (void)resumeTask:(nonnull WBInternalTask *)task
{
    NSMutableURLRequest *mRequest = [self addHostHeaderToRequest:task.originResumeRequest];
    if (!mRequest) return;
    [self dnsResolveDispatch:mRequest
                      wbTask:task];
}

#pragma mark - dns resolve dispatch
- (void)dnsResolveDispatch:(nonnull NSMutableURLRequest *)request
                    wbTask:(nonnull WBInternalTask *)task
{
    __block BOOL usingHttpDNS = [self canUsingHttpDNS:request];
    NSString *identifier = [WBInternalIdentifierGenerator generateTaskIdentifier];
    task.identifier = identifier;
    if (usingHttpDNS)
    {
        WBInternalTaskMetrics *taskMetrics = [[WBInternalTaskMetrics alloc] init];
        taskMetrics.domainLookupStartDate = [NSDate date];
        self.httpDNSManager.resolveBlock(request.URL.host, ^(WBInternalHttpDNSResult * _Nullable result) {
            taskMetrics.domainLookupEndDate = [NSDate date];
            //httpdns返回了有效的结果，采用IP直连请求数据
            usingHttpDNS = (result && [result validHttpDNSResult]);
            if (usingHttpDNS)
            {
                taskMetrics.domainNameIPLookupFrom = result.domainNameIPLookupFrom;
                taskMetrics.net_ip = result.net_ip;
                //IP更换Host
                NSURL *url = [request.URL copy];
                BOOL ipReplaceResult = [result tryIPReplaceURLHost:&url];
                usingHttpDNS = ipReplaceResult;
                if (ipReplaceResult)
                {
                    request.URL = url;
                    //服务器地址
                    taskMetrics.remoteAddress = url.host;
                }
            }
            [self sendRequest:request
                      WBITask:(WBInternalDataTask *)task
               withIdentifier:identifier
                httpDNSResult:result
                  taskMetrics:taskMetrics
                 usingHttpDNS:usingHttpDNS];
        });
    }
    else
    {
        [self sendRequest:request
                  WBITask:(WBInternalDataTask *)task
           withIdentifier:identifier
            httpDNSResult:nil
              taskMetrics:nil
             usingHttpDNS:usingHttpDNS];
    }
}

#pragma mark - Request WBITask
- (void)sendRequest:(NSMutableURLRequest *)request
            WBITask:(WBInternalDataTask *)task
     withIdentifier:(nullable NSString *)identifier
      httpDNSResult:(nullable WBInternalHttpDNSResult *)httpDNSResult
        taskMetrics:(nullable WBInternalTaskMetrics *)taskMetrics
       usingHttpDNS:(BOOL)usingHttpDNS
{
    WBISuccessBlock success = (WBISuccessBlock)task.successBlock;
    WBIFailureBlock failure = (WBIFailureBlock)task.failureBlock;
    NSURLSessionTask *dataTask = [self generateSessionTask:task
                                                   request:request
                                                   success:success
                                                   failure:failure
                                             httpDNSResult:httpDNSResult
                                               taskMetrics:taskMetrics];
    dataTask.internalTaskIdentifier = identifier;
    task.task = dataTask;
    dataTask.usingHttpDNS = usingHttpDNS;
    dataTask.httpDNSResult = httpDNSResult;
    dataTask.wbinternalTaskMetrics = taskMetrics;
    NSLog(@"task created,task:%@,identifier:%@,usingHttpDNS:%ld,httpDNSResult:%@",dataTask,dataTask.internalTaskIdentifier,dataTask.usingHttpDNS,dataTask.httpDNSResult);
    [dataTask resume];
}

- (nullable NSURLSessionTask *)generateSessionTask:(nonnull WBInternalTask *)wbTask
                                           request:(nonnull NSMutableURLRequest *)request
                                           success:(nullable WBISuccessBlock)success
                                           failure:(nullable WBIFailureBlock)failure
                                     httpDNSResult:(nullable WBInternalHttpDNSResult *)httpDNSResult
                                       taskMetrics:(nullable WBInternalTaskMetrics *)taskMetrics
{
    __block NSURLSessionTask *sessionTask = nil;
    void (^completionHandler)(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) = ^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error){
        [self dispatchResponse:responseObject
                       success:success
                       failure:failure
                        wbTask:wbTask
                         error:error
                       request:request
                 httpDNSResult:httpDNSResult
                   taskMetrics:taskMetrics
                   sessionTask:sessionTask];
    };
    if (wbTask.requestType == VolatileCachedDownloadRequest)
    {
        sessionTask = [self.httpSessionManager downloadTaskWithRequest:request
                                                              progress:wbTask.downloadProgressBlock
                                                           destination:((WBInternalVolatileCachedDownloadTask *)wbTask).destinationBlock
                                                     completionHandler:completionHandler];
    }
    else if (wbTask.requestType == UploadRequest)
    {
        sessionTask = [self.httpSessionManager uploadTaskWithRequest:request
                                                            fromFile:((WBInternalUploadTask *)wbTask).localFileURL
                                                            progress:wbTask.uploadProgressBlock
                                                   completionHandler:completionHandler];
    }
    else if (wbTask.requestType == PostMultiPartRequest)
    {
        sessionTask = [self.httpSessionManager uploadTaskWithStreamedRequest:request
                                                                    progress:wbTask.uploadProgressBlock
                                                           completionHandler:completionHandler];
    }
    else
    {
        sessionTask = [self.httpSessionManager dataTaskWithRequest:request
                                                    uploadProgress:wbTask.uploadProgressBlock
                                                  downloadProgress:wbTask.downloadProgressBlock
                                                 completionHandler:completionHandler];
    }
    return sessionTask;
}

#pragma mark -
- (void)dispatchResponse:(id _Nullable)responseObject
                 success:(nullable WBISuccessBlock)success
                 failure:(nullable WBIFailureBlock)failure
                  wbTask:(nonnull WBInternalTask *)task
                   error:(nullable NSError *)error
                 request:(nonnull NSMutableURLRequest *)request
           httpDNSResult:(nullable WBInternalHttpDNSResult *)httpDNSResult
             taskMetrics:(nullable WBInternalTaskMetrics *)taskMetrics
             sessionTask:(nullable NSURLSessionTask *)sessionTask
{
    NSLog(@"task finished excution,task:%@,identifier:%@,usingHttpDNS:%ld,httpDNSResult:%@",sessionTask,sessionTask.internalTaskIdentifier,sessionTask.usingHttpDNS,sessionTask.httpDNSResult);
    /// 设置log相关数据，业务方会需要log数据
    [self addCronetLogToRequest:sessionTask.currentRequest
                           task:sessionTask
                    taskMetrics:taskMetrics
                          error:error];
    if (error)
    {
        //业务层执行了取消请求操作，主动执行的取消操作，不记录log
        if (sessionTask.state == NSURLSessionTaskStateCanceling)
        {
            if (failure)
            {
                failure(sessionTask,error);
            }
            return;
        }
        //采用HttpDNS查询，并且有有效的httpdns查询结果
        //一定是IP直连，并且继续走IP直连
        if (sessionTask.usingHttpDNS && httpDNSResult)
        {
            //IP更换Host
            NSURL *url = [request.URL copy];
            BOOL ipReplaceResult = [httpDNSResult tryIPReplaceURLHost:&url];
            if (ipReplaceResult)
            {
                request.URL = url;
                //服务器地址
                taskMetrics.remoteAddress = url.host;
            }
            else
            {
                //如果已经全部IP直连试过，则走LocalDNS
                sessionTask.usingHttpDNS = NO;
                NSString *host = [request valueForHTTPHeaderField:@"HOST"];
                //request中未设置host值，将请求错误结果直接返回到上层，不执行重发送请求机制。
                if ([NSString isEmptyString:host])
                {
                    if (failure)
                    {
                        failure(sessionTask, error);
                    }
                    return;
                }
                //替换ip为host，执行localdns形式的请求
                NSURL *hostURL = [httpDNSResult replaceURLHost:request.URL
                                                        byHost:host];
                request.URL = hostURL;
            }
            [self sendRequest:request
                      WBITask:(WBInternalDataTask *)task
               withIdentifier:sessionTask.internalTaskIdentifier
                httpDNSResult:httpDNSResult
                  taskMetrics:taskMetrics
                 usingHttpDNS:sessionTask.usingHttpDNS];
            return;
        }
        //重试结束，仍然请求失败，回调失败结果给上层。
        if (failure)
        {
            failure(sessionTask,error);
        }
    }
    else
    {
        if (success)
        {
            success(sessionTask,responseObject);
        }
    }
}

#pragma mark - helper method
- (NSMutableURLRequest *)buildRequestWithHTTPMethod:(NSString *)method
                                          URLString:(NSString *)URLString
                                         parameters:(nullable id)parameters
                                            headers:(nullable NSDictionary <NSString *, NSString *> *)headers
{
    WBInternalAFHTTPRequestSerializer *requestSerializer = nil;
    if ([NSString isEmptyString:method]) method = @"";
     NSDictionary<NSString *,NSNumber *> *methodsType = @{GetRequestKey:@(YES),
                                                          HeadRequestKey:@(YES),
                                                          DeleteRequestKey:@(YES)
                                                        };
    BOOL usingHTTPDefaultSerializer = [methodsType objectForKey:method.lowercaseString].boolValue;
    //UsingFormURLEncodedKey
    if (!usingHTTPDefaultSerializer &&
        parameters &&
        [parameters isKindOfClass:[NSDictionary class]])
    {
        NSNumber *usingGetSerializer = [(NSDictionary *)parameters objectForKey:UsingFormURLEncodedKey];
        if (usingGetSerializer)
        {
            NSMutableDictionary *newParameters = [(NSDictionary *)parameters mutableCopy];
            [newParameters removeObjectForKey:UsingFormURLEncodedKey];
            parameters = [newParameters copy];
            usingHTTPDefaultSerializer = YES;
        }
    }

    if (usingHTTPDefaultSerializer)
    {
        requestSerializer = [self.requestSerializers objectForKey:GetRequestKey];
    }
    else
    {
        requestSerializer = [self.requestSerializers objectForKey:POSTRequestKey];
    }
    //`GET`, `HEAD`, and `DELETE`方法，默认采用urlencode方式，
    //符合http协议，不会导致莫名的错误
    if (!usingHTTPDefaultSerializer &&
        parameters &&
        [parameters isKindOfClass:[NSDictionary class]])
    {
        NSNumber *usingGetSerializer = [(NSDictionary *)parameters objectForKey:UsingGetRequestSerializerKey];
        if (usingGetSerializer)
        {
            requestSerializer = [self.requestSerializers objectForKey:GetRequestKey];
            NSMutableDictionary *newParameters = [(NSDictionary *)parameters mutableCopy];
            [newParameters removeObjectForKey:UsingGetRequestSerializerKey];
            parameters = [newParameters copy];
        }
    }
    NSError *serializationError = nil;
    NSURL *hostURL = [NSURL URLWithString:URLString relativeToURL:self.httpSessionManager.baseURL];
    URLString = hostURL.absoluteString;
    parameters = [self requestAdditionalParametersHandle:hostURL originParameters:parameters];
    //build request
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:method URLString:URLString parameters:parameters error:&serializationError];
    if (serializationError)
    {
        return nil;
    }
    for (NSString *headerField in headers.keyEnumerator)
    {
        [request addValue:headers[headerField] forHTTPHeaderField:headerField];
    }
    [self requestAdditionalHeaderHandle:request];
    return request;
}

- (NSMutableURLRequest *)buildMultipartRequestWithURLString:(NSString *)URLString
                                                 parameters:(nullable id)parameters
                                  constructingBodyWithBlock:(void (^)(id <WBInternalAFMultipartFormData> formData))block
                                                    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
{
    NSError *serializationError = nil;
    WBInternalAFHTTPRequestSerializer *requestSerializer = [self.requestSerializers objectForKey:GetRequestKey];
    NSURL *hostURL = [NSURL URLWithString:URLString
                            relativeToURL:self.httpSessionManager.baseURL];
    parameters = [self requestAdditionalParametersHandle:hostURL originParameters:parameters];
    URLString = hostURL.absoluteString;
    NSMutableURLRequest *request = [requestSerializer multipartFormRequestWithMethod:@"POST"
                                                                           URLString:URLString
                                                                          parameters:parameters
                                                           constructingBodyWithBlock:block
                                                                               error:&serializationError];
    if (serializationError)
    {
        return nil;
    }
    for (NSString *headerField in headers.keyEnumerator)
    {
        [request addValue:headers[headerField] forHTTPHeaderField:headerField];
    }
    [self requestAdditionalHeaderHandle:request];
    return request;
}

- (nullable NSDictionary *)divisionMultipartParameters:( NSDictionary * _Nonnull *)parameters
{
    NSMutableDictionary *files = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *others = [*parameters mutableCopy];
    [*parameters enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[NSURL class]])
        {
            [files setObject:obj forKey:key];
            [others removeObjectForKey:key];
        }
    }];
    *parameters = others;
    if (files.count > 0 ) return files;
    return nil;
}

#pragma mark - additional header parameters
- (id)requestAdditionalParametersHandle:(nonnull NSURL *)url
                       originParameters:(NSDictionary *)originParameters
{
    if (!originParameters ||
        ![originParameters isKindOfClass:[NSDictionary class]])
    {
        return originParameters;
    }
    if (!self.addAdditionalRequestParametersBlock ||
        !self.additionalRequestParametersBlock)
    {
        return originParameters;
    }
    if (!self.addAdditionalRequestParametersBlock(url)) return originParameters;
    NSMutableDictionary *mDict = [originParameters mutableCopy];
    NSDictionary *aDict = self.additionalRequestParametersBlock();
    if (aDict &&
        [aDict isKindOfClass:[NSDictionary class]])
    {
        [mDict addEntriesFromDictionary:aDict];
    }
    return mDict;
}

- (void)requestAdditionalHeaderHandle:(nonnull NSMutableURLRequest *)request
{
    if (!self.addAdditionalRequestHeadersBlock ||
        !self.additionalRequestHeadersBlock)
    {
        return;
    }
    if (!self.addAdditionalRequestHeadersBlock(request)) return;
    NSDictionary<NSString *,NSString *> *header = self.additionalRequestHeadersBlock();
    if (header &&
        [header isKindOfClass:[NSDictionary class]] &&
        request)
    {
        [header enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [request setValue:obj forHTTPHeaderField:key];
        }];
    }
}

#pragma mark - requestParametersCached
- (void)storeReuqestParameters:(nullable id)parameters
                   withRequest:(nullable NSURLRequest *)request
{
    if (!parameters) return;
    NSString *key = [self requestParametersCachedKey:request];
    if (key)
    {
        [self.requestParametersCached setObject:parameters forKey:key];
    }
}

- (nonnull id)requestParameters:(nullable NSURLRequest *)request
{
    if (!request) return nil;
    NSString *key = [self requestParametersCachedKey:request];
    if (key)
    {
        id parameters = [self.requestParametersCached objectForKey:key];
        [self.requestParametersCached removeObjectForKey:key];
        return parameters;
    }
    return nil;
}

- (nullable NSString *)requestParametersCachedKey:(nullable NSURLRequest *)request
{
    if (!request) nil;
    return [NSString stringWithFormat:@"%p",request];
}

#pragma mark - Http DNS
- (BOOL)canUsingHttpDNS:(nonnull NSURLRequest *)request
{
    BOOL using = NO;
    if (self.excludeHostUsingHTTPDNS &&
        self.excludeHostUsingHTTPDNS(request))
    {
        return using;
    }
    using = (![NSString isIPHost:request.URL.host] &&
            self.httpDNSManager.resolveBlock);
    return using;
}

#pragma mark -
- (NSMutableURLRequest *)addHostHeaderToRequest:(nonnull NSURLRequest *)request
{
    if (!request) return nil;
    NSString *host = request.URL.host;
    if ([NSString isIPHost:host]) return [request mutableCopy];
    NSMutableURLRequest *mRequest = [request mutableCopy];
    if (![NSString isEmptyString:host] && ![request valueForHTTPHeaderField:@"host"])
    {
        [mRequest addValue:host forHTTPHeaderField:@"host"];
    }
    return mRequest;
}

- (BOOL)enableHttpDNSFeature
{
    BOOL enable = [self.httpDNSManager checkUsingHttpDNS];
    return enable;
}

#pragma mark - deprecated
- (void)addCronetLogToRequest:(nonnull NSURLRequest *)request
                         task:(nonnull NSURLSessionTask *)task
                  taskMetrics:(nullable WBInternalTaskMetrics *)taskMetrics
                        error:(nullable NSError *)error
{
    WBInternalRequestStatus status = error ? FAILED : SUCCESS;
    taskMetrics.requestStatus = status;

//    [request wbt_setObject:[task.cronet_log copy] forAssociatedKey:@"cronet_log" retained:YES];
//    [request wbt_setObject:[task.cronet_start_end copy] forAssociatedKey:@"cronet_start_end" retained:YES];
}

#pragma mark -
- (nullable NSError *)validResponse:(id)response
                       httpResponse:(nonnull NSHTTPURLResponse *)httpResponse
{
    NSError *er = [self parseResponseData:response];
    if (!er) er = [self parseHttpResponse:httpResponse];
    return er;
}

- (nullable NSError *)parseResponseData:(id)response
{
    NSError *businessEr = nil;
    if (response && [response isKindOfClass:[NSDictionary class]])
    {
//        businessEr = [WBInternalBusiness bussinessErrorFromResponseObject:response];
    }
    return businessEr;
}

- (nullable NSError *)parseHttpResponse:(NSHTTPURLResponse *)httpResponse
{
    return nil;// [WBInternalErrorDomain parseHttpResponse:httpResponse];
}

@end
