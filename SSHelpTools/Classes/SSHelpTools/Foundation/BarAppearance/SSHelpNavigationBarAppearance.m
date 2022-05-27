//
//  SSHelpNavigationBarAppearance.m
//  Pods
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpNavigationBarAppearance.h"
#import "SSHelpToolsConfig.h"

@implementation SSHelpNavigationBarAppearance

+ (SSHelpNavigationBarAppearance *)defaultAppearance
{
    SSHelpNavigationBarAppearance *_navbarAppearance = [[SSHelpNavigationBarAppearance alloc] init];
    _navbarAppearance.translucent = NO;
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        _navbarAppearance.backgroundColor = appearance.backgroundColor;
        _navbarAppearance.backgroundImage = appearance.backgroundImage;
        _navbarAppearance.titleTextAttributes = appearance.titleTextAttributes;
        _navbarAppearance.backgroundEffect = appearance.backgroundEffect;
        _navbarAppearance.shadowImage = appearance.shadowImage;
        _navbarAppearance.shadowColor = appearance.shadowColor;
    } else {
        _navbarAppearance.backgroundColor = [UIColor colorWithWhite:0.87f alpha:0.8f];
        _navbarAppearance.backgroundImage = nil;
        _navbarAppearance.titleTextAttributes = @{NSForegroundColorAttributeName:SSHELPTOOLSCONFIG.labelColor,
                                                  NSFontAttributeName:[UIFont systemFontOfSize:18]};
        _navbarAppearance.backgroundEffect = nil;
        _navbarAppearance.shadowImage = [UIImage new];
        _navbarAppearance.shadowColor = [UIColor clearColor];
    }
    return _navbarAppearance;
}

@end
