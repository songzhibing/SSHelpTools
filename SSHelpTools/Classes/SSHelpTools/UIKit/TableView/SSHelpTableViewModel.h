//
//  SSHelpTableViewModel.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <Foundation/Foundation.h>
@class
SSHelpTableView,
SSHelpTableViewCell,
SSHelpTabViewSectionModel,
SSHelpTabViewHeaderModel,
SSHelpTabViewCellModel,
SSHelpTabViewFooterModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSHelpTabViewItemOnClick)(SSHelpTableView * _Nullable tableView, __kindof UICollectionReusableView * _Nullable reusableView, NSIndexPath * _Nullable indexPath);

typedef void (^SSHelpTabViewItemSubOnClick)(__kindof UICollectionReusableView * _Nullable reusableView, id _Nullable data);

//******************************************************************************

@interface SSHelpTableViewModel : NSObject

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewSectionModel *> *sectionModels;

@end

//******************************************************************************

@interface SSHelpTableViewMoveRule : NSObject

/// 是否支持移动、交换，默认NO
@property(nonatomic, assign) BOOL canMove;

/// 是否支持跨Section区域移动、交换，默认NO
@property(nonatomic, assign) BOOL canMoveTransSectionArea;

/// 开始位置
@property(nonatomic, strong) NSIndexPath *moveBeginIndexPath;

/// 结束位置
@property(nonatomic, strong) NSIndexPath *moveEndIndexPath;

/// 开始移动
@property(nonatomic, strong, nullable) void(^beginBlock)(SSHelpTableViewMoveRule *rule);

/// 结束移动
@property(nonatomic, strong, nullable) BOOL (^endBlock)(SSHelpTableViewMoveRule *rule);

@end

//******************************************************************************

@interface SSHelpTabViewSectionModel : NSObject

@property(nonatomic, strong) SSHelpTabViewHeaderModel * _Nullable headerModel;

/// 列数，默认1列
@property(nonatomic, assign) NSInteger columnCount;

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewCellModel *> *cellModels;

@property(nonatomic, strong) SSHelpTabViewFooterModel * _Nullable footerModel;

@property(nonatomic, assign) CGFloat minimumLineSpacing;

@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

@end

//******************************************************************************

@interface SSHelpTableViewItemModel: NSObject

/// item点击事件
@property(nonatomic, copy, nullable) SSHelpTabViewItemOnClick onClick;

/// item内部子控件点击事件
@property(nonatomic, copy, nullable) SSHelpTabViewItemSubOnClick subOnClick;

/// 推荐存储字典数据
@property(nonatomic, strong, nullable) __kindof NSDictionary *data;

/// 推荐存储模型数据
@property(nonatomic, strong, nullable) id model;

@end

//******************************************************************************

@interface SSHelpTabViewHeaderModel : SSHelpTableViewItemModel

@property(nonatomic, assign) CGFloat headerHeight;

@property(nonatomic, copy) NSString *headerIdentifier;

@property(nonatomic, assign) Class headerClass;

@end

//******************************************************************************

@interface SSHelpTabViewCellModel : SSHelpTableViewItemModel

@property(nonatomic, copy) NSString *cellIdentifier;

@property(nonatomic, assign) Class cellClass;

@property(nonatomic, assign) CGFloat cellHeght;

@property(nonatomic, strong) NSIndexPath *cellIndexPath;

/// 是否移动中
@property(nonatomic, assign) BOOL cellMoving;

@end

//******************************************************************************

@interface SSHelpTabViewFooterModel : SSHelpTableViewItemModel

@property(nonatomic, assign) CGFloat footerHeight;

@property(nonatomic, copy) NSString *footerIdentifier;

@property(nonatomic, assign) Class footerClass;

@end


NS_ASSUME_NONNULL_END
