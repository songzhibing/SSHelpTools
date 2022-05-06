//
//  SSHelpButton.h
//  SSHelpTools
//
//  Created by songzhibing on 2017/8/8.
//  Copyright © 2017年 songzhibing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SSHelpButtonStyle) {
    SSButtonStyleCustom   = 0, // 默认自定义按钮
    SSButtonStyleBack,         // 普通的返回按钮
    SSButtonStyleLocation,     // 定位按钮
    SSButtonStyleList,         // 展开列表按钮
    SSButtonStyleScan,         // 扫一扫按钮
    SSButtonStyleRefresh,      // 刷新按钮
    SSButtonStyleFlashlight,   // 手电筒按钮
};

@interface SSHelpButtonModel : NSObject

/// 按钮类型 (使用Model创建按钮，按钮类型style优先级最低，按钮图标icon优先级最高)
@property(nonatomic, assign) SSHelpButtonStyle style;

/// 按钮标识
@property(nonatomic, copy) NSString *identifier;

/// 按钮图标 (支持图片或者把图片的Base64String字符串)
@property(nonatomic, strong) id icon;

/// 按钮标题
@property(nonatomic, copy) NSString *title;

/// 按钮点击事件 (对GCUIButtonStyleList列表按钮，此事件不起作用，内部自动处理)
@property(nonatomic, copy) void(^block)(id sender);

/// 列表按钮包含的子按钮
@property(nonatomic, assign, nullable)  NSArray <NSDictionary *> *childButtons;

/// 快速构建
/// @param dict 字典数据
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

//******************************************************************************
//******************************************************************************

@interface SSHelpButton : UIButton

+ (instancetype)buttonWithStyle:(SSHelpButtonStyle)buttonStyle;

+ (instancetype)buttonWithModel:(SSHelpButtonModel*)buttonModel;

@property(nonatomic, assign) SSHelpButtonStyle style;

@property(nonatomic, copy  ) NSString *identifier;

@property(nonatomic, copy  ) NSString *normalTitle;

@property(nonatomic, strong) UIColor *normalTitleColor;

@property(nonatomic, strong) UIImage *normalImage;

@property(nonatomic, strong) UIImage *highlightedImage;

@property(nonatomic, strong) UIImage *selectedImage;

@property(nonatomic, assign) CGRect backgroundRect;

@property(nonatomic, assign) CGRect contentRect;

@property(nonatomic, assign) CGRect contentImageRect;

@property(nonatomic, assign) CGRect titleContentRect;

/// 响应区域需要改变的大小，负值表示往外扩大，正值表示往内缩小
@property(nonatomic, assign) UIEdgeInsets outsideEdge;

@property(nonatomic, assign) NSArray <NSDictionary *> *_Nullable childButtons;

/// 支持多设
@property(nonatomic, copy  ) void(^onClick)(SSHelpButton *sender);

@end

NS_ASSUME_NONNULL_END
