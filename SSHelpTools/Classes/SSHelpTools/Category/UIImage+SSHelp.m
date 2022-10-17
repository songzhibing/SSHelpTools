//
//  UIImage+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "UIImage+SSHelp.h"

@implementation UIImage (SSHelp)

/// 纯色图
+ (UIImage *)ss_imageWithcolor:(UIColor *)color
{
    CGRect rect= CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}


+ (NSData *)ss_compressImageQuality:(UIImage *)image toByte:(NSInteger)maxLength
{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    #ifdef DEBUG
    //SSLog(@"原始图片大小:%.2fKB",data.length/1024.f);
    #endif
    while (data.length > maxLength && compression > 0) {
        compression -= 0.02;
        data = UIImageJPEGRepresentation(image, compression); // When compression less than a value, this code dose not work
    }
    if (compression >= 0.02) {
        //在压缩之后再转成图片，会变大，这里系数再次-0.01优化一下。
        compression -= 0.01;
        data = UIImageJPEGRepresentation(image, compression);
    }
    #ifdef DEBUG
    //SSLog(@"压缩图片大小:%.2fKB 系数：%.2f",data.length/1024.f,compression);
    #endif
    return data;
}

+ (UIImage *)ss_addWatermarkInImage:(UIImage *)image atPonit:(CGPoint)point withText:(NSString *)text
{
    //开启一个图形上下文
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    //绘制上下文：1-绘制图片
    [image drawAtPoint:point];
    
    //绘制上下文：2-添加文字到上下文
    NSDictionary *dic = @{
                          NSFontAttributeName:[UIFont systemFontOfSize:30],
                          NSForegroundColorAttributeName:[UIColor redColor]
                          };
    
    [text drawAtPoint:point withAttributes:dic];
    
    //从图形上下文中获取合成的图片
    UIImage *watermarkImage = UIGraphicsGetImageFromCurrentImageContext();
    
    //关闭上下文
    UIGraphicsEndImageContext();
    
    return watermarkImage;
}

+ (UIImage * _Nullable)ss_takeScreenShot
{
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    if (window) {
        UIGraphicsBeginImageContextWithOptions(window.frame.size, NO, 0);
        [window drawViewHierarchyInRect:window.frame afterScreenUpdates:YES];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return  newImage;
    }
    return nil;
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

/// 识别二维码
+ (void)ss_featuresInImage:(UIImage *)image callback:(void(^_Nonnull)(NSString *_Nullable result))callback;
{
    NSString *resultString = nil;
    CIImage *ciimage     = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    CIContext *content   = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode
                                              context:content
                                              options:@{CIDetectorAccuracy:CIDetectorAccuracyHigh}];
    NSArray *features    = [detector featuresInImage:ciimage];
    
    for (CIQRCodeFeature *item in features) {
        if (item.messageString) {
            resultString  = item.messageString;
            break;
        }
    }
    callback(resultString);
}

@end
