//
//  main.m
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "ScreenBoundsPrint.h"

#import "fishhook.h"
#include <dlfcn.h>
#include <dns_sd.h>

static int (*origin_getaddrinfo)(const char * __restrict, const char * __restrict, const struct addrinfo * __restrict, struct addrinfo ** __restrict);
int my_getaddrinfo(const char *a, const char *b, const struct addrinfo *c, struct addrinfo **d){
    //DNS解析开始
    int result = origin_getaddrinfo(a,b,c,d);
    //DNS解析结束
    return result;
}

void hookGetAddrinfo(void)
{
//    static dispatch_once_t rebind;
//    dispatch_once(&rebind, ^{
//        origin_getaddrinfo = dlsym(RTLD_DEFAULT, "getaddrinfo");
//        int result = rebind_symbols((struct rebinding[1]){{"getaddrinfo",my_getaddrinfo}}, 1);
//        NSLog(@"");
//    });
    void *lib = dlopen("/usr/lib/system/libsystem_info.dylib", RTLD_NOW);//libsystem_info.dylib libsystem_dnssd.dylib
    origin_getaddrinfo = dlsym(lib, "getaddrinfo");//dlsym(lib, "getaddrinfo");
    struct rebinding getaddrinfoRebinding;//{"getaddrinfo", my_getaddrinfo, (void*)&origin_getaddrinfo};// {"getaddrinfo", my_getaddrinfo, (void*)&origin_getaddrinfo}
    getaddrinfoRebinding.name = "getaddrinfo";
    getaddrinfoRebinding.replacement = (void *)my_getaddrinfo;
    getaddrinfoRebinding.replaced = (void *)&origin_getaddrinfo;
    struct rebinding rebs[1] = {getaddrinfoRebinding};
    int result = rebind_symbols(rebs, 1);
    NSLog(@"");
}

int main(int argc, char * argv[]) {
    NSString * appDelegateClassName;
    hookGetAddrinfo();
    int fd = open(argv[0], O_RDONLY);
    uint32_t magic_number = 0;
    read(fd, &magic_number, 4);
    printf("Mach-O Magic Number: %x \n", magic_number);
    close(fd);

    @autoreleasepool {
        // Setup code that might create autoreleased objects goes here.
        appDelegateClassName = NSStringFromClass([AppDelegate class]);
    }
    [ScreenBoundsPrint screenBoundsPrint:@"main"];
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
