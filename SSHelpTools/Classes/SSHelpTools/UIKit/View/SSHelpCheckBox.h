//
//  SSHelpCheckBox.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/7/21.
//

#import <SSHelpTools/SSHelpTools.h>
@class SSHelpCheckBox;
@class SSHelpCheckBoxItem;

NS_ASSUME_NONNULL_BEGIN

typedef void(^SSHelpChakBoxSelected)(SSHelpCheckBox *checkbox, SSHelpCheckBoxItem *item, NSInteger index);

typedef NS_ENUM(NSUInteger, SSHelpCheckBoxTriangleStyle) {
    SSHelpCheckBoxTriangleStyleNull,
    SSHelpCheckBoxTriangleStyleCenter,
    SSHelpCheckBoxTriangleStyleLeft,
    SSHelpCheckBoxTriangleStyleRight,
};

typedef NS_ENUM(NSUInteger, SSHelpCheckBoxPosition) {
    SSHelpCheckBoxPositionAlwaysDown, // 总是在控件下面
    SSHelpCheckBoxPositionAlwaysUp,   // 总是在控件上面，展示不下自动调整方向
};

@interface SSHelpCheckBoxItem : NSObject
+ (instancetype)itemWithTitle:(NSString *)title;
+ (instancetype)itemWithTitle:(NSString *)title data:(id)data;
@property(nonatomic, strong, nullable) UIImage *normalIcon;
@property(nonatomic, strong, nullable) UIImage *selectedIcon;
@property(nonatomic, copy, nonnull) NSString *title;
@property(nonatomic, strong, nullable) id data;
@end



@protocol SSHelpCheckBoxDelegate <NSObject>

@optional

- (void)checkbox:(SSHelpCheckBox *)checkbox didSelectOptionAtIndex:(NSUInteger)index item:(SSHelpCheckBoxItem *)item; /// 点击某一项

@end


@interface SSHelpCheckBox : SSHelpView
@property(nonatomic, strong) NSMutableArray <SSHelpCheckBoxItem *> *dataSouce;
@property(nonatomic, weak) id <SSHelpDropdownMenuDelegate> delegate;
@property(nonatomic, strong) SSHelpChakBoxSelected didSelectedHandler;

@property(nonatomic, assign) SSHelpCheckBoxPosition position;

@property(nonatomic, copy  ) NSString        *title;
@property(nonatomic, strong) UIColor         *titleBgColor;
@property(nonatomic, strong) UIFont          *titleFont;
@property(nonatomic, strong) UIColor         *titleColor;
@property(nonatomic, assign) NSTextAlignment  titleAlignment;
@property(nonatomic, assign) UIEdgeInsets     titleEdgeInsets;

@property(nonatomic, strong) UIImage *rotateIcon; // 右侧旋转箭头
@property(nonatomic, assign) CGSize   rotateIconSize;
@property(nonatomic, assign) CGFloat  rotateIconMarginRight; // default: 7.5
@property(nonatomic, strong) UIColor *rotateIconTint;

@property(nonatomic, assign) CGFloat showSpace; // 视图出现时与目标view的间隙

@property(nonatomic, assign) SSHelpCheckBoxTriangleStyle triangleStyle;
@property(nonatomic, assign) CGFloat triangleHeight; // 小三角的高度
@property(nonatomic, assign) CGFloat triangleWidth; // 小三角的宽度

@property(nonatomic, assign) CGFloat roundMargin; // 调整弹出视图背景四周的空隙
@property(nonatomic, strong) UIColor *shadowColor; // 阴影颜色 默认#666666
@property(nonatomic, strong) UIColor *containerBackgroudColor; // 弹出视图背景色 默认#eeeeee
@property(nonatomic, assign) CGFloat containerCornerRadius; // 弹出视图背景的圆角半径
@property(nonatomic, assign) CGFloat containerBorderWidth; // 边框宽度默认0.5( 必须 >= 0.5)
@property(nonatomic, strong) UIColor *containerBorderColor; // 边框颜色 默认#666666

@property(nonatomic, assign) CGFloat           optionItemHeight; //default: 44
@property(nonatomic, strong) UIColor         * optionBgColor;
@property(nonatomic, strong) UIFont          * optionFont;
@property(nonatomic, strong) UIColor         * optionTextColor;
@property(nonatomic, assign) NSTextAlignment   optionTextAlignment;
@property(nonatomic, assign) CGFloat           optionTextMarginLeft; // default: 15
@property(nonatomic, assign) NSInteger         optionNumberOfLines;
@property(nonatomic, assign) CGSize            optionIconSize;  // default:(15,15)
@property(nonatomic, assign) CGFloat           optionIconMarginRight; // default: 15
@property(nonatomic, strong) UIColor         * optionLineColor;
@property(nonatomic, assign) CGFloat           optionLineHeight; // default: 0.5
@property(nonatomic, assign) NSInteger         optionMaxRow;  // default: 5

/*
 选项列表的最大高度。超出最大高度后，选项可滚动 （optionsListLimitHeight <= 0 时，下拉列表将显示所有选项）
 The maximum height of the drop-down list, beyond which the options can be scrolled （When optionsListLimitHeight <= 0, the drop-down list shows all options）
 */
@property(nonatomic,assign) CGFloat           optionsListLimitHeight; // default: 0
@property(nonatomic,assign) BOOL              showsVerticalScrollIndicatorOfOptionsList; // default: YES


@property(nonatomic,assign) CGFloat animateTime;   // 下拉动画时间 default: 0.25


- (void)reloadOptionsData;

- (void)showOptionBox; // 显示下拉菜单

- (void)hideDropDown; // 隐藏下拉菜单

@end

NS_ASSUME_NONNULL_END
