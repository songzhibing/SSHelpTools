//
//  SSHelpViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/8/27.
//

#import "SSHelpViewController.h"
#import "UIView+SSHelp.h"
#import "SSHelpDefines.h"

@interface SSHelpViewController ()

@end

@implementation SSHelpViewController

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self)
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = SSHELPTOOLSCONFIG.backgroundColor;
    _viewSafeAreaInsets = UIEdgeInsetsZero;
}

- (void)loadViewIfNeeded
{
    [super loadViewIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewLayoutMarginsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewLayoutMarginsDidChange];
    [self adjustSubviewsDisplay];
}

- (void)viewSafeAreaInsetsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewSafeAreaInsetsDidChange];
    [self adjustSubviewsDisplay];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    if (@available(iOS 11.0, *)) {
        // iOS11之后使用 - (void)viewSafeAreaInsetsDidChange
    } else {
        [self adjustSubviewsDisplay];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)tryGoBack
{
    if (self.navigationController) {
        if ([self.navigationController presentationController].presentedViewController == self) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            if (self.navigationController.topViewController == self) {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    } else {
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:NULL];
        }
    }
}

/// 调整子视图位置
- (void)adjustSubviewsDisplay API_AVAILABLE(ios(10.0)) NS_REQUIRES_SUPER
{
    CGFloat statusBarHeight    = 0;
    CGRect  navigationBarFrame = CGRectZero;
    CGFloat tabBarHeight       = 0;
    UIEdgeInsets safeAreaInsets= UIEdgeInsetsZero;
    
    if (self.navigationController && !self.navigationController.isNavigationBarHidden) {
        // 使用系统导航栏
        navigationBarFrame = self.navigationController.navigationBar.frame;
        // 隐藏自定义导航栏
        if (_customNavigationBar) {
            _customNavigationBar.frame = navigationBarFrame;
            _customNavigationBar.ss_originY = -(navigationBarFrame.size.height); //上移
            _customNavigationBar.hidden = YES; //隐藏
        }
    } else {
        // 未使用系统导航栏
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if (orientation==UIInterfaceOrientationLandscapeLeft || orientation==UIInterfaceOrientationLandscapeRight) {
            statusBarHeight = 0; //横屏状态高度为0
        } else {
            if (@available(iOS 11.0, *)) {
                statusBarHeight = self.view.safeAreaInsets.top;
            } else {
                statusBarHeight = 20; //竖屏
            }
        }
        // 处理自定义导航栏
        if (_customNavigationBar) {
            navigationBarFrame = CGRectMake(0, 0, self.view.ss_width, statusBarHeight+_kNavBarHeight);
            _customNavigationBar.frame = navigationBarFrame;
            _customNavigationBar.hidden = NO; //显示
        }
    }
    
    // 计算间距
    if (@available(iOS 11.0, *)) {
        if (self.navigationController && !self.navigationController.isNavigationBarHidden) {
            safeAreaInsets = self.view.safeAreaInsets;
        } else {
            CGFloat navgationBarHeight = (_customNavigationBar && !_customNavigationBar.hidden)?_kNavBarHeight:0;
            safeAreaInsets = UIEdgeInsetsMake(self.view.safeAreaInsets.top+navgationBarHeight,
                                              self.view.safeAreaInsets.left,
                                              self.view.safeAreaInsets.bottom,
                                              self.view.safeAreaInsets.right);
        }
    } else {
        if (self.tabBarController && self.tabBarController.tabBar && !self.tabBarController.tabBar.isHidden) {
            tabBarHeight = CGRectGetHeight(self.tabBarController.tabBar.frame);
        } else {
            tabBarHeight = 0;
        }
        safeAreaInsets = UIEdgeInsetsMake(navigationBarFrame.size.height,0,tabBarHeight,0);
    }
    
    CGRect contentFrame = CGRectMake(safeAreaInsets.left,
                                     safeAreaInsets.top,
                                     self.view.ss_width-(safeAreaInsets.left+safeAreaInsets.right),
                                     self.view.ss_height-(safeAreaInsets.top+safeAreaInsets.bottom));
    // 调整
    _viewSafeAreaInsets = safeAreaInsets;
    if (_contentView) {
        _contentView.frame = contentFrame;
    }
}

#pragma mark - Device Orientation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait; 
}

/// 设置屏幕方向
- (void)resetDeviceOrientation:(UIDeviceOrientation)orientation
{
    // 方式1：
    UIDevice *device = [UIDevice currentDevice];
    if([device respondsToSelector:@selector(setOrientation:)]) {
        [device setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
    }
    /*
    // 方式2：
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice
        instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
     */
}

#pragma mark - CustomNavigationBar

- (SSHelpNavigationBar *)customNavigationBar
{
    if (!_customNavigationBar) {
        CGRect rect = CGRectMake(0, 0, self.view.ss_width, _kStatusBarHeight+_kNavBarHeight);
        _customNavigationBar = [[SSHelpNavigationBar alloc] initWithFrame:rect style:[self customNavigationBarStyle]];
        _customNavigationBar.delegate = self;
        [self.view addSubview:_customNavigationBar];
    }
    return _customNavigationBar;
}

- (SSHelpNavigationBarStyle)customNavigationBarStyle
{
    return SSNavigationBarWithLeftBack;
}

- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didLeftButton:(SSHelpButton *)button
{
    // 子类可重写
    if (button.style & (SSButtonStyleBack|SSButtonStyleRightExit)) {
        [self tryGoBack];
    }
}

- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didRightButton:(SSHelpButton *)button
{
    // 子类可重写
    if (button.style & (SSButtonStyleBack|SSButtonStyleRightExit)) {
        [self tryGoBack];
    }
}

#pragma mark - ContentView

- (SSHelpView *)contentView
{
    if (!_contentView) {
        CGFloat navbarHeight = _kNavBarHeight+_kStatusBarHeight;
        CGRect rect = CGRectMake(0, navbarHeight, self.view.ss_width, self.view.ss_height-navbarHeight);
        _contentView = [[SSHelpView alloc] initWithFrame:rect];
        _contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
        [self.view addSubview:_contentView];
    }
    return _contentView;
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
