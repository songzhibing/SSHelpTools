//
//  UIResponder+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIResponder (SSHelp)

/// 获取视图的视图控制器 eg. uiview.ss_viewController
- (__kindof UIViewController *_Nullable)ss_viewController;

/// 获取sharedApplication.delegate.window.rootViewController
- (__kindof UIViewController *_Nullable)ss_rootViewController;

/// 获取sharedApplication.delegate.window上最顶的视图控制器
- (__kindof UIViewController *_Nullable)ss_windowTopViewController;

/// 获取目标vc上的最顶层的视图控制器
+ (__kindof UIViewController *_Nullable)ss_topViewController:(UIViewController *)vc;

@end

NS_ASSUME_NONNULL_END
