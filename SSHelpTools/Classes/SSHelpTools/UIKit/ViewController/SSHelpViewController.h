//
//  SSHelpViewController.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/8/27.
//  自定义视图控制器
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>

#import "SSHelpDefines.h"
#import "SSHelpNavigationBar.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpViewController : UIViewController <SSHelpNavigationBarDelegate>

/// 自定义导航栏
@property(nonatomic, strong) SSHelpNavigationBar *customNavigationBar;

/// 控制自定义导航栏默认样式
- (SSHelpNavigationBarStyle)customNavigationBarStyle;

/// 自定义内容视图
@property(nonatomic, strong) SSHelpView *contentView;

/// 内容视图安全间距
@property(nonatomic, readonly) UIEdgeInsets viewSafeAreaInsets API_AVAILABLE(ios(10.0));

/// 调整子视图位置
- (void)adjustSubviewsDisplay API_AVAILABLE(ios(10.0)) NS_REQUIRES_SUPER;

/// 设置屏幕方向
- (void)resetDeviceOrientation:(UIDeviceOrientation)orientation;

/// 返回上级页面
- (void)tryGoBack;

@end


NS_ASSUME_NONNULL_END
