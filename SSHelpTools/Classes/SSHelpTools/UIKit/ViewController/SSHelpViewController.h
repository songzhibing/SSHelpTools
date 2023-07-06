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
#import "SSHelpCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpViewController : UIViewController <SSHelpNavigationBarDelegate>

/// 自定义导航栏
@property(nonatomic, strong, nullable) SSHelpNavigationBar *customNavigationBar;

/// 自定义view
@property(nonatomic, strong, nullable) SSHelpView *containerView;

/// 自定义collectionView
@property(nonatomic, strong, nullable) SSHelpCollectionView *collectionView;

/// 调整自定义视图位置
- (void)adjustUI;

/// 设置屏幕方向
- (void)resetDeviceOrientation:(UIDeviceOrientation)orientation;

/// 返回上级页面
- (void)tryGoBack;

@end


NS_ASSUME_NONNULL_END
