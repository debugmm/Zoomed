//
//  WBInternalTask+Private.h
//  BaseLibs
//
//  Created by jungao on 2020/11/27.
//

#import "WBInternalTask.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, WBInternalRequestType) {
    GetRequest = 1,
    PostRequest = 2,
    UploadRequest = 3,
    DownloadRequest = 4,
    DeleteRequest = 5,
    PUTRequest = 6,
    PatchRequest = 7,
    HeadRequest = 8,
    VolatileCachedDownloadRequest = 9,
    PostMultiPartRequest = 10
};

@class WBInternalHttpManager;

@interface WBInternalTask ()
/// 以下是私有属性，不对外公布
@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, strong) NSMutableURLRequest *originResumeRequest;
@property (nonatomic, weak) WBInternalHttpManager *httpManager;
@property (nonatomic, assign) WBInternalRequestType requestType;

/// 以下属性，可能未来会开放
@property (nonatomic, readonly, assign) int64_t countOfBytesExpectedToReceive;
@property (nonatomic, readonly, assign) int64_t countOfBytesReceived;
@property (nonatomic, readonly, assign) int64_t countOfBytesSent;
@property (nonatomic, strong) id requestParameters;

@end

NS_ASSUME_NONNULL_END
