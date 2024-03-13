//
//  SSHelpListCell.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 自定义Cell视图
@interface SSHelpListCell : UICollectionViewCell

/// 模型数据
@property(nonatomic, weak) SSListCellModel *cellModel;

/// 刷新
- (void)refresh;

@end



/// 自定义Cell视图 [别名...]
@interface SSListCell : SSHelpListCell

@end



/// 自定义横向排版占位Cell视图
@interface SSListCellDirectionHorizontal : SSHelpListCell

/// Section数据模型
@property(nonatomic, weak) SSListSectionModel *sectionModel;

@end

NS_ASSUME_NONNULL_END


