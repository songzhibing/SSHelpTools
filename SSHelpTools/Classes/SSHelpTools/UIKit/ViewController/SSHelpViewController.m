//
//  SSHelpViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/8/27.
//

#import "SSHelpViewController.h"
#import "UIView+SSHelp.h"
#import "SSHelpDefines.h"
#import "SSHelpLabel.h"

@interface SSHelpViewController ()

@property(nonatomic, strong, nullable) SSHelpLabel *debugBackView;

@end


@implementation SSHelpViewController

- (void)dealloc
{
    //SSLifeCycleLog(@"%@ dealloc ... ",self);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = SSHELPTOOLSCONFIG.backgroundColor;
    
    #ifdef DEBUG
    self.debugBackView.alpha = 0.5f;
    #endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self adjustUI];
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    [self adjustUI];
}

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

#pragma mark -
#pragma mark - Private Method

/// 调整子视图位置
- (void)adjustUI
{
    CGFloat statusBarHeight     = 0;
    CGRect  navigationBarFrame  = CGRectZero;
    UIEdgeInsets safeAreaInsets = UIEdgeInsetsZero;
    
    if (self.navigationController && !self.navigationController.isNavigationBarHidden) {
        // 使用系统导航栏
        navigationBarFrame = self.navigationController.navigationBar.frame;
        // 计算内容安全区域
        safeAreaInsets = self.view.safeAreaInsets;
        // 隐藏自定义导航栏
        if (_customNavigationBar) {
            _customNavigationBar.frame = navigationBarFrame;
            _customNavigationBar.ss_originY = -(navigationBarFrame.size.height); //上移
            _customNavigationBar.hidden = YES; //隐藏
        }
    } else {
        // 未使用系统导航栏
        statusBarHeight = self.view.safeAreaInsets.top;
        // 计算内容安全区域
        safeAreaInsets = self.view.safeAreaInsets;
        // 处理自定义导航栏
        if (_customNavigationBar) {
            navigationBarFrame = CGRectMake(0, 0, self.view.ss_width, statusBarHeight+_kNavBarHeight);
            _customNavigationBar.frame = navigationBarFrame;
            _customNavigationBar.hidden = NO; //显示
            //调整安全区域
            safeAreaInsets.top += _kNavBarHeight;
        }
    }
    
    CGRect contentFrame = CGRectMake(safeAreaInsets.left,
                                     safeAreaInsets.top,
                                     self.view.ss_width-(safeAreaInsets.left+safeAreaInsets.right),
                                     self.view.ss_height-(safeAreaInsets.top+safeAreaInsets.bottom));
    // 重新赋值
    if (_debugBackView) {
        _debugBackView.frame = contentFrame;
    }
    if (_containerView) {
        _containerView.frame = contentFrame;
    }
    if (_collectionView) {
        _collectionView.frame = contentFrame;
    }
}

#pragma mark -
#pragma mark - Public Method

/// 返回
- (void)tryGoBack
{
    if (self.presentingViewController) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        BOOL pop = self.navigationController &&
        self.navigationController.viewControllers.count>=2 &&
        self.navigationController.topViewController == self;
        if (pop) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
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

#pragma mark -
#pragma mark - SSHelpNavigationBarDelegate Method

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

#pragma mark -
#pragma mark - Lazy Loading Method

/// 自定义导航栏
- (SSHelpNavigationBar *)customNavigationBar
{
    if (!_customNavigationBar) {
        CGRect rect = CGRectMake(0, 0, self.view.ss_width, _kStatusBarHeight+_kNavBarHeight);
        _customNavigationBar = [[SSHelpNavigationBar alloc] initWithFrame:rect style:SSNavigationBarWithLeftBack];
        _customNavigationBar.delegate = self;
        [self.view addSubview:_customNavigationBar];
    }
    return _customNavigationBar;
}

- (SSHelpCollectionView *)collectionView
{
    if (!_collectionView) {
        _collectionView = [SSHelpCollectionView creatWithFrame:self.view.bounds];
        [self.view addSubview:_collectionView];
    }
    return _collectionView;
}

- (SSHelpView *)containerView
{
    if (!_containerView) {
        _containerView = [[SSHelpView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_containerView];
    }
    return _containerView;
}

- (SSHelpLabel *)debugBackView
{
    if (!_debugBackView) {
        _debugBackView = [[SSHelpLabel alloc] initWithFrame:self.view.bounds];
        _debugBackView.backgroundColor = [UIColor.orangeColor colorWithAlphaComponent:0.5f];
        _debugBackView.layer.borderWidth = 2;
        _debugBackView.layer.borderColor = [UIColor.greenColor CGColor];
        _debugBackView.numberOfLines = 0;
        _debugBackView.textAlignment = NSTextAlignmentCenter;
        _debugBackView.text = [NSString stringWithFormat:@"%@",self];
        [self.view addSubview:_debugBackView];
    }
    return _debugBackView;
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
