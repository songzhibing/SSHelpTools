//
//  SSHelpListViewModel.h
//  Pods
//
//  Created by 宋直兵 on 2024/1/9.
//

#import <Foundation/Foundation.h>
#import <Masonry/Masonry.h>
#import "SSHelpDefines.h"
#import "SSHelpListReusableViewModel.h"
#import "SSHelpListLayoutAttributes.h"

NS_ASSUME_NONNULL_BEGIN

/// Section布局风格
typedef NS_ENUM(NSInteger, SSListSectionLayoutStyle) {
    /// 默认瀑布流多列布局
    SSListSectionLayoutStyleDefault = 0,
    /// 横向有限布局,类似搜索历史记录
    SSListSectionLayoutStyleHorizontalFinite = 1,
    /// 横向无限布局
    SSListSectionLayoutStyleHorizontalInfinitely = 2,
};


/// Header数据模型
@interface SSListHeaderModel : SSHelpListReusableViewModel
@end


/// Footer数据模型
@interface SSListFooterModel : SSHelpListReusableViewModel
@end


/// Backer数据模型
@interface SSListBackerModel : SSHelpListReusableViewModel
@end


/// Cell数据模型
@interface SSListCellModel : SSHelpListReusableViewModel

/// 具体尺寸 [支持SSListSectionLayoutStyleHorizontalInfinitely:且都是等高不等宽、
///          支持SSListSectionLayoutStyleHorizontalFinite]
@property(nonatomic, assign) CGSize size;

@end


/// Section数据模型
@interface SSListSectionModel : NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 初始化
+ (instancetype)ss_new;

/// 布局风格
@property(nonatomic, assign) SSListSectionLayoutStyle layoutStyle;

/// 内间距 [section整体]
@property(nonatomic, assign) UIEdgeInsets sectionInset;

/// 内间距 [cells整体]
@property(nonatomic, assign) UIEdgeInsets contentInset;

/// 列数
@property(nonatomic, assign) NSInteger columnsCount;

/// 行间距
@property(nonatomic, assign) CGFloat minimumLineSpacing;

/// 列间距
@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

@property(nonatomic, strong) SSListHeaderModel *headerModel;

@property(nonatomic, strong) SSListFooterModel *footerModel;

@property(nonatomic, strong) SSListBackerModel *backerModel;

@property(nonatomic, strong) NSMutableArray <SSListCellModel *> *cellModels;

@end



/// ViewModel
@interface SSHelpListViewModel : NSObject

@end

NS_ASSUME_NONNULL_END


