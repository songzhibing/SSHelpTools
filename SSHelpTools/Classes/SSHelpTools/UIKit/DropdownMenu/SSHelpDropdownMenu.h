//
//  SSHelpDropdownMenu.h
//  下拉菜单
//

#import "SSHelpView.h"
#import "SSHelpButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSDropdownMenuItem : NSObject

+ (instancetype)itemWithTitle:(NSString *)title;

@property(nonatomic, strong, nullable) UIImage *icon;

@property(nonatomic, copy  ) NSString *title;

@property(nonatomic, strong, nullable) id param;

@property(nonatomic, assign, readwrite) BOOL isSelected;

@property(nonatomic, assign, readonly) NSInteger index;

@end



/// 下拉列表视图
@interface SSHelpDropdownMenu : SSHelpView

@property(nonatomic, strong) NSMutableArray <SSDropdownMenuItem *> *data;

@property(nonatomic, strong) void (^didSelect)(NSMutableArray <SSDropdownMenuItem *> *selectItems);

@property(nonatomic, assign) BOOL supportMutableSelect; // 支持多选，default NO

@property(nonatomic, assign) CGFloat animateTime;       // 下拉动画时间 default: 0.25

@property(nonatomic, strong) SSHelpButton *mainBtn;      // 显示的按钮，可编辑

@property(nonatomic, assign) CGFloat           contentCornerRadius; //default: 6
@property(nonatomic, strong) UIColor         * contentBgColor;

@property(nonatomic, assign) CGFloat           optionItemHeight; //default: 44
@property(nonatomic, strong) UIColor         * optionBgColor;
@property(nonatomic, strong) UIFont          * optionFont;
@property(nonatomic, strong) UIColor         * optionTextColor;
@property(nonatomic)         NSTextAlignment   optionTextAlignment;
@property(nonatomic, assign) CGFloat           optionTextMarginLeft; // default: 15
@property(nonatomic, assign) NSInteger         optionNumberOfLines;
@property(nonatomic, assign) CGSize            optionIconSize;  // default:(15,15)
@property(nonatomic, assign) CGFloat           optionIconMarginRight; // default: 15
@property(nonatomic, strong) UIColor         * optionLineColor;
@property(nonatomic, assign) CGFloat           optionLineHeight; // default: 0.5
@property(nonatomic, assign) CGFloat           optionsListLimitHeight; // default: 0
@property(nonatomic, assign) BOOL              showsVerticalScrollIndicator; // default: NO

@end

NS_ASSUME_NONNULL_END


