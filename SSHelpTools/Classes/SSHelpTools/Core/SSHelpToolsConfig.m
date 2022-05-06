//
//  SSHelpToolsConfig.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "SSHelpToolsConfig.h"
#import "NSBundle+SSHelp.h"

@implementation SSHelpToolsConfig

+ (SSHelpToolsConfig *)sharedConfig
{
    static SSHelpToolsConfig *_config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [[SSHelpToolsConfig alloc] init];
        [_config setupConfig];
        
    });
    return _config;
}

#pragma mark - Private Method

- (void)setupConfig
{
    /// 打印日志
    _enableLog = NO;

    ///导航栏背景色
    _navigationBarBackgroundColor = [UIColor colorWithRed:0.22f green:0.48 blue:0.93 alpha:1.0];
    
    ///导航栏左侧返回按钮图片
    _navigationBarLeftBackImg = [NSBundle ss_navigationBackImage];
    
    _viewDefaultBackgroundColor = [UIColor whiteColor];
    
}

#pragma mark - Lazy load

- (CGFloat)homeIndicatorHeight
{
    if (self.window) {
        if (@available(iOS 11.0, *)) {
            return self.window.safeAreaInsets.bottom;
        }
    }
    return 0;
}

- (UIWindow *)window
{
    if (!_window) {
        _window = [UIApplication sharedApplication].delegate.window;
    }
    return _window;
}

@end
