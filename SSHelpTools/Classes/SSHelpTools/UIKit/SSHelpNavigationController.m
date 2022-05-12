//
//  SSHelpNavigationController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/4/6.
//

#import "SSHelpNavigationController.h"
#import "SSHelpDefines.h"

@interface SSHelpNavigationController ()<UINavigationControllerDelegate>

@end

@implementation SSHelpNavigationController

- (void)dealloc
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [_kRandomColor colorWithAlphaComponent:0.25f];
    
    //导航栏适配
//    UIColor *bgColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
////    if (@available(iOS 15.0, *)) {
//        UINavigationBarAppearance *navBar = [[UINavigationBarAppearance alloc] init];
//        navBar.backgroundColor = bgColor;
//        navBar.backgroundEffect = nil;
//        self.navigationController.navigationBar.scrollEdgeAppearance = navBar;
//        self.navigationController.navigationBar.standardAppearance = navBar;
////    } else {
////        // 常规配置方式
////        [self.navigationController.navigationBar setBackgroundImage:[UIImage imageWithColor:bgColor]
////                                                      forBarMetrics:UIBarMetricsDefault];
////    }
    
    //侧滑返回手势
    if (!self.interactivePopGestureRecognizerDisable && [self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        __weak typeof(self) __weak_self = self;
        self.interactivePopGestureRecognizer.delegate = (id)__weak_self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - Autorotation support.

- (BOOL)shouldAutorotate
{
    return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.visibleViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
}

/// Push到下一级页面，默认隐藏底部工具栏
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count==1) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}

#pragma mark - UIGestureRecognizerDelegate Method
 
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.interactivePopGestureRecognizerDisable && gestureRecognizer == self.interactivePopGestureRecognizer) {
        // 屏蔽调用rootViewController的滑动返回手势，避免右滑返回手势引起crash
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
