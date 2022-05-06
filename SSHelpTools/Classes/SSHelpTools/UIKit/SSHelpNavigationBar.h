//
//  SSHelpNavigationBar.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/9/3.
//  自定义顶部导航栏
//

#import "SSHelpView.h"
#import "SSHelpButton.h"

@class SSHelpNavigationBar;

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SSHelpNavigationBarStyle) {
    SSNavigationBarDefault = 1 << 0,
    SSNavigationBarWithLeftBack = 1 << 1,
    SSNavigationBarWithLeftBackAndCustomRight = 1 << 2,
};

@interface SSHelpNavigationBarModel : NSObject

/// 导航栏标题
@property(nonatomic, copy) NSString *title;

/// 导航栏标图,优先级高于标题;支持UIImage, NSString(图片转换后的Base64string)
@property(nonatomic, strong) id titleImage;

/// 导航栏左侧按钮 (最多2个，多个可用列表按钮)
@property(nonatomic, assign) NSArray <SSHelpButtonModel *> *leftButtons;

/// 导航栏右侧按钮 (最多2个，多个可用列表按钮)
@property(nonatomic, assign) NSArray <SSHelpButtonModel *> *rightButtons;

/// 快速构建
/// @param dict 字典数据
+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

//******************************************************************************
//******************************************************************************

@protocol SSHelpNavigationBarDelegate <NSObject>

@optional
- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didLeftButton:(SSHelpButton *)button;

- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didRightButton:(SSHelpButton *)button;

@end

@interface SSHelpNavigationBar : UIView

- (instancetype)initWithFrame:(CGRect)frame style:(SSHelpNavigationBarStyle)barStyle;

@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIImageView *titleImage;

@property(nonatomic, strong) SSHelpButton *leftButton;

@property(nonatomic, strong) SSHelpButton *rightButton;

@property(nonatomic, weak) id<SSHelpNavigationBarDelegate> delegate;

- (void)resetNavigationBar:(SSHelpNavigationBarModel *)model;

- (void)resetLeftButtons:(NSArray <SSHelpButtonModel *> * _Nullable)leftButtons;

- (void)resetRightButtons:(NSArray <SSHelpButtonModel *> * _Nullable)rightButtons;

@end

NS_ASSUME_NONNULL_END
