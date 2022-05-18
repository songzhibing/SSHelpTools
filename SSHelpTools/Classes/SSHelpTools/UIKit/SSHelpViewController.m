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
    SSLifeCycleLog(@"%@ dealloc %td...",self,_kRetainCount(self));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = SSHELPTOOLSCONFIG.backgroundColor;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        // iOS11之后使用 - (void)viewSafeAreaInsetsDidChange
    } else {
        [self updateSubviewsDisplay];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewLayoutMarginsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewLayoutMarginsDidChange];    
    [self updateSubviewsDisplay];
}

- (void)viewSafeAreaInsetsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewSafeAreaInsetsDidChange];
    [self updateSubviewsDisplay];
}

#pragma mark -

/// 控制器视图尺寸发生变化回调，更新自定义视图布局
- (void)updateSubviewsDisplay NS_REQUIRES_SUPER
{
    CGFloat statusBarHeight = 20;     //状态栏高度
    CGFloat homeIndicatorHeight = 0;  //底部"Home键"高度
    CGRect  contentRect = CGRectZero; //有效内容区域

    //使用系统导航栏
    if (self.navigationController && !self.navigationController.isNavigationBarHidden) {
        CGRect navbarRect = self.navigationController.navigationBar.frame;
        if (@available(iOS 11.0, *)) {
            contentRect = self.view.safeAreaLayoutGuide.layoutFrame;
        } else {
            CGFloat originY = navbarRect.origin.y+navbarRect.size.height;
            contentRect = CGRectMake(0, originY, self.view.ss_width, self.view.ss_height-originY);
        }
        if (_navigationBar) {
            //调整自定义导航栏
            _navigationBar.frame = navbarRect;
            _navigationBar.ss_originY = -_navigationBar.ss_height; //上移
            _navigationBar.hidden = YES; //隐藏
        }
    } else {
        //未使用系统导航栏
        if (@available(iOS 11.0, *)) {
            statusBarHeight = self.view.safeAreaLayoutGuide.layoutFrame.origin.y;
        } else {
            statusBarHeight = 20; //iOS11之前的设备无“刘海”，且状态栏固定高度;
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if (orientation==UIInterfaceOrientationLandscapeLeft ||
                orientation==UIInterfaceOrientationLandscapeRight) {
                statusBarHeight = 0; //横屏状态:高度为0
            }
        }
        //计算导航栏尺寸并调整
        CGRect navbarRect = CGRectMake(0, 0, self.view.ss_width, statusBarHeight+_kNavBarHeight);
        if (_navigationBar) {
            _navigationBar.frame = navbarRect;
            _navigationBar.hidden = NO;
        }
        
        //计算"有效内容"区域尺寸
        if (@available(iOS 11.0, *)) {
            contentRect = self.view.safeAreaLayoutGuide.layoutFrame;
            if (_navigationBar) {
                contentRect.origin.y += _kNavBarHeight;
                contentRect.size.height -= _kNavBarHeight;
            }
        } else {
            CGFloat originY = navbarRect.origin.y+navbarRect.size.height;
            contentRect = CGRectMake(0, originY, self.view.ss_width, self.view.ss_height-originY);
        }
    }
    
    //计算底部Home区域高度
    if (@available(iOS 11.0, *)) {
        homeIndicatorHeight = self.view.bounds.size.height- self.view.safeAreaLayoutGuide.layoutFrame.origin.y-self.view.safeAreaLayoutGuide.layoutFrame.size.height;
    }
    
    //最后调整"有效内容"区域
    if (_contentView) {
        _contentView.frame = contentRect;
    }
}

#pragma mark - 设备旋转

/// 是否支持屏幕旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

/// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

/// 默认方向
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait; 
}

/*
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //旋转前
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        //旋转后
    }];
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}
*/

/// 设置屏幕方向
- (void)resetDeviceOrientation:(UIDeviceOrientation)orientation
{
    UIDevice *currentDevice = [UIDevice currentDevice];
    if([currentDevice respondsToSelector:@selector(setOrientation:)]) {
        // 需要 - (BOOL)shouldAutorotate 返回YES，才能启作用
        [currentDevice setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
    }
    
    /*
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

/// 返回上级页面
- (void)tryGoBack
{
    if (_hookGoBack) {
        _hookGoBack(self);
        return;
    }
    
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

#pragma mark - GCNavigationBarDelegate Method

- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didLeftButton:(SSHelpButton *)button
{
    // 子类可重写
    if (button.style == SSButtonStyleBack) {
        [self tryGoBack];
    }
}

- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didRightButton:(SSHelpButton *)button
{
    // 子类可重写
}

#pragma mark - Getter

- (SSHelpNavigationBar *)navigationBar
{
    if (!_navigationBar) {
        CGRect rect = CGRectMake(0, 0, self.view.ss_width, _kNavBarHeight+_kStatusBarHeight);
        _navigationBar = [[SSHelpNavigationBar alloc] initWithFrame:rect style:SSNavigationBarWithLeftBack];
        _navigationBar.delegate = self;
        [self.view addSubview:_navigationBar];
    }
    return _navigationBar;
}

- (SSHelpView *)contentView
{
    if (!_contentView) {
        CGFloat navbarHeight = _kNavBarHeight+_kStatusBarHeight;
        CGRect rect = CGRectMake(0, navbarHeight, self.view.ss_width, self.view.ss_height-navbarHeight);
        _contentView = [[SSHelpView alloc] initWithFrame:rect];
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
