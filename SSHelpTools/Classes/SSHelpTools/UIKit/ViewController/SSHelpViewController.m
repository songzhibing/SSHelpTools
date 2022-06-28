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
    SSLifeCycleLog(@"%@ dealloc retain %td ... ",self,_kRetainCount(self))
}

/**
 view 被加载到内存后调用 viewDidLoad()；
 重写该方法需要首先调用父类该方法；
 该方法中可以额外初始化控件，例如添加子控件，添加约束；
 该方法被调用意味着控制器有可能（并非一定）在未来会显示；
 在控制器生命周期中，该方法只会被调用一次；
 */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = SSHELPTOOLSCONFIG.backgroundColor;
    _viewSafeAreaInsets = UIEdgeInsetsZero;
}

/**
 可以主动显式触发加载视图的方法；
 只要是触发了 view 加载, 加载完成后就会触发 viewDidLoad 方法；
 此时视图控制器的主视图可能还未加入到视图树中, 且绝大多数情况下都是(此时 view 的 window 属性还是 nil)!
 不应在 viewDidLoad 中进行一些依赖于屏幕尺寸或窗口尺寸的操作(初学者常犯的错误)；
 */
- (void)loadViewIfNeeded
{
    [super loadViewIfNeeded];
}

/**
 该方法在控制器 view 即将添加到视图层次时以及展示 view 时所有动画配置前被调用；
 重写该方法需要首先调用父类该方法；
 该方法中可以进行操作即将显示的 view，例如改变状态栏的取向，类型；
 该方法被调用意味着控制器将一定会显示；
 在控制器生命周期中，该方法可能会被多次调用；
 */
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (@available(iOS 11.0, *)) {
        // iOS11之后使用 - (void)viewSafeAreaInsetsDidChange
    } else {
        [self updateSubviewsDisplayWithOptions:UIViewControllerViewWillAppear];
    }
}

/**
 iOS 11后新API，根视图的边距变更时会触发该方法的回调
 */
- (void)viewLayoutMarginsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewLayoutMarginsDidChange];
    [self updateSubviewsDisplayWithOptions:UIViewControllerViewLayoutMarginsDidChange];
}

/**
 iOS 11后新API，此时可以获取安全区的信息
 */
- (void)viewSafeAreaInsetsDidChange NS_REQUIRES_SUPER API_AVAILABLE(ios(11.0), tvos(11.0))
{
    [super viewSafeAreaInsetsDidChange];
    [self updateSubviewsDisplayWithOptions:UIViewControllerViewSafeAreaInsetsDidChange];
}

/**
 该方法在通知控制器将要布局 view 的子控件时调用；
 每当视图的 bounds 改变，view 将调整其子控件位置；
 该方法可重写以在 view 布局子控件前做出改变；
 该方法的默认实现为空；
 该方法调用时，AutoLayout 未起作用；
 在控制器生命周期中，该方法可能会被多次调用；
 */
- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

/**
 该方法在通知控制器已经布局 view 的子控件时调用；
 该方法可重写以在 view 布局子控件后做出改变；
 该方法的默认实现为空；
 该方法调用时，AutoLayout 已经完成；
 在控制器生命周期中，该方法可能会被多次调用；
 */
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

/**
 该方法在控制器 view 已经添加到视图层次时被调用；
 重写该方法需要首先调用父类该方法；
 该方法可重写以进行有关正在展示的视图操作；
 在控制器生命周期中，该方法可能会被多次调用；
 */
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/**
 该方法在控制器 view 将要从视图层次移除时被调用；
 该方法可重写以提交变更，取消视图第一响应者状态；
 */
- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

/**
 该方法在控制器 view 已经从视图层次移除时被调用；
 该方法可重写以清除或隐藏控件；
 */
- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

#pragma mark - Public Method

/**
 控制器视图尺寸发生变化回调
 */
- (void)updateSubviewsDisplayWithOptions:(UIViewControllerLifeCycleOptions)options API_AVAILABLE(ios(10.0)) NS_REQUIRES_SUPER
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
    
    //计算view边距
    _viewSafeAreaInsets = UIEdgeInsetsMake(contentRect.origin.y,
                                           contentRect.origin.x,
                                           homeIndicatorHeight,
                                           self.view.ss_width-contentRect.origin.x-contentRect.size.width);

    
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
    // 方式1：
    UIDevice *currentDevice = [UIDevice currentDevice];
    if([currentDevice respondsToSelector:@selector(setOrientation:)]) {
        // 需要 - (BOOL)shouldAutorotate 返回YES，才能启作用
        [currentDevice setValue:[NSNumber numberWithInteger:orientation] forKey:@"orientation"];
    }
    
    // 方式2：
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
