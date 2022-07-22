//
//  SSHelpNavigationBarModel.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/6/27.
//

#import <Foundation/Foundation.h>
#import "SSHelpButton.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SSHelpNavigationBarStyle) {
    SSNavigationBarDefault       = (1 << 0), //默认空的导航
    SSNavigationBarWithLeftBack  = (1 << 1), //带左侧返回按钮的导航
    SSNavigationBarWithRightMenu = (1 << 2), //带右侧多功能按钮(类似小程序右侧'胶囊'按钮)的导航
};

@interface SSHelpNavigationBarModel : NSObject

/// 快速构建
/// @param dict 字典数据
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

/// 导航栏标题
@property(nonatomic, copy) NSString *title;

/// 导航栏标图,优先级高于标题;支持UIImage, NSString(图片转换后的Base64string)
@property(nonatomic, strong) id titleImage;

/// 导航栏左侧按钮 (建议最多2个，多个可用列表按钮)
@property(nonatomic, assign) NSArray <SSHelpButtonModel *> *leftButtons;

/// 导航栏右侧按钮 (建议最多2个，多个可用列表按钮)
@property(nonatomic, assign) NSArray <SSHelpButtonModel *> *rightButtons;

@end

NS_ASSUME_NONNULL_END
