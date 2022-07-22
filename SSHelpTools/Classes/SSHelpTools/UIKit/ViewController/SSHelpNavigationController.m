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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    SSLifeCycleLog(@"%@ dealloc %td...",self,_kRetainCount(self));
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateNavigationBarAppearance)
                                                     name:SSNavBarAppearanceDidChangeNotification
                                                   object:nil];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = SSHELPTOOLSCONFIG.backgroundColor;
    [self updateNavigationBarAppearance];
    /// 适配>>边缘返回手势
    if (!self.interactivePopGestureRecognizerDisable && [self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        __weak typeof(self) __weak_self = self;
        self.interactivePopGestureRecognizer.delegate = (id)__weak_self;
    }
}

- (void)updateNavigationBarAppearance
{
    SSHelpNavigationBarAppearance *newAppearance = SSHELPTOOLSCONFIG.customNavbarAppearance;
    if (!newAppearance) return;
    
    /// 适配>>导航栏
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.titleTextAttributes = newAppearance.titleTextAttributes;
        appearance.backgroundColor = newAppearance.backgroundColor;
        appearance.backgroundImage = newAppearance.backgroundImage;
        appearance.backgroundEffect = newAppearance.backgroundEffect;
        appearance.shadowColor = newAppearance.shadowColor;
        appearance.shadowImage = newAppearance.shadowImage;
        self.navigationBar.standardAppearance = appearance;
        self.navigationBar.scrollEdgeAppearance = appearance;
    } else {
        [self.navigationBar setTitleTextAttributes:newAppearance.titleTextAttributes];
        [self.navigationBar setBarTintColor:newAppearance.backgroundColor];
        [self.navigationBar setBackgroundImage:newAppearance.backgroundImage
                                 forBarMetrics:UIBarMetricsDefault];
        [self.navigationBar setShadowImage:newAppearance.shadowImage];
    }
    self.navigationBar.tintColor = newAppearance.titleTextAttributes[NSForegroundColorAttributeName];
    self.navigationBar.translucent = newAppearance.translucent;
    
    if (@available(iOS 11.0, *)) {
        [[UICollectionView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    if (@available(iOS 13.0, *)) {
        [[UITableView appearance] setAutomaticallyAdjustsScrollIndicatorInsets:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (UIViewController *)childViewControllerForStatusBarStyle
{
    return self.topViewController;
}

- (UIViewController *)childViewControllerForStatusBarHidden
{
    return self.topViewController;
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
