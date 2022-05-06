//
//  NSBundle+SSHelp.m
//  AFNetworking
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "NSBundle+SSHelp.h"
#import "SSHelpToolsConfig.h"

@implementation NSBundle (SSHelp)

+ (instancetype)ss_toolsBundle
{
    static NSBundle *uikitBundle = nil;
    if (uikitBundle == nil) {
        NSBundle *containnerBundle = [NSBundle bundleForClass:[SSHelpToolsConfig class]];
        uikitBundle = [NSBundle bundleWithPath:[containnerBundle pathForResource:@"SSHelpTools" ofType:@"bundle"]];
    }
    return uikitBundle;
}

+ (UIImage *)ss_navigationBackImage
{
    static UIImage *backImage = nil;
    if (backImage == nil) {
        backImage = [UIImage imageWithContentsOfFile:[[self ss_toolsBundle] pathForResource:@"ss_navi_back_white@2x" ofType:@"png"]];
    }
    return backImage;
}

+ (UIImage *)ss_flashlightOpenImg
{
    static UIImage *_flashlightOpenImg = nil;
    if (_flashlightOpenImg == nil) {
        _flashlightOpenImg = [UIImage imageWithContentsOfFile:[[self ss_toolsBundle] pathForResource:@"ss_flashlight_open_img@2x" ofType:@"png"]];
    }
    return _flashlightOpenImg;
}

+ (UIImage *)ss_flashlightCloseImg
{
    static UIImage *_flashlightCloseImg = nil;
    if (_flashlightCloseImg == nil) {
        _flashlightCloseImg = [UIImage imageWithContentsOfFile:[[self ss_toolsBundle] pathForResource:@"ss_flashlight_close_img@2x" ofType:@"png"]];
    }
    return _flashlightCloseImg;
}

+ (UIImage *)ss_scanLineImg
{
    static UIImage *_scanLineImg = nil;
    if (_scanLineImg == nil) {
        _scanLineImg = [UIImage imageWithContentsOfFile:[[self ss_toolsBundle] pathForResource:@"ss_scan_line_img@3x" ofType:@"png"]];
    }
    return _scanLineImg;
}

+ (UIImage *)ss_scanGridImg
{
    static UIImage *_scanGridImg = nil;
    if (_scanGridImg == nil) {
        _scanGridImg = [UIImage imageWithContentsOfFile:[[self ss_toolsBundle] pathForResource:@"ss_scan_grid_img@3x" ofType:@"png"]];
    }
    return _scanGridImg;
}

@end
