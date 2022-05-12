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

@interface SSHelpTableViewModel : NSObject

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewSectionModel *> *sectionModels;

@end

@interface SSHelpTabViewSectionModel : NSObject

@property(nonatomic, strong) SSHelpTabViewHeaderModel *headerModel;

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewCellModel *> *cellModels;

@property(nonatomic, strong) SSHelpTabViewFooterModel *footerModel;

@end


@interface SSHelpTabViewHeaderModel : NSObject

@property(nonatomic, assign) CGFloat headerHeight;

@property(nonatomic, copy) NSString *headerIdentifier;

@property(nonatomic, assign) Class headerClass;

@property(nonatomic, copy) SSHelpTabViewItemOnClick onClick;

@end


@interface SSHelpTabViewCellModel : NSObject

@property(nonatomic, copy) NSString *cellIdentifier;

@property(nonatomic, assign) Class cellClass;

@property(nonatomic, assign) CGFloat cellHeght;

@property(nonatomic, copy) SSHelpTabViewItemOnClick onClick;

@end


@interface SSHelpTabViewFooterModel : NSObject

@property(nonatomic, assign) CGFloat footerHeight;

@property(nonatomic, copy) NSString *footerIdentifier;

@property(nonatomic, assign) Class footerClass;

@property(nonatomic, copy) SSHelpTabViewItemOnClick onClick;

@end


NS_ASSUME_NONNULL_END
