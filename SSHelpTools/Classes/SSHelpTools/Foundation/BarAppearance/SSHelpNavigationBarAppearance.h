//
//  SSHelpNavigationBarAppearance.h
//  Pods
//
//  Created by 宋直兵 on 2022/5/11.
//  自定义外观配置, 兼容iOS10~
//

#import "SSHelpBarApparance.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpNavigationBarAppearance : SSHelpBarApparance

+ (SSHelpNavigationBarAppearance *)defaultAppearance;

/// Inline Title text attributes. If the font or color are unspecified, appropriate defaults are supplied.
@property(nonatomic, readwrite, copy) NSDictionary <NSAttributedStringKey, id> *titleTextAttributes;

@property(nonatomic, assign) BOOL translucent;

@end

NS_ASSUME_NONNULL_END
