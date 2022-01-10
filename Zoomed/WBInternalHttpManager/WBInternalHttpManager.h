//
//  WBInternalHttpManager.h
//  Weibo
//
//  Created by jungao on 2020/7/7.
//  Copyright © 2020 Sina. All rights reserved.
//

#if !__has_feature(modules)
#import <Foundation/Foundation.h>
#else
@import Foundation;
#endif
#import "WBInternalBlockDefine.h"

@class WBInternalDataTask;
@class WBInternalUploadTask;
@class WBInternalDownloadTask;
@class WBInternalVolatileCachedDownloadTask;

NS_ASSUME_NONNULL_BEGIN

@interface WBInternalHttpManager : NSObject
/// ===============================
/// 1. 所有实例生成方法，每次调用都生成新的实例
///
/// 2. 默认同时支持JSON、XML、plist格式Response数据解析
///    如果默认的类，解析不了Response，
///    success block回调方法返回的是原始数据（NSData）
///
/// 3. 默认安全策略为：验证服务器公钥（和浏览器证书验证相同）
///
/// 4. Get、Head、Delete方法参数按照http协议定义方式设置（参数编码到URL中）
///
/// 5. 其他所有方法参数（除multipart请求）都按照POST方法参数设置（参数JSON格式添加至Body中）
///
///    5.1. 需要form-urlencoded形式，采用url-encode形式编码后放入Body中
///         在parameters中添加：UsingFormURLEncodedKey:@YES，即可
///    5.2. multipart form/data，按照HTTP协议方式将参数放入Body中
///
/// 6. 如果想更改参数设置方式，在请求方法parameters中添加
///    UsingGetRequestSerializerKey : @(YES)
///    此时parameters类型一定要是NSDictionary
///    任何方法参数设置，只要设置了这个值，那么将按照Get方法参数设置（url编码参数）
///    否则，采用5、6规定的形式设置与编码参数
/// ===============================
#pragma mark - Key define
//在parameters中UsingGetRequestSerializerKey:@YES，表示此方法采用Get方式请求，即：参数编码到url中
FOUNDATION_EXPORT NSString * const UsingGetRequestSerializerKey;
//在parameters中，UsingFormURLEncodedKey:@YES，表示参数使用urlencode方式编码，然后设置到body中
FOUNDATION_EXPORT NSString * const UsingFormURLEncodedKey;

/// ABTest Key define
FOUNDATION_EXPORT NSString * const WBIABTPostAPIKey;
FOUNDATION_EXPORT NSString * const WBIABTGetAPIKey;
FOUNDATION_EXPORT NSString * const WBIABTPutAPIKey;
FOUNDATION_EXPORT NSString * const WBIABTDeleteAPIKey;
FOUNDATION_EXPORT NSString * const WBIABTUploadAPIKey;
FOUNDATION_EXPORT NSString * const WBIABTDownloadAPIKey;

FOUNDATION_EXPORT NSString * const WBIABTInterceptPathKeyFormat;

/// interface日志中WBINewNetFrameworkKey = 1，表示采用了新网络库执行网络请求
FOUNDATION_EXPORT NSString * const WBINewNetFrameworkKey;
FOUNDATION_EXPORT NSString * const WBINewNetFrameworkValue;

#pragma mark - instance
/// Default SessionConfiguration配置
+ (instancetype)httpManager;

/// Background SessionConfiguration配置
+ (instancetype)httpManagerOfBackground;
/// Ephemeral SessionConfiguration配置
+ (instancetype)httpManagerOfEphemeral;
#pragma mark -
/// Default SessionConfiguration配置
/// @param url base url
- (instancetype)initWithBaseURL:(nullable NSURL *)url;

/// Background SessionConfiguration配置
/// @param url base url
/// @param backgroundId id
/// @discussion backgroundId值不能为空或者nil，否则返回nil
- (instancetype)initWithBaseURL:(nullable NSURL *)url
          OfBackgroundManagerId:(NSString *)backgroundId;

/// Ephemeral SessionConfiguration配置
/// @param url base url
- (instancetype)initWithBaseURLOfEphemeral:(nullable NSURL *)url;

/// 指定的初始化方法
/// @param url base url
/// @param configuration session config
- (instancetype)initWithBaseURL:(nullable NSURL *)url
           sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;

