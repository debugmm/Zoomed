//
//  WBInternalBlockDefine.h
//  WeiboTechs
//
//  Created by jungao on 2020/11/28.
//

#import <Foundation/Foundation.h>

@class WBInternalDataTask;
@class WBInternalUploadTask;
@class WBInternalDownloadTask;

NS_ASSUME_NONNULL_BEGIN

//WBI：WBInternal
//成功回调block
typedef void (^WBIDataTaskSuccessBlock)(NSURLSessionDataTask * _Nullable task, id _Nullable responseObject);
//失败回调block
typedef void (^WBIDataTaskFailureBlock)(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error);

//成功回调block
typedef void (^WBIUploadTaskSuccessBlock)(NSURLSessionUploadTask * _Nullable task, id _Nullable responseObject);
//失败回调block
typedef void (^WBIUploadTaskFailureBlock)(NSURLSessionUploadTask * _Nullable task, NSError * _Nullable error);

typedef void (^WBIVolatileCachedDownloadTaskSuccessBlock)(NSURLSessionDownloadTask * _Nullable task, id _Nullable responseObject);
typedef void (^WBIVolatileCachedDownloadTaskFailureBlock)(NSURLSessionDownloadTask * _Nullable task, NSError * _Nullable error);

typedef NSURL * _Nullable (^WBIVolatileCachedDownloadTaskDestination)(NSURL *targetPath, NSURLResponse *response);

typedef void (^WBIProgress)(NSProgress *progress);

//扩展请求Parameters参数block（block返回id类型参数：array or dictionary）
//block传入urlPath，提供业务方实现参数生成
typedef id _Nullable (^WBIExtendParametersBlock)(NSString * _Nullable urlPath);

/// WBInternalDownloadTask Block define
typedef void (^WBInternalDataTaskDidReceiveDataBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSData *data);
typedef void (^WBInternalDataTaskDidReceiveResponseBlock)(NSURLSession *session, NSURLSessionDataTask *dataTask, NSURLResponse *response);

typedef NSDictionary<NSString *,NSString *> * _Nullable (^WBInternalResumeTaskHTTPHeaderFieldsBlock)(void);

@interface WBInternalBlockDefine : NSObject

@end

NS_ASSUME_NONNULL_END
