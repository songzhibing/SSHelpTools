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

/// 自定义导航栏,懒加载
@property(nonatomic, strong) SSHelpNavigationBar *navigationBar;

/// 自定义容器视图,懒加载
@property(nonatomic, strong) SSHelpView *contentView;

/// 自定义返回
@property(nonatomic, strong, nullable) void(^hookGoBack)(SSHelpViewController *viewController);

/// 设置屏幕方向
- (void)resetDeviceOrientation:(UIDeviceOrientation)orientation;

/// 返回上级页面
- (void)tryGoBack;

/// 控制器视图尺寸发生变化回调
- (void)updateSubviewsDisplay NS_REQUIRES_SUPER;

@end


NS_ASSUME_NONNULL_END
