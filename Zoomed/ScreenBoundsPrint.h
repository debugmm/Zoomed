//
//  ScreenBoundsPrint.h
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScreenBoundsPrint : NSObject

+ (void)screenBoundsPrint:(nonnull NSString *)methodName;

+ (nonnull NSString *)screenInfo;

@end

NS_ASSUME_NONNULL_END
