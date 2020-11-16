//
//  ViewController.h
//  Zoomed
//
//  Created by jungao on 2020/11/3.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

//可以通过消息转发机制+分类重写+runtimeAPI，实现无感知调用父类方法，然后再执行子类方法。
//分类，override方法，并调用父类一个自定义方法
//父类自定义方法，实现需要的功能，同时通过runtime获取子类的方法，并且调用它们

@end

