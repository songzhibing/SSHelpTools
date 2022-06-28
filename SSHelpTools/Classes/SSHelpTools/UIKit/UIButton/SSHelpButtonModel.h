//
//  SSHelpButtonModel.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/6/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SSHelpButtonStyle) {
    SSButtonStyleCustom   = 0, // 默认自定义按钮
    SSButtonStyleBack,         // 普通的返回按钮
    SSButtonStyleLocation,     // 定位按钮
    SSButtonStyleList,         // 展开列表按钮
    SSButtonStyleRefresh,      // 刷新按钮
    SSButtonStyleRightMore,    // '胶囊'左按钮
    SSButtonStyleRightExit,    // '胶囊'右按钮
};

@interface SSHelpButtonModel : NSObject

/// 快速构建
/// @param dict 字典数据
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

/// 按钮类型
@property(nonatomic, assign) SSHelpButtonStyle style;

/// 按钮标识
@property(nonatomic, copy) NSString *identifier;

/// 按钮图标 (支持图片或者是图片的Base64String字符串)
@property(nonatomic, strong) id icon;

/// 按钮标题
@property(nonatomic, copy) NSString *title;

/// 按钮点击事件 (对GCUIButtonStyleList列表按钮，此事件不起作用，内部自动处理)
@property(nonatomic, copy) void(^block)(id sender);

/// 列表按钮包含的子按钮
@property(nonatomic, strong, nullable)  NSArray <NSDictionary *> *childButtons;


@end

NS_ASSUME_NONNULL_END
