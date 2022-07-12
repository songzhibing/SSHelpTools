//
//  UIImage+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SSHelp)

/// 图片上写文字
- (UIImage *)ss_writeString:(NSString *)string;

/// 图片绘制圆角
- (UIImage *)ss_setCornerRadius:(CGFloat)cornerRadius;

/// 改变图片颜色
- (UIImage *)ss_imageWithTintColor:(UIColor *)tintColor;

/// 颜色生成图片 CGSizeMake(1,1)
+ (UIImage *)ss_imageWithColor:(UIColor *)color;

/// 颜色生成图片
+ (UIImage *)ss_imageWithColor:(UIColor *)color size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
