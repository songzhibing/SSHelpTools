//
//  UIColor+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import "UIColor+SSHelp.h"

@implementation UIColor (SSHelp)

/**
 16进制颜色转换为UIColor

 @param hexColor 16进制字符串（可以以0x开头，可以以#开头，也可以就是6位的16进制）
 @param alpha 透明度
 @return 16进制字符串对应的颜色,异常返回 blackColor
 */
+(UIColor *)ss_colorWithHexString:(NSString *)hexColor alpha:(float)alpha
{
    if (hexColor && [hexColor isKindOfClass:[NSString class]]) {
        NSString *cString = [[hexColor stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];

        // String should be 6 or 8 characters
        if ([cString length] < 6) return [UIColor blackColor];

        // strip 0X if it appears
        if ([cString hasPrefix:@"0X"]) cString = [cString substringFromIndex:2];
        if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];

        if ([cString length] != 6) return [UIColor blackColor];

        // Separate into r, g, b substrings
        NSRange range;
        range.location = 0;
        range.length = 2;
        NSString * rString = [cString substringWithRange:range];

        range.location = 2;
        NSString * gString = [cString substringWithRange:range];

        range.location = 4;
        NSString * bString = [cString substringWithRange:range];

        // Scan values
        unsigned int r, g, b;
        [[NSScanner scannerWithString:rString] scanHexInt:&r];
        [[NSScanner scannerWithString:gString] scanHexInt:&g];
        [[NSScanner scannerWithString:bString] scanHexInt:&b];

        return [UIColor colorWithRed:((float)r / 255.0f)
                               green:((float)g / 255.0f)
                                blue:((float)b / 255.0f)
                               alpha:alpha];
    }
    return [UIColor blackColor];
}

/**
 0x开头的十六进制数值转换成的颜色,透明度可调整
 */
+ (UIColor *)ss_colorWithHex:(long)hexValue alpha:(float)alpha
{
    float red = ((float)((hexValue & 0xFF0000) >> 16))/255.0;
    float green = ((float)((hexValue & 0xFF00) >> 8))/255.0;
    float blue = ((float)(hexValue & 0xFF))/255.0;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

/**
 @return a random Color.
 */
+ (UIColor *)ss_randomColor
{
    return  [UIColor colorWithRed:arc4random_uniform(256)/255.0
                            green:arc4random_uniform(256)/255.0
                             blue:arc4random_uniform(256)/255.0
                            alpha:1.0];
}

@end
