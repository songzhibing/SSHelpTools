//
//  UIColor+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (SSHelp)

/// 0XFFFFFF，#FFFFFF 转 Color
+ (UIColor *)ss_colorWithHexString:(NSString *)hexString alpha:(float)alpha;

/// RGBA 转 Color
+ (UIColor *)ss_colorWithString:(NSString *)hexString;

/// 0xFFFFFF 转 Color
+ (UIColor *)ss_colorWithHex:(long)hexValue alpha:(float)alpha;

/// Return a random Color.
+ (UIColor *)ss_randomColor;

@end

NS_ASSUME_NONNULL_END
