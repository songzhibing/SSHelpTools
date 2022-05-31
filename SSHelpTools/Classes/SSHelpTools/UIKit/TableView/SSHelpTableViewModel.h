//
//  SSHelpTableViewModel.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <Foundation/Foundation.h>
@class
SSHelpTableView,
SSHelpTabViewCell,
SSHelpTabViewSectionModel,
SSHelpTabViewHeaderModel,
SSHelpTabViewCellModel,
SSHelpTabViewFooterModel;

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSHelpTabViewItemOnClick)(SSHelpTableView *tableView, __kindof UICollectionReusableView *reusableView, NSIndexPath *indexPath);

typedef void (^SSHelpTabViewCellRefresh)(__kindof UICollectionReusableView *reusableView);

@interface SSHelpTableViewModel : NSObject

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewSectionModel *> *sectionModels;

@end

@interface SSHelpTabViewSectionModel : NSObject

@property(nonatomic, strong) SSHelpTabViewHeaderModel * _Nullable headerModel;

/// 默认1列
@property(nonatomic, assign) NSInteger columnCount;

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewCellModel *> *cellModels;

@property(nonatomic, strong) SSHelpTabViewFooterModel * _Nullable footerModel;

@end

@interface SSHelpTableViewItemModel: NSObject

@property(nonatomic, copy, nullable) NSString *identifier;

@property(nonatomic, assign) CGFloat height;

@property(nonatomic, strong) UIColor *backgroundColor;

@property(nonatomic, assign, nullable) Class className;

@property(nonatomic, copy, nullable) SSHelpTabViewCellRefresh refreshBlock;

@property(nonatomic, copy, nullable) SSHelpTabViewItemOnClick onClick;

/// 推荐存储字典数据
@property(nonatomic, strong, nullable) __kindof NSDictionary *data;

/// 推荐存储模型数据
@property(nonatomic, strong, nullable) id model;

@end

@interface SSHelpTabViewHeaderModel : SSHelpTableViewItemModel

@property(nonatomic, assign) CGFloat headerHeight;

@property(nonatomic, copy) NSString *headerIdentifier;

@property(nonatomic, assign) Class headerClass;

@end


@interface SSHelpTabViewCellModel : SSHelpTableViewItemModel

@property(nonatomic, copy) NSString *cellIdentifier;

@property(nonatomic, assign) Class cellClass;

@property(nonatomic, assign) CGFloat cellHeght;

@end


@interface SSHelpTabViewFooterModel : SSHelpTableViewItemModel

@property(nonatomic, assign) CGFloat footerHeight;

@property(nonatomic, copy) NSString *footerIdentifier;

@property(nonatomic, assign) Class footerClass;

@end


NS_ASSUME_NONNULL_END