#pragma mark - property
/// Request附加参数
/// 业务方可以在此处实现添加附加的参数
@property (nonatomic, copy, nullable) NSDictionary * (^additionalRequestParametersBlock)(void);
/// 是否添加附加的Request参数
@property (nonatomic, copy, nullable) BOOL (^addAdditionalRequestParametersBlock)(NSURL *currentURL);
#pragma mark -
/// Request附加Header
/// 业务方可以在此处实现添加附加的Header
@property (nonatomic, copy, nullable) NSDictionary<NSString *,NSString *> * (^additionalRequestHeadersBlock)(void);
/// 是否添加附加的Request Header
@property (nonatomic, copy, nullable) BOOL (^addAdditionalRequestHeadersBlock)(NSURLRequest *currentRequest);

/// 是否排除当前Host，不使用公司自研HttpDNS功能
@property (nonatomic, copy, nullable) BOOL (^excludeHostUsingHTTPDNS)(NSURLRequest *currentRquest);

#pragma mark - HTTP Request

#pragma mark Get Request
/// 发送HTTP Get请求
/// @param URL URLString
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看下面Get方法中Discussion
- (nullable WBInternalDataTask *)getWithURL:(NSString *)URLString
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure;
/// 发送HTTP Get请求
/// @param URL URLString Get请求URLString（比如：https://www.weibo.com/login）
/// @param parameters Get请求参数
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看下面Get方法中Discussion
- (nullable WBInternalDataTask *)getWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP Get请求
/// @param URLString URLString
/// @param downloadProgress downloadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)getWithURL:(NSString *)URLString
                                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP Get请求
/// @param URLString URLString
/// @param parameters parameters
/// @param downloadProgress downloadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)getWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP Get请求
/// @param URL  URLString Get请求URLString（比如：https://www.weibo.com/login）
/// @param parameters Get请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param downloadProgress 请求进度
/// @param success 请求成功回调（网络正确返回了数据）
/// @param failure 请求失败回调（网络错误或者取消了一个待发送的请求，都会引发失败failure block回调）
/// @discussion 请求成功与失败，是指网络错误、被主动cancel、意外导致（app被kill掉），不是指服务器没有参数或者参数错误
- (nullable WBInternalDataTask *)getWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                   progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure;

#pragma mark -
/// 发送HTTP Get请求
/// @param request request
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)getWithRequest:(NSURLRequest *)request
                                        success:(nullable WBIDataTaskSuccessBlock)success
                                        failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP Get请求
/// @param request request
/// @param downloadProgress downloadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)getWithRequest:(NSURLRequest *)request
                                       progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgress
                                        success:(nullable WBIDataTaskSuccessBlock)success
                                        failure:(nullable WBIDataTaskFailureBlock)failure;

#pragma mark - POST Request
/// 发送HTTP POST请求
/// @param URL URLString POST请求URLString
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP POST请求
/// @param URLString POST请求URLString
/// @param parameters 请求参数
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP POST请求
/// @param URLString URLString
/// @param parameters parameters
/// @param uploadProgress uploadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                    progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP POST请求
/// @param URLString POST请求URLString
/// @param parameters 请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP POST请求
/// @param URL URLString POST请求URLString
/// @param parameters 请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param uploadProgress 请求进度
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)postWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                    progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure;

#pragma mark -
/// 发送HTTP POST请求
/// @param request request
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)postWithRequest:(NSURLRequest *)request
                                         success:(nullable WBIDataTaskSuccessBlock)success
                                         failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP POST请求
/// @param request request
/// @param uploadProgress uploadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)postWithRequest:(NSURLRequest *)request
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIDataTaskSuccessBlock)success
                                         failure:(nullable WBIDataTaskFailureBlock)failure;

#pragma mark - POST Multi Part
/// multi part 请求
/// @param URLString URLString
/// @param parameters 需要上传的数据（key : value）
///        value可以是字符串、数字、NSData、FileURL；
///        其他类或者自定义类无法实现上传数据目的。
/// @param success success
/// @param failure failure
- (nullable WBInternalUploadTask *)postMultipartWithURL:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                                                success:(nullable WBIUploadTaskSuccessBlock)success
                                                failure:(nullable WBIUploadTaskFailureBlock)failure;

