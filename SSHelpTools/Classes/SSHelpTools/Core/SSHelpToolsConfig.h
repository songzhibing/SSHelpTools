//
//  SSHelpToolsConfig.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//  统一配置
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpToolsConfig : NSObject

+ (SSHelpToolsConfig *)sharedConfig;

/// 输出日志, default is NO
@property(nonatomic, assign) BOOL enableLog;

/// Default is [UIApplication sharedApplication].delegate.window
@property(nonatomic, strong, readwrite, nullable) UIWindow *window;

/// "home键"高度
@property(nonatomic, assign, readonly) CGFloat homeIndicatorHeight;

/// 默认导航栏背景色
@property(nonatomic, strong, readwrite) UIColor *navigationBarBackgroundColor;

/// 默认导航栏左侧返回按钮背景图片，白色
@property(nonatomic, strong, readwrite) UIImage *navigationBarLeftBackImg;

/// 默认视图背景色
@property(nonatomic, assign, readwrite) UIColor *viewDefaultBackgroundColor;

@end

NS_ASSUME_NONNULL_END
