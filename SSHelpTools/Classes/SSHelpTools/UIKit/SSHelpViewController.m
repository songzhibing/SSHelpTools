//
//  SSHelpViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/8/27.
//

/*
    UIViewController生命周期：
    ->viewDidLoad
    ->viewWillAppear
    ->viewSafeAreaInsetsDidChange
    ->viewWillLayoutSubviews
    ->viewDidLayoutSubviews
    ->viewDidAppear
 */

#import "SSHelpViewController.h"
#import "UIView+SSHelp.h"
#import "SSHelpDefines.h"

@interface SSHelpViewController ()

@end

@implementation SSHelpViewController

- (void)dealloc
{
    SSToolsLog(@"%@ dealloc ...",self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [SSHelpToolsConfig sharedConfig].viewDefaultBackgroundColor;
    [self.view addSubview:self.navigationBar];
    [self.view addSubview:self.safeContentView];
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

/// 控制器视图尺寸发生变化回调，更新自定义视图布局
- (void)updateSubviewsDisplay NS_REQUIRES_SUPER
{
    CGFloat statusBarHeight = 20; //状态栏高度
    CGFloat homeIndicatorHeight = 0; //底部"Home键"高度
    CGRect  contentRect = CGRectZero;

    if (self.navigationController && !self.navigationController.isNavigationBarHidden) {
        //使用系统导航栏

        CGRect navbarRect =  self.navigationController.navigationBar.frame;
        if (@available(iOS 11.0, *)) {
            CGFloat originX = self.view.safeAreaLayoutGuide.layoutFrame.origin.x;
            CGFloat originY = self.view.safeAreaLayoutGuide.layoutFrame.origin.y;
            CGFloat width = self.view.safeAreaLayoutGuide.layoutFrame.size.width;
            CGFloat height = self.view.safeAreaLayoutGuide.layoutFrame.size.height;
            contentRect = CGRectMake(originX, originY, width, height);
        } else {
            CGFloat originY = navbarRect.origin.y+navbarRect.size.height;
            contentRect = CGRectMake(0, originY, self.view.ss_width, self.view.ss_height-originY);
        }
    } else {
        //未使用系统导航栏
        
        //Tip:statusBarFrame在self.prefersStatusBarHidden=YES时，高度是0，但在viewDidAppear之前可能是40

        if (@available(iOS 11.0, *)) {
            statusBarHeight = self.view.safeAreaLayoutGuide.layoutFrame.origin.y;
            homeIndicatorHeight = self.view.bounds.size.height- self.view.safeAreaLayoutGuide.layoutFrame.origin.y-self.view.safeAreaLayoutGuide.layoutFrame.size.height;
        } else {
            statusBarHeight = 20; //iOS11之前的设备无“刘海”，且状态栏固定高度;
            
            UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
            if (orientation==UIInterfaceOrientationLandscapeLeft ||
                orientation==UIInterfaceOrientationLandscapeRight) {
                statusBarHeight = 0; //横屏状态:高度为0
            }
        }
        
        CGRect navbarRect =  CGRectMake(0, 0, self.view.ss_width, statusBarHeight+_kNavBarHeight);
        if (_hiddenNavigationBar) {
            //隐藏则上移，参照系统方式
            navbarRect.origin.y = -(navbarRect.size.height);
        }
        if (_navigationBar) {
            _navigationBar.frame = navbarRect;
            _navigationBar.hidden = _hiddenNavigationBar;
        }
        
        if (@available(iOS 11.0, *)) {
            /// Example iPhone11 Pro Max
            /// 横屏 layoutFrame = {{40, 0}, {732, 354}}, frame = (0 0; 812 375);
            /// 竖屏 layoutFrame = {{0, 40}, {375, 741.33333333333337}}, frame = (0 0; 375 812);
            CGFloat originX = self.view.safeAreaLayoutGuide.layoutFrame.origin.x;
            CGFloat originY = self.view.safeAreaLayoutGuide.layoutFrame.origin.y+(_hiddenNavigationBar?0:_kNavBarHeight);
            CGFloat width = self.view.safeAreaLayoutGuide.layoutFrame.size.width;
            CGFloat height = self.view.safeAreaLayoutGuide.layoutFrame.size.height-(_hiddenNavigationBar?0:_kNavBarHeight);
            contentRect = CGRectMake(originX, originY, width, height);
        } else {
            CGFloat originY = navbarRect.origin.y+navbarRect.size.height;
            contentRect = CGRectMake(0, originY, self.view.ss_width, self.view.ss_height-originY);
        }
    }
    
    if (_safeContentView) {
        _safeContentView.frame = contentRect;
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
    if (self.navigationController){
        if ([self.navigationController presentationController].presentedViewController== self){
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            if (self.navigationController.topViewController==self){
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
    }else{
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
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
    if (!_navigationBar)
    {
        CGRect rect = CGRectMake(0, 0, _kScreenWidth, _kNavBarHeight+_kStatusBarHeight);
        _navigationBar = [[SSHelpNavigationBar alloc] initWithFrame:rect style:SSNavigationBarWithLeftBack];
        _navigationBar.delegate = self;
    }
    return _navigationBar;
}

- (SSHelpView *)safeContentView
{
    if (!_safeContentView) {
        CGFloat navbarHeight = _kNavBarHeight+_kStatusBarHeight;
        CGRect rect = CGRectMake(0, navbarHeight, _kScreenWidth, _kScreenHeight-navbarHeight);
        _safeContentView = [[SSHelpView alloc] initWithFrame:rect];
        _safeContentView.userInteractionEnabled = YES;
    }
    return _safeContentView;
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