/// multi part 请求
/// @param URLString URLString
/// @param parameters 需要上传的数据（key : value）
///        value可以是字符串、数字、NSData、FileURL；
///        其他类或者自定义类无法实现上传数据目的。
/// @param uploadProgress uploadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalUploadTask *)postMultipartWithURL:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                success:(nullable WBIUploadTaskSuccessBlock)success
                                                failure:(nullable WBIUploadTaskFailureBlock)failure;

/// multi part 请求
/// @param URLString 请求URLString
/// @param parameters 需要上传的数据（key : value）
///        value可以是字符串、数字、NSData、FileURL；
///        其他类或者自定义类无法实现上传数据目的。
///
/// @param headers 额外添加的header
/// @param uploadProgress 进度
/// @param success 成功回调
/// @param failure 失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalUploadTask *)postMultipartWithURL:(NSString *)URLString
                                             parameters:(NSDictionary *)parameters
                                                headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                               progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                success:(nullable WBIUploadTaskSuccessBlock)success
                                                failure:(nullable WBIUploadTaskFailureBlock)failure;


/// multi part 请求
/// @param request request
/// @param uploadProgress uploadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalUploadTask *)postMultipartWithRequest:(NSURLRequest *)request
                                                   progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                                    success:(nullable WBIUploadTaskSuccessBlock)success
                                                    failure:(nullable WBIUploadTaskFailureBlock)failure;

#pragma mark - Upload Request
/// 发送HTTP文件上传请求
/// @param URLString 文件上传请求URLString
/// @param filePath 上传文件路径
/// @param uploadProgress 上传进度
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalUploadTask *)uploadWithURL:(NSString *)URLString
                                        fromFile:(NSString *)filePath
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIUploadTaskSuccessBlock)success
                                         failure:(nullable WBIUploadTaskFailureBlock)failure;

/// 发送HTTP文件上传请求
/// @param URLString 文件上传请求URLString
/// @param parameters 请求参数
/// @param filePath 上传文件路径
/// @param uploadProgress 上传进度
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalUploadTask *)uploadWithURL:(NSString *)URLString
                                      parameters:(nullable id)parameters
                                        fromFile:(NSString *)filePath
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIUploadTaskSuccessBlock)success
                                         failure:(nullable WBIUploadTaskFailureBlock)failure;

/// 发送HTTP文件上传请求
/// @param URLString 文件上传请求URLString
/// @param parameters 请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param filePath 上传文件路径
/// @param uploadProgress 上传进度
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalUploadTask *)uploadWithURL:(NSString *)URLString
                                      parameters:(nullable id)parameters
                                         headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                        fromFile:(NSString *)filePath
                                        progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                         success:(nullable WBIUploadTaskSuccessBlock)success
                                         failure:(nullable WBIUploadTaskFailureBlock)failure;

/// 发送HTTP文件上传请求
/// @param request request
/// @param filePath filePath
/// @param uploadProgress uploadProgress
/// @param success success
/// @param failure failure
- (nullable WBInternalUploadTask *)uploadWithRequest:(NSURLRequest *)request
                                            fromFile:(NSString *)filePath
                                            progress:(nullable void (^)(NSProgress *uploadProgress))uploadProgress
                                             success:(nullable WBIUploadTaskSuccessBlock)success
                                             failure:(nullable WBIUploadTaskFailureBlock)failure;

#pragma mark - Download Request
/// 发送HTTP数据下载请求
/// 系统管理下载过程中的数据缓存;
/// 这个缓存数据大部分情况下都只在APP运行期间存在
/// APP退出之后，缓存可能不存在，也就是不能断点下载续传
///
/// @param URLString 请求URLString
/// @param downloadProgressBlock 下载进度
/// @param destination 下载完成后，文件路径
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure;
/// 发送HTTP数据下载请求
/// 系统管理下载过程中的数据缓存;
/// 这个缓存数据大部分情况下都只在APP运行期间存在
/// APP退出之后，缓存可能不存在，也就是不能断点下载续传
///
/// @param URLString 请求URLString
/// @param headers 额外添加的HTTP Request消息头
/// @param downloadProgressBlock 下载进度
/// @param destination 下载完成后，文件路径
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                           headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure;
/// 发送HTTP数据下载请求
/// 系统管理下载过程中的数据缓存;
/// 这个缓存数据大部分情况下都只在APP运行期间存在
/// APP退出之后，缓存可能不存在，也就是不能断点下载续传
///
/// @param URLString 请求URLString
/// @param parameters 请求参数
/// @param downloadProgressBlock 下载进度
/// @param destination 下载完成后，文件路径
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                        parameters:(nullable id)parameters
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure;

