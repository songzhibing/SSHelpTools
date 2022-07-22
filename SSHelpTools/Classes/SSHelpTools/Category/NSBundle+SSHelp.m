//
//  NSBundle+SSHelp.m
//  AFNetworking
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "NSBundle+SSHelp.h"
#import "SSHelpToolsConfig.h"

@implementation NSBundle (SSHelp)

+ (NSString * _Nullable)ss_bundlePath:(NSString *)bundleName
{
    // #use_frameworks!
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:bundleName ofType:@"bundle"];
    if (!bundlePath) {
        // use_frameworks!
        NSString *path = [NSString stringWithFormat:@"Frameworks/%@.framework/%@",bundleName,bundleName];
        bundlePath = [[NSBundle mainBundle] pathForResource:path ofType:@"bundle"];
    }
    return bundlePath;
}

+ (UIImage * _Nullable)ss_loadImage:(NSString *)imageName fromBundle:(NSString *)bundleName
{
    NSString *bundlePath = [self ss_bundlePath:bundleName];
    if (bundlePath) {
        NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
        if (bundle) {
            UIImage *image = [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
            return image;
        }
    }
    return nil;
}

+ (NSBundle *)ss_toolsBundle
{
    static NSBundle *toolsBundle;
    if (!toolsBundle) {
        toolsBundle = [NSBundle bundleWithPath:[self ss_bundlePath:@"SSHelpTools"]];
    }
    return toolsBundle;
}

+ (UIImage *)ss_toolsBundleImage:(NSString *)imageName
{
    return [UIImage imageNamed:imageName inBundle:[self ss_toolsBundle] compatibleWithTraitCollection:nil];
}

@end
