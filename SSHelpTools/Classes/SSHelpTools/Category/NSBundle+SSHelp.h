//
//  NSBundle+SSHelp.h
//  AFNetworking
//
//  Created by 宋直兵 on 2022/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (SSHelp)

/// 获取指定bundle路径 ，支持静态库、动态库
+ (NSString * _Nullable)ss_bundlePath:(NSString *)bundleName;

/// 从指定bundle获取指定图片，
+ (UIImage * _Nullable)ss_loadImage:(NSString *)imageName fromBundle:(NSString *)bundleName;

/// 'SSHelpTools库'专属bundle
+ (NSBundle *)ss_toolsBundle;

/// 'SSHelpTools库'专属bundle图
+ (UIImage *)ss_toolsBundleImage:(NSString *)imageName;

@end

NS_ASSUME_NONNULL_END
