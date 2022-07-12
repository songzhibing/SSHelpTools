//
//  UIImage+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "UIImage+SSHelp.h"

@implementation UIImage (SSHelp)

/// 图片上写文字
/// @param string 文字
- (UIImage *)ss_writeString:(NSString *)string
{
    UIFont  *font  = [UIFont systemFontOfSize:14];
    UIColor *color = [ UIColor whiteColor];
    
    //画布大小
    CGSize size = CGSizeMake(self.size.width,self.size.height);
    //创建一个基于位图的上下文
    UIGraphicsBeginImageContextWithOptions(size,NO,0.0);//opaque:NO  scale:0.0

    [self drawAtPoint:CGPointMake(0.0,0.0)];

    //文字居中显示在画布上
    NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    paragraphStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paragraphStyle.alignment = NSTextAlignmentCenter;//文字居中

    //计算文字所占的size,文字居中显示在画布上
    CGSize sizeText= [string boundingRectWithSize:self.size
                                          options:NSStringDrawingUsesLineFragmentOrigin
                                       attributes:@{NSFontAttributeName:font}
                                          context:nil].size;
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;

    CGRect rect = CGRectMake((width-sizeText.width)/2,
                             (height-sizeText.height)/2,
                             sizeText.width,
                             sizeText.height);
    //绘制文字
    [string drawInRect:rect
        withAttributes:@{NSFontAttributeName:font,
                         NSForegroundColorAttributeName:color,
                         NSParagraphStyleAttributeName:paragraphStyle}];

    //返回绘制的新图形
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

/// 颜色生成图片
+ (UIImage *)ss_imageWithColor:(UIColor *)color
{
    return [UIImage ss_imageWithColor:color size:CGSizeMake(1, 1)];
}

/// 颜色生成图片
+ (UIImage *)ss_imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/// 图片绘制圆角
- (UIImage *)ss_setCornerRadius:(CGFloat)cornerRadius
{
    CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:cornerRadius];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextAddPath(ctx, path.CGPath);
    CGContextClip(ctx);
    [self drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGContextRelease(ctx);
    return newImage;
}

/// 改变图片颜色
- (UIImage *)ss_imageWithTintColor:(UIColor *)color
{
    if (@available(iOS 13.0, *)) {
        return [self imageWithTintColor:color renderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        UIGraphicsBeginImageContextWithOptions(self.size, NO, 0.0f);
        [color setFill];
        CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
        UIRectFill(bounds);
        //绘制一次 保留灰度信息
        [self drawInRect:bounds blendMode:kCGBlendModeOverlay alpha:1.0f];
        //再绘制一次 保留透明度信息
        [self drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
        UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return tintedImage;
    }
}


@end
