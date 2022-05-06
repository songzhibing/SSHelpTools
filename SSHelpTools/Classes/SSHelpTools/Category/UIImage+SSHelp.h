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
/// @param string 文字
- (UIImage *)ss_writeString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
