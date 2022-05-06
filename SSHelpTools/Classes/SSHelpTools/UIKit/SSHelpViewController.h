//
//  SSHelpViewController.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/8/27.
//  自定义基础视图控制器 (默认忽视系统NavigationBar,toolBar)
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "SSHelpToolsConfig.h"
#import "SSHelpDefines.h"
#import "SSHelpNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpViewController : UIViewController <SSHelpNavigationBarDelegate>

/// 默认提供一个自定义导航栏
@property(nonatomic, strong) SSHelpNavigationBar *navigationBar;

/// 是否隐藏自定义导航栏
@property(nonatomic, assign) BOOL hiddenNavigationBar;

/// 提供一个安全的容器视图
@property(nonatomic, strong) SSHelpView *safeContentView;

#pragma mark 可调用

/// 设置屏幕方向
- (void)resetDeviceOrientation:(UIDeviceOrientation)orientation;

/// 返回上级页面
- (void)tryGoBack;

#pragma mark 可重写

/// 控制器视图尺寸发生变化回调
- (void)updateSubviewsDisplay NS_REQUIRES_SUPER;

@end


NS_ASSUME_NONNULL_END