/// 发送HTTP数据下载请求
/// 系统管理下载过程中的数据缓存;
/// 这个缓存数据大部分情况下都只在APP运行期间存在
/// APP退出之后，缓存可能不存在，也就是不能断点下载续传
///
/// @param URLString 请求URLString
/// @param parameters 请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param downloadProgressBlock 下载进度
/// @param destination 下载完成后，文件路径
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithURL:(NSString *)URLString
                                                        parameters:(nullable id)parameters
                                                           headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                                          progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                       destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                           success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                           failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure;

/// 发送HTTP数据下载请求
/// @param request request
/// @param downloadProgressBlock downloadProgressBlock
/// @param destination destination
/// @param success success
/// @param failure failure
- (nullable WBInternalVolatileCachedDownloadTask *)downloadWithRequest:(NSURLRequest *)request
                                                              progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                                                           destination:(nullable NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                                                               success:(nullable WBIVolatileCachedDownloadTaskSuccessBlock)success
                                                               failure:(nullable WBIVolatileCachedDownloadTaskFailureBlock)failure;

#pragma mark - extension Download Request
/// 下载数据（自定义下载断点续传）
/// @param URLString URLString
/// @param taskDidReceiveResponseBlock taskDidReceiveResponseBlock
/// @param taskDidReceiveDataBlock taskDidReceiveDataBlock
/// @param success success
/// @param failure failure
- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure;

/// 下载数据（自定义下载断点续传）
/// @param URLString URLString
/// @param taskDidReceiveResponseBlock taskDidReceiveResponseBlock
/// @param taskDidReceiveDataBlock taskDidReceiveDataBlock
/// @param resumeHttpHeaderFieldsBlock resumeHttpHeaderFieldsBlock
/// @param success success
/// @param failure failure
- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                         resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure;

/// 下载数据（自定义下载断点续传）
/// 支持自定义下载过程中，数据缓存处理
/// 支持自定义的下载断点续传处理
///
/// @param URLString url string
/// @param headers 请求头（更多的是用来设置断点续传相关参数）
/// @param parameters 请求参数
/// @param downloadProgressBlock 下载进度回调block
/// @param taskDidReceiveResponseBlock 服务端响应返回回调block
/// @param taskDidReceiveDataBlock 数据接收回调block
/// @param resumeHttpHeaderFieldsBlock 下载断点续传，头参数设置block
/// @param success 成功回调
/// @param failure 失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDownloadTask *)downloadWithURL:(NSString *)URLString
                                             headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                          parameters:(nullable id)parameters
                                            progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                         taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                             taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                         resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                             success:(nullable WBIDataTaskSuccessBlock)success
                                             failure:(nullable WBIDataTaskFailureBlock)failure;

#pragma mark -
/// 下载数据（自定义下载断点续传）
/// @param request request
/// @param taskDidReceiveResponseBlock taskDidReceiveResponseBlock
/// @param taskDidReceiveDataBlock taskDidReceiveDataBlock
/// @param success success
/// @param failure failure
- (nullable WBInternalDownloadTask *)downloadWithRequest:(NSURLRequest *)request
                             taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                                 taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                                                 success:(nullable WBIDataTaskSuccessBlock)success
                                                 failure:(nullable WBIDataTaskFailureBlock)failure;

/// 下载数据（自定义下载断点续传）
/// @param request request
/// @param downloadProgressBlock downloadProgressBlock
/// @param taskDidReceiveResponseBlock taskDidReceiveResponseBlock
/// @param taskDidReceiveDataBlock taskDidReceiveDataBlock
/// @param resumeHttpHeaderFieldsBlock resumeHttpHeaderFieldsBlock
/// @param success success
/// @param failure failure
- (nullable WBInternalDownloadTask *)downloadWithRequest:(NSURLRequest *)request
                                                progress:(nullable void (^)(NSProgress *downloadProgress))downloadProgressBlock
                             taskDidReceiveResponseBlock:(nullable WBInternalDataTaskDidReceiveResponseBlock)taskDidReceiveResponseBlock
                                 taskDidReceiveDataBlock:(nullable WBInternalDataTaskDidReceiveDataBlock)taskDidReceiveDataBlock
                             resumeHttpHeaderFieldsBlock:(nullable WBInternalResumeTaskHTTPHeaderFieldsBlock)resumeHttpHeaderFieldsBlock

                                                 success:(nullable WBIDataTaskSuccessBlock)success
                                                 failure:(nullable WBIDataTaskFailureBlock)failure;

#pragma mark - Others Request
/// 发送HTTP delete请求
/// @param URLString delete请求URLString
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)deleteWithURL:(NSString *)URLString
                                       success:(nullable WBIDataTaskSuccessBlock)success
                                       failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP delete请求
