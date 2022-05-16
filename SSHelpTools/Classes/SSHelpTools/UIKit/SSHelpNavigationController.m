//
//  SSHelpNavigationController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/4/6.
//

#import "SSHelpNavigationController.h"
#import "SSHelpDefines.h"

@interface SSHelpNavigationController ()<UINavigationControllerDelegate,UIGestureRecognizerDelegate>

@end

@implementation SSHelpNavigationController

- (void)dealloc
{
    SSToolsLog(@"%@ dealloc %td...",self,_kRetainCount(self));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = SSHELPTOOLSCONFIG.backgroundColor;
    
    /// 适配>>导航栏
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.titleTextAttributes = SSHELPTOOLSCONFIG.navbarAppearance.titleTextAttributes;
        appearance.backgroundColor = SSHELPTOOLSCONFIG.navbarAppearance.backgroundColor;
        appearance.backgroundImage = SSHELPTOOLSCONFIG.navbarAppearance.backgroundImage;
        appearance.backgroundEffect = SSHELPTOOLSCONFIG.navbarAppearance.backgroundEffect;
        appearance.shadowColor = SSHELPTOOLSCONFIG.navbarAppearance.shadowColor;
        appearance.shadowImage = SSHELPTOOLSCONFIG.navbarAppearance.shadowImage;

        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;

    } else {
        [self.navigationBar setTitleTextAttributes:SSHELPTOOLSCONFIG.navbarAppearance.titleTextAttributes];
        [self.navigationBar setBarTintColor:SSHELPTOOLSCONFIG.navbarAppearance.backgroundColor];
        [self.navigationBar setBackgroundImage:SSHELPTOOLSCONFIG.navbarAppearance.backgroundImage
                                 forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setTranslucent:NO];
        [self.navigationBar setShadowImage:SSHELPTOOLSCONFIG.navbarAppearance.shadowImage];
    }

    /// 适配>>边缘返回手势
    /// Tip:https://developer.aliyun.com/article/853626
    if (!self.interactivePopGestureRecognizerDisable && [self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        __weak typeof(self) __weak_self = self;
        self.interactivePopGestureRecognizer.delegate = (id)__weak_self;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.topViewController;
}

//- (BOOL)shouldForceEnableInteractivePopGestureRecognizer
//{
//
//    return YES;
//}
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

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.childViewControllers.count==1) {
        //Push到下一级页面，默认隐藏底部工具栏
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
