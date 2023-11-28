//
//  SSHelpListViewModel.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// Section 布局风格
typedef NS_ENUM(NSInteger, SSListSectionLayoutStyle) {
    SLSectionLayoutStyleDefault = 0,                 //常规布局
    SLSectionLayoutStyleHorizontalFinite = 1,        //横向有限布局,类似搜索历史记录
    SLSectionLayoutStyleHorizontalInfinitely = 2,    //横向无限布局
};

/// Section 代理选项
typedef NS_ENUM(NSInteger, SSListLayoutDelegateOptions) {
    SSListSectionOfLayoutStyle = 0, // Section.布局风格
    SSListSectionOfNumberOfColumn,  // Section.列数
    SSListSectionOfSectionInset,    // Section.内间距
    SSListSectionOfContentInset,    // Section.Items内间距
    SSListSectionOfSizeForItem,     // Section.Item尺寸
    SSListSectionOfHeightForItem,   // Section.Item高度
    SSListSectionOfMinimumLineSpacing,
    SSListSectionOfMinimumInteritemSpacing,
    SSListSectionOfHeightForHeader, // Section.Header高度
    SSListSectionOfHeightForFooter, // Section.Footer高度
    SSListSectionOfDecorationViewApply, // Section.DecorationView 自定义
};

UIKIT_EXTERN NSString *const _kSSListCellEventsDidSelect;
UIKIT_EXTERN NSString *const _kSSListCellEventsDidDeselect;
UIKIT_EXTERN NSString *const _kSSListCellEventsWillDisplay;
UIKIT_EXTERN NSString *const _kSSListCellEventsDidEndDisplaying;

typedef void(^SSListDecorationViewApply)(UIView *backgroundView);



/// Header、Cell、Footer 数据模型基类
@interface SSListReusableViewModel: NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 调试
@property(nonatomic, assign) BOOL isDebug;

/// 初始化
- (instancetype)init;

/// 初始化
+ (instancetype)ss_new;

/// 标识符
@property(nonatomic, copy  ) NSString *identifier;

/// 位置索引
@property(nonatomic, strong) NSIndexPath *indexPath;

/// 视图高度
@property(nonatomic, assign) CGFloat height;

/// 视图类名
@property(nonatomic, assign) Class class;

/// 事件回调
@property(nonatomic, copy  ) void (^callback)(NSString *_Nullable events);

/// 推荐存储字典数据
@property(nonatomic, strong) __kindof NSDictionary *_Nullable data;

/// 推荐存储模型数据
@property(nonatomic, strong) id _Nullable model;

@end

//******************************************************************************

/// Header数据模型
@interface SSListHeaderModel : SSListReusableViewModel

@end

//******************************************************************************

/// Footer数据模型
@interface SSListFooterModel : SSListReusableViewModel

@end

//******************************************************************************

/// Cell数据模型
@interface SSListCellModel : SSListReusableViewModel

/// 具体尺寸。某些横向布局需要具体尺寸
@property(nonatomic, assign) CGSize size;

@end

//******************************************************************************

/// Section数据模型
@interface SSListSectionModel : NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 初始化
+ (instancetype)ss_new;

/// 布局风格
@property(nonatomic, assign) SSListSectionLayoutStyle layoutStyle;

/// 整体内间距 (header+cells+footer)
@property(nonatomic, assign) UIEdgeInsets sectionInset;

/// 内容内间距 (cells)
@property(nonatomic, assign) UIEdgeInsets contentInset;

/// 列数
@property(nonatomic, assign) NSInteger columnsCount;

/// 行间距
@property(nonatomic, assign) CGFloat minimumLineSpacing;

/// 列间距
@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

@property(nonatomic, strong) SSListHeaderModel *_Nullable headerModel;

@property(nonatomic, strong) SSListFooterModel *_Nullable footerModel;

@property(nonatomic, strong) NSMutableArray <SSListCellModel *> *cellModels;

/// 装饰图应用回调，可自定义背景
@property(nonatomic, strong) SSListDecorationViewApply decorationViewApply;

@end

//******************************************************************************

@interface SSHelpListViewModel : NSObject

@end

NS_ASSUME_NONNULL_END