/// @param URLString delete请求URLString
/// @param parameters 请求参数
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)deleteWithURL:(NSString *)URLString
                                    parameters:(nullable id)parameters
                                       success:(nullable WBIDataTaskSuccessBlock)success
                                       failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP delete请求
/// @param URLString delete请求URLString
/// @param parameters 请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)deleteWithURL:(NSString *)URLString
                                    parameters:(nullable id)parameters
                                       headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                       success:(nullable WBIDataTaskSuccessBlock)success
                                       failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP delete请求
/// @param request request
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)deleteWithRequest:(NSURLRequest *)request
                                           success:(nullable WBIDataTaskSuccessBlock)success
                                           failure:(nullable WBIDataTaskFailureBlock)failure;

#pragma mark -
/// 发送HTTP PUT请求
/// @param URLString URLString
/// @param parameters parameters
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)putWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure;
/// 发送HTTP PUT请求
/// @param URLString PUT请求URLString
/// @param parameters 请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)putWithURL:(NSString *)URLString
                                 parameters:(nullable id)parameters
                                    headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                    success:(nullable WBIDataTaskSuccessBlock)success
                                    failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP PUT请求
/// @param request request
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)putWithRequest:(NSURLRequest *)request
                                        success:(nullable WBIDataTaskSuccessBlock)success
                                        failure:(nullable WBIDataTaskFailureBlock)failure;
#pragma mark -
/// 发送HTTP PATCH请求
/// @param URLString URLString
/// @param parameters parameters
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)patchWithURL:(NSString *)URLString
                                   parameters:(nullable id)parameters
                                      success:(nullable WBIDataTaskSuccessBlock)success
                                      failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP PATCH请求
/// @param URLString PATCH请求URLString
/// @param parameters 请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param success 请求成功回调
/// @param failure 请求失败回调
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)patchWithURL:(NSString *)URLString
                                   parameters:(nullable id)parameters
                                      headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                      success:(nullable WBIDataTaskSuccessBlock)success
                                      failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP PATCH请求
/// @param request request
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)patchWithRequest:(NSURLRequest *)request
                                          success:(nullable WBIDataTaskSuccessBlock)success
                                          failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP Head请求
/// @param URLString Head请求URLString
/// @param parameters Head请求参数
/// @param headers 额外添加的HTTP Request消息头
/// @param success 请求成功回调（网络正确返回了数据）
/// @param failure 请求失败回调（网络错误或者取消了一个待发送的请求，都会引发失败failure block回调）
/// @discussion 关于请求成功与失败解释，参看Get请求中的讨论
- (nullable WBInternalDataTask *)headWithURL:(NSString *)URLString
                                  parameters:(nullable id)parameters
                                     headers:(nullable NSDictionary <NSString *, NSString *> *)headers
                                     success:(nullable WBIDataTaskSuccessBlock)success
                                     failure:(nullable WBIDataTaskFailureBlock)failure;

/// 发送HTTP Head请求
/// @param request request
/// @param success success
/// @param failure failure
- (nullable WBInternalDataTask *)headWithRequest:(NSURLRequest *)request
                                         success:(nullable WBIDataTaskSuccessBlock)success
                                         failure:(nullable WBIDataTaskFailureBlock)failure;

@end

NS_ASSUME_NONNULL_END
