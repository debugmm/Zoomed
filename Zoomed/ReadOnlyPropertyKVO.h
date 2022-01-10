//
//  ReadOnlyPropertyKVO.h
//  Zoomed
//
//  Created by jungao on 2021/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Person;

@interface ReadOnlyPropertyKVO : NSObject

+ (instancetype)sharedManager;

@end

NS_ASSUME_NONNULL_END
