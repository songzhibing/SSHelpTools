//
//  SSHelpCollectionViewModel.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <Foundation/Foundation.h>
#import "SSHelpDefines.h"
#import "SSHelpCollectionViewLayout.h"

@class
SSCollectionViewSectionModel,
SSCollectionViewHeaderModel,
SSCollectionViewCellModel,
SSCollectionViewFooterModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSCollectionReusableViewOnClick)(__kindof UICollectionView * _Nullable collectionView, __kindof UICollectionReusableView * _Nullable reusableView, NSIndexPath * _Nullable indexPath, id _Nullable data);

//******************************************************************************

@interface SSHelpCollectionViewModel : NSObject

@end

//******************************************************************************

@interface SSCollectionVieMoveRule : NSObject

+ (instancetype)ss_new;

/// 是否支持移动、交换，默认NO
@property(nonatomic, assign) BOOL canMove;

/// 是否支持跨Section区域移动、交换，默认NO
@property(nonatomic, assign) BOOL canMoveTransSectionArea;

/// 开始位置
@property(nonatomic, strong) NSIndexPath *moveBeginIndexPath;

/// 结束位置
@property(nonatomic, strong, nullable) NSIndexPath *moveEndIndexPath;

/// 开始移动
@property(nonatomic, strong, nullable) void(^beginBlock)(SSCollectionVieMoveRule *rule);

/// 结束移动
@property(nonatomic, strong, nullable) BOOL (^endBlock)(SSCollectionVieMoveRule *rule);

@end

//******************************************************************************

@interface SSCollectionViewSectionModel : NSObject

+ (instancetype)ss_new;

@property(nonatomic, strong) SSCollectionViewHeaderModel * _Nullable headerModel;

@property(nonatomic, strong) NSMutableArray <SSCollectionViewCellModel *> *cellModels;

@property(nonatomic, strong) SSCollectionViewFooterModel * _Nullable footerModel;

@property(nonatomic, assign) NSInteger columnCount;

@property(nonatomic, assign) CGFloat minimumLineSpacing;

@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

@property(nonatomic, assign) SSSectionLayoutStyle layoutStyle;

@property(nonatomic, assign) UIEdgeInsets sectionInset;

/// Section背景
@property(nonatomic, strong) void (^applyLayoutCallback) (UIView *backgroundView);

@end

//******************************************************************************

@interface SSCollectionReusableViewModel: NSObject

/// 点击事件传递，携带一个字符串参数
@property(nonatomic, copy) SSBlockString callback;

/// 点击事件传递，携带参数
@property(nonatomic, copy, nullable) SSCollectionReusableViewOnClick onClick;

/// 点击事件传递，不携带参数
@property(nonatomic, copy) SSBlockVoid didSelect _kApiDeprecatedWarning("pod.version > 0.2.0 后不建议使用，请使用 callback");

/// 推荐存储字典数据
@property(nonatomic, strong, nullable) __kindof NSDictionary *data;

/// 推荐存储模型数据
@property(nonatomic, strong, nullable) id model;

@end

//******************************************************************************

@interface SSCollectionViewHeaderModel : SSCollectionReusableViewModel

+ (instancetype)ss_new;

@property(nonatomic, assign) CGFloat headerHeight;

@property(nonatomic, copy) NSString *headerIdentifier;

@property(nonatomic, assign) Class headerClass;

@end

//******************************************************************************

@interface SSCollectionViewCellModel : SSCollectionReusableViewModel

+ (instancetype)ss_new;

@property(nonatomic, copy  ) NSString *cellIdentifier;

@property(nonatomic, assign) Class cellClass;

/// 高度, 常规布局需要
@property(nonatomic, assign) CGFloat cellHeight;

/// (宽度,高度), 横向限制布局需要
@property(nonatomic, assign) CGSize cellSize;

@property(nonatomic, strong) UIColor *cellBackgroundColor;

@property(nonatomic, strong) NSIndexPath *cellIndexPath;

@property(nonatomic, weak  ) id delegate;

@end

//******************************************************************************

@interface SSCollectionViewFooterModel : SSCollectionReusableViewModel

+ (instancetype)ss_new;

@property(nonatomic, assign) CGFloat footerHeight;

@property(nonatomic, copy) NSString *footerIdentifier;

@property(nonatomic, assign) Class footerClass;

@end


NS_ASSUME_NONNULL_END
