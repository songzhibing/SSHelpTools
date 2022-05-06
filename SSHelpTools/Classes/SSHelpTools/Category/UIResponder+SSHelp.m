//
//  UIResponder+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "UIResponder+SSHelp.h"

@implementation UIResponder (SSHelp)

/// 获取视图的视图控制器
- (__kindof UIViewController *_Nullable)ss_viewController;
{
    if ([self isKindOfClass:[UIView class]])
    {
        UIResponder *next = [self nextResponder];
        if (next) {
            do {
                if ([next isKindOfClass:[UIViewController class]]) {
                    return (UIViewController *)next;
                }
                next = [next nextResponder];
            } while (next != nil);
        }
    }
    else if([self isKindOfClass:[UIViewController class]])
    {
        return (__kindof UIViewController *)self;
    }
    return nil;
}

/// 获取sharedApplication.delegate.window.rootViewController
- (__kindof UIViewController *_Nullable)ss_rootViewController;
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    return window.rootViewController;
}

/// 获取sharedApplication.delegate.window上最顶的视图控制器
- (__kindof UIViewController *_Nullable)ss_windowTopViewController
{
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    return [UIResponder ss_topViewController:window.rootViewController];
}

/// 获取目标vc上的最顶的视图控制器
+ (__kindof UIViewController *_Nullable)ss_topViewController:(UIViewController *)vc;
{
    if (!vc) return nil;
    
    if (vc.presentedViewController)
    {
        // Return presented view controller
        return [UIResponder ss_topViewController:vc.presentedViewController];
    }
    else if ([vc isKindOfClass:[UINavigationController class]])
    {
        // Return top view
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0)
            return [UIResponder ss_topViewController:svc.topViewController];
        else
            return vc;
    }
    else if ([vc isKindOfClass:[UITabBarController class]])
    {
        // Return visible view
        UITabBarController *svc = (UITabBarController *)vc;
        if (svc.viewControllers.count > 0)
            return [UIResponder ss_topViewController:svc.selectedViewController];
        else
            return vc;
    }
    else
    {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}

@end
