//
//  SSHelpNavigationBarAppearance.h
//  Pods
//
//  Created by 宋直兵 on 2022/5/11.
//  自定义外观配置，主要目的是兼容iOS10~13版本，如果工程最低支持版本>=iOS13建议使用系统类
//

#import "SSHelpBarApparance.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpNavigationBarAppearance : SSHelpBarApparance

/// Inline Title text attributes. If the font or color are unspecified, appropriate defaults are supplied.
@property (nonatomic, readwrite, copy) NSDictionary <NSAttributedStringKey, id> *titleTextAttributes;

@end

NS_ASSUME_NONNULL_END
