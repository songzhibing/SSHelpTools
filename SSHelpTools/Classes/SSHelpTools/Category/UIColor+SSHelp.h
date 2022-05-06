//
//  UIColor+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (SSHelp)

/**
 16进制颜色转换为UIColor

 @param hexColor 16进制字符串（可以以0x开头，可以以#开头，也可以就是6位的16进制）
 @param alpha 透明度
 @return 16进制字符串对应的颜色,异常返回 blackColor
 */
+(UIColor *)ss_colorWithHexString:(NSString *)hexColor alpha:(float)alpha;

/**
 0x开头的十六进制数值转换成的颜色,透明度可调整
 */
+ (UIColor *)ss_colorWithHex:(long)hexValue alpha:(float)alpha;

/**
 @return a random Color.
 */
+ (UIColor *)ss_randomColor;

@end

NS_ASSUME_NONNULL_END
