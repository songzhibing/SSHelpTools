//
//  SSHelpToolsConfig.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//  1.统一配置
//  2.外观风格配置，支持换肤，iOS13默认跟随系统
//

#import <Foundation/Foundation.h>
#import "SSHelpNavigationBarAppearance.h"
#import "SSHelpTabBarApparance.h"

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSNotificationName const SSNavBarAppearanceDidChangeNotification;
UIKIT_EXTERN NSNotificationName const SSTabBarAppearanceDidChangeNotification;

#define SSHELPTOOLSCONFIG [SSHelpToolsConfig sharedConfig]

typedef SSHelpNavigationBarAppearance *_Nonnull(^SSUpdateNavBarAppearance)(void);
typedef SSHelpTabBarApparance *_Nonnull(^SSUpdateTabBarAppearance)(void);

@interface SSHelpToolsConfig : NSObject

+ (SSHelpToolsConfig *)sharedConfig;

/// 输出日志, default is NO
@property(nonatomic, assign) BOOL enableLog;

/// OC对象生命周期日志输出,方便调试内存泄露等问题,default is NO
@property(nonatomic, assign) BOOL enableLifeCycleLog;

/// 支持最低iOS版本，默认iOS10.0 推荐iOS13.0
@property(nonatomic, assign) CGFloat supportMinSystemiOS;

/// return [UIApplication sharedApplication].delegate.window
@property(nonatomic, strong, readwrite, nullable) UIWindow *window;

@property(nonatomic, assign) CGFloat homeIndicatorHeight;

@property(nonatomic, strong) UIColor *backgroundColor;

@property(nonatomic, strong) UIColor *secondaryBackgroundColor;

@property(nonatomic, strong) UIColor *secondaryFillColor;

@property(nonatomic, strong) UIColor *tertiaryFillColor;

@property(nonatomic, strong) UIColor *blueColor;

@property(nonatomic, strong) UIColor *labelColor;

@property(nonatomic, strong) UIColor *secondaryLabelColor;

@property(nonatomic, strong) UIColor *linkColor;

@property(nonatomic, strong) UIColor *groupedBackgroundColor;

@property(nonatomic, strong) UIColor *secondaryGroupedBackgroundColor;

@property(nonatomic, strong, readonly, nullable) SSHelpNavigationBarAppearance *customNavbarAppearance;

@property(nonatomic, strong, readonly, nullable) SSHelpTabBarApparance *customTabBarAppearance;

/// 自定义导航栏外观、换肤
- (void)updateNavigationBarAppearance:(SSUpdateNavBarAppearance)block;

/// 自定义底部选项外观、换肤
- (void)updateTabBarAppearance:(SSUpdateTabBarAppearance)block;

@end

NS_ASSUME_NONNULL_END
