//
//  UIViewController+PrivateCategory.m
//  Zoomed
//
//  Created by jungao on 2020/11/16.
//

#import "UIViewController+PrivateCategory.h"
#import "PrivateConstString.h"
#import <objc/runtime.h>

@implementation UIViewController (PrivateCategory)

- (void)viewDidLayoutSubviews
{
    if ([self respondsToSelector:@selector(_privateViewDidLayoutSubviews)])
    {
        [self _privateViewDidLayoutSubviews];
    }
    else
    {
        //读取子类实现的viewDidLayoutSubviews方法，并调用。
        [self _privatePerformMethodListWithMethodName:ViewDidLayoutSubviewsMethodName parameters:nil];
    }
}

#pragma mark - helper
- (void)_privateViewDidLayoutSubviews {
    if (self.safeAreaBlock)
    {
        CGFloat topLayoutLength = self.topLayoutGuide.length;
        CGFloat bottomLayoutLength = self.bottomLayoutGuide.length;
        CGFloat w = [UIScreen mainScreen].bounds.size.width;
        CGFloat h = [UIScreen mainScreen].bounds.size.height;
        CGFloat top = topLayoutLength;
        CGFloat bottom = bottomLayoutLength;
        self.safeAreaBlock(top, bottom, w, h, 0, 0);
    }
    [self _privatePerformMethodListWithMethodName:ViewDidLayoutSubviewsMethodName parameters:nil];
}

#pragma mark - 
- (void)_privatePerformMethodListWithMethodName:(nonnull NSString *)methodNameString
                                     parameters:(nullable NSArray *)parameters
{
    //读取子类ViewDidLayoutSubviews方法，并执行
    unsigned int methodCount = 0;
    Method *methodList = class_copyMethodList([self class], &methodCount);
    for (unsigned int i=1; i<methodCount; i++)
    {
        Method method = methodList[i];
        //viewDidLayoutSubviews
        NSString *methodName = NSStringFromSelector(method_getName(method));
        if ([methodName isEqualToString:methodNameString])
        {
            [self _privatePerformSelector:method_getName(method) withObjects:parameters];
        }
    }
}

//可以传多个参数的方法
- (id)_privatePerformSelector:(SEL)selector withObjects:(nullable NSArray *)parameters
{
    // 方法签名(方法的描述)
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    if (signature == nil) {
        //可以抛出异常也可以不操作。
    }
    // NSInvocation : 利用一个NSInvocation对象包装一次方法调用（方法调用者、方法名、方法参数、方法返回值）
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;

    //设置参数
    NSInteger paramsCount = signature.numberOfArguments - 2; // 除self、_cmd以外的参数个数
    if (parameters && parameters.count > 0)
    {
        paramsCount = MIN(paramsCount, parameters.count);
        for (NSInteger i = 0; i < paramsCount; i++)
        {
            id object = parameters[i];
            if ([object isKindOfClass:[NSNull class]]) continue;
            [invocation setArgument:&object atIndex:i + 2];
        }
    }
    // 调用方法
    [invocation invoke];
    // 获取返回值
    id returnValue = nil;
    if (signature.methodReturnLength) { // 有返回值类型，才去获得返回值
        [invocation getReturnValue:&returnValue];
    }
    return returnValue;
}

#pragma mark - property
- (SafeAreaBlock)safeAreaBlock
{
    return objc_getAssociatedObject(self, &SafeAreaBlockPropertyKey);
}

- (void)setSafeAreaBlock:(SafeAreaBlock)safeAreaBlock
{
    objc_setAssociatedObject(self, &SafeAreaBlockPropertyKey, safeAreaBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

@end
