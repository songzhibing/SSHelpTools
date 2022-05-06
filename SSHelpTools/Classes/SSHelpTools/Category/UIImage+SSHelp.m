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
    UIFont *font = [UIFont systemFontOfSize:14];
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

@end
