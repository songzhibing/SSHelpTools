//
//  SSHelpNavigationBar.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/9/3.
//  自定义顶部导航栏
//

#import "SSHelpView.h"
#import "SSHelpNavigationBarModel.h"
#import "SSHelpButton.h"

@class SSHelpNavigationBar;

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpNavigationBarDelegate <NSObject>

@optional
- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didLeftButton:(SSHelpButton *)button;

- (void)navigationBar:(SSHelpNavigationBar *)navigationBar didRightButton:(SSHelpButton *)button;

@end

@interface SSHelpNavigationBar : UIView

- (instancetype)initWithFrame:(CGRect)frame style:(SSHelpNavigationBarStyle)barStyle;

@property(nonatomic, weak) id<SSHelpNavigationBarDelegate> delegate;

@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) UIImageView *titleImage;

@property(nonatomic, strong, nullable) SSHelpButton *leftButton;

@property(nonatomic, strong, nullable) SSHelpButton *rightMoreButton;

@property(nonatomic, strong, nullable) SSHelpButton *rightExitButton;


- (void)resetNavigationBar:(SSHelpNavigationBarModel *)model;

- (void)resetLeftButtons:(NSArray <SSHelpButtonModel *> * _Nullable)leftButtons;

- (void)resetRightButtons:(NSArray <SSHelpButtonModel *> * _Nullable)rightButtons;

@end

NS_ASSUME_NONNULL_END
