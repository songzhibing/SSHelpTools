//
//  SSHelpCollectionViewModel.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <Foundation/Foundation.h>
@class
SSCollectionViewSectionModel,
SSCollectionViewHeaderModel,
SSCollectionViewCellModel,
SSCollectionViewFooterModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSCollectionReusableViewOnClick)(__kindof UICollectionView * _Nullable collectionView, __kindof UICollectionReusableView * _Nullable reusableView, NSIndexPath * _Nullable indexPath, id _Nullable data);

//******************************************************************************

@interface SSHelpCollectionViewModel : NSObject

@property(nonatomic, strong) NSMutableArray <SSCollectionViewSectionModel *> *sectionModels;

@end

//******************************************************************************

@interface SSCollectionVieMoveRule : NSObject

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

@property(nonatomic, strong) SSCollectionViewHeaderModel * _Nullable headerModel;

/// 列数，默认1列
@property(nonatomic, assign) NSInteger columnCount;

@property(nonatomic, strong) NSMutableArray <SSCollectionViewCellModel *> *cellModels;

@property(nonatomic, strong) SSCollectionViewFooterModel * _Nullable footerModel;

@property(nonatomic, assign) CGFloat minimumLineSpacing;

@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

@property(nonatomic, assign) UIEdgeInsets sectionInset;

@end

//******************************************************************************

@interface SSCollectionReusableViewModel: NSObject

/// 点击事件传递参数
@property(nonatomic, copy, nullable) SSCollectionReusableViewOnClick onClick;

/// 推荐存储字典数据
@property(nonatomic, strong, nullable) __kindof NSDictionary *data;

/// 推荐存储模型数据
@property(nonatomic, strong, nullable) id model;

@end

//******************************************************************************

@interface SSCollectionViewHeaderModel : SSCollectionReusableViewModel

@property(nonatomic, assign) CGFloat headerHeight;

@property(nonatomic, copy) NSString *headerIdentifier;

@property(nonatomic, assign) Class headerClass;

@end

//******************************************************************************

@interface SSCollectionViewCellModel : SSCollectionReusableViewModel

@property(nonatomic, copy  ) NSString *cellIdentifier;

@property(nonatomic, assign) Class cellClass;

@property(nonatomic, assign) CGFloat cellHeght;

@property(nonatomic, strong) UIColor *cellBackgrounColor;

@property(nonatomic, strong) NSIndexPath *cellIndexPath;

@end

//******************************************************************************

@interface SSCollectionViewFooterModel : SSCollectionReusableViewModel

@property(nonatomic, assign) CGFloat footerHeight;

@property(nonatomic, copy) NSString *footerIdentifier;

@property(nonatomic, assign) Class footerClass;

@end


NS_ASSUME_NONNULL_END
