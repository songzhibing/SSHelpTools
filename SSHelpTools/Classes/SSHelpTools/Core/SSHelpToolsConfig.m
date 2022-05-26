//
//  SSHelpToolsConfig.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "SSHelpToolsConfig.h"
#import "NSBundle+SSHelp.h"
#import "UIColor+SSHelp.h"

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

- (void)resetNavigationBarAppearance:(SSHelpNavigationBarAppearance *)appearance
{
    
}

- (void)resetTabBarAppearance:(SSHelpTabBarApparance *)appearance
{
    
}

#pragma mark - Private Method

- (void)setupConfig
{
    /// 打印日志
    _enableLog = NO;
    
    _enableLifeCycleLog = NO;

    if (@available(iOS 13.0, *)) {
        _backgroundColor = [UIColor systemBackgroundColor];
    } else {
        _backgroundColor = [UIColor whiteColor];
    }
    
    if (@available(iOS 13.0, *)) {
        _secondaryBackgroundColor = [UIColor secondarySystemBackgroundColor];
    } else {
        _secondaryBackgroundColor = [UIColor ss_colorWithString:@"#F2F2F7FF"];
    }
    
    if (@available(iOS 13.0, *)) {
        _labelColor = [UIColor labelColor];
    } else {
        _labelColor = [UIColor blackColor];
    }
    
    if (@available(iOS 13.0, *)) {
        _secondaryLabelColor = [UIColor secondaryLabelColor];
    } else {
        _secondaryLabelColor = [UIColor ss_colorWithString:@"#3C3C434C"];
    }
    
    if (@available(iOS 13.0, *)) {
        _linkColor = [UIColor linkColor];
    } else {
        _linkColor = [UIColor ss_colorWithString:@"#007AFFFF"];
    }
    
    if (@available(iOS 13.0, *)) {
        _blueColor = [UIColor systemBlueColor];
    } else {
        _blueColor = [UIColor ss_colorWithString:@"#007AFFFF"];
    }
    
    if (@available(iOS 13.0, *)) {
        _groupedBackgroundColor = [UIColor systemGroupedBackgroundColor];
    } else {
        _groupedBackgroundColor = [UIColor ss_colorWithString:@"#F2F2F7FF"];
    }
    
    if (@available(iOS 13.0, *)) {
        _secondaryGroupedBackgroundColor = [UIColor secondarySystemGroupedBackgroundColor];
    } else {
        _secondaryGroupedBackgroundColor = [UIColor ss_colorWithString:@"#FFFFFFFF"];
    }
    
    if (@available(iOS 13.0, *)) {
        _secondaryFillColor = [UIColor secondarySystemFillColor];
    } else {
        _secondaryFillColor = [UIColor ss_colorWithString:@"#78788028"];
    }
    
    if (@available(iOS 13.0, *)) {
        _tertiaryFillColor = [UIColor tertiarySystemFillColor];
    } else {
        _tertiaryFillColor = [UIColor ss_colorWithString:@"#7676801E"];
    }
        
    _navbarAppearance = [[SSHelpNavigationBarAppearance alloc] init];
    _navbarAppearance.backgroundColor = _blueColor;
    _navbarAppearance.backgroundImage = nil;

    /// 基于backgroundColor或backgroundImage的磨砂效果
    _navbarAppearance.backgroundEffect = nil;
    
    _navbarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont systemFontOfSize:16]};
    
    /// 阴影图片。template图像:[img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]
    _navbarAppearance.shadowImage = [UIImage new];
    
    /// 阴影颜色（底部分割线），当shadowImage为nil时，直接使用此颜色为阴影色。
    /// 如果此属性为nil或clearColor（需要显式设置），则不显示阴影
    _navbarAppearance.shadowColor = [UIColor clearColor];
    
#ifdef DEBUG
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        _navbarAppearance.backgroundColor = appearance.backgroundColor;
        _navbarAppearance.backgroundEffect = appearance.backgroundEffect;
        _navbarAppearance.backgroundImage = appearance.backgroundImage;
        _navbarAppearance.titleTextAttributes = appearance.titleTextAttributes;
        _navbarAppearance.shadowImage = appearance.shadowImage;
        _navbarAppearance.shadowColor = appearance.shadowColor;
    }
#endif
    /// 导航栏左侧返回按钮图片
    _navigationBarLeftBackImg = [NSBundle ss_navigationBackImage];
}

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
