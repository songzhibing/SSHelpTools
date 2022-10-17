//
//  SSHelpToolsConfig.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "SSHelpToolsConfig.h"
#import "NSBundle+SSHelp.h"
#import "UIColor+SSHelp.h"
#import "UIImage+SSHelp.h"

NSNotificationName const SSNavBarAppearanceDidChangeNotification = @"ss.navbar.appearance.change";
NSNotificationName const SSTabBarAppearanceDidChangeNotification = @"ss.tabbar.appearance.change";

@implementation SSHelpToolsConfig

+ (SSHelpToolsConfig *)sharedConfig
{
    static SSHelpToolsConfig *_config;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [[SSHelpToolsConfig alloc] init];
    });
    return _config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
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
    }
    return self;
}

- (void)updateNavigationBarAppearance:(SSUpdateNavBarAppearance)block
{
    _customNavbarAppearance = block();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SSNavBarAppearanceDidChangeNotification object:nil];
    });
}

- (void)updateTabBarAppearance:(SSUpdateTabBarAppearance)block
{
    _customTabBarAppearance = block();
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:SSTabBarAppearanceDidChangeNotification object:nil];
    });
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
