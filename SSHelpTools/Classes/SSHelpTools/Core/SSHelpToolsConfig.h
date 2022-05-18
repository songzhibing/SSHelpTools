//
//  SSHelpToolsConfig.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//  统一配置
//

#import <Foundation/Foundation.h>
#import "SSHelpNavigationBarAppearance.h"
#import "SSHelpTabBarApparance.h"

NS_ASSUME_NONNULL_BEGIN

#define SSHELPTOOLSCONFIG [SSHelpToolsConfig sharedConfig]

@interface SSHelpToolsConfig : NSObject

+ (SSHelpToolsConfig *)sharedConfig;

/// 输出日志, default is YES
@property(nonatomic, assign) BOOL enableLog;

/// OC对象生命周期日志输出,方便调试内存泄露等问题,default is NO
@property(nonatomic, assign) BOOL enableLifeCycleLog;

/// Default is [UIApplication sharedApplication].delegate.window
@property(nonatomic, strong, readwrite, nullable) UIWindow *window;

/// "home键"高度
@property(nonatomic, assign, readonly) CGFloat homeIndicatorHeight;

/// 默认导航栏左侧返回按钮背景图片，白色
@property(nonatomic, strong, readwrite) UIImage *navigationBarLeftBackImg;

/// 视图背景色
@property(nonatomic, assign, readwrite) UIColor *backgroundColor;

/// 二级视图背景色
@property(nonatomic, assign, readwrite) UIColor *secondaryBackgroundColor;

/// TabBarItem图标色值
@property(nonatomic, assign, readwrite) UIColor *secondaryFillColor;

/// TabBar背景色
@property(nonatomic, assign, readwrite) UIColor *tertiaryFillColor;

@property(nonatomic, assign, readwrite) UIColor *blueColor;

@property(nonatomic, assign, readwrite) UIColor *labelColor;

@property(nonatomic, assign, readwrite) UIColor *secondaryLabelColor;

@property(nonatomic, assign, readwrite) UIColor *linkColor;

@property(nonatomic, assign, readwrite) UIColor *groupedBackgroundColor;

@property(nonatomic, assign, readwrite) UIColor *secondaryGroupedBackgroundColor;

@property(nonatomic, strong) SSHelpNavigationBarAppearance *navbarAppearance;

@property(nonatomic, strong) SSHelpTabBarApparance *tabBarAppearance;

- (void)resetNavigationBarAppearance:(SSHelpNavigationBarAppearance *)appearance;

- (void)resetTabBarAppearance:(SSHelpTabBarApparance *)appearance;

@end

NS_ASSUME_NONNULL_END
