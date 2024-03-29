//
//  UIImage+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import <UIKit/UIKit.h>
#import "SSHelpDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (SSHelp)

- (UIImage *)ss_imageWithTintColor:(UIColor *)color;

/// 纯色图
+ (UIImage *)ss_imageWithcolor:(UIColor *)color;

/// 压缩大小
+ (NSData *)ss_compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength;

/// 添加水印
+ (UIImage *)ss_addWatermarkInImage:(UIImage *)image atPonit:(CGPoint)point withText:(NSString *)text;

/// 生成居中带logo的图像
+ (UIImage *)ss_generateImageWithLogo:(UIImage *)logo backgroundColor:(UIColor *)backgroundColor size:(CGSize)size;

/// 截屏
+ (UIImage * _Nullable)ss_takeScreenShot;

/// 识别二维码
+ (void)ss_featuresInImage:(UIImage *)image callback:(SSBlockString)callback;

@end

NS_ASSUME_NONNULL_END
