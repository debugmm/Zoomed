//
//  Person.h
//  Zoomed
//
//  Created by jungao on 2021/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Person : NSObject

+ (instancetype)sharedManager;

/**
 *  Unavailable initializer
 */
+ (instancetype)new NS_UNAVAILABLE;

/**
 *  Unavailable initializer
 */
- (instancetype)init NS_UNAVAILABLE;

#pragma mark - property

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSInteger age;
@property (nonatomic, assign) NSInteger sex;

@property (nonatomic, assign, readonly) float height;

@end

NS_ASSUME_NONNULL_END
