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

/// 纯色图片，SizeMake(1,1)
+ (UIImage *)ss_imageWithColor:(UIColor *)color;

/// 纯色图片，自定大小
+ (UIImage *)ss_imageWithColor:(UIColor *)color withFrame:(CGRect)frame;

@end

NS_ASSUME_NONNULL_END
