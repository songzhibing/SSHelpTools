//
//  UIDevice+SSHelp.h
//  Pods
//
//  Created by 宋直兵 on 2022/6/24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (SSHelp)

/// 优先返回ipv4，次之ipv6
+ (NSString *)ss_IPAdress;

@end

NS_ASSUME_NONNULL_END
