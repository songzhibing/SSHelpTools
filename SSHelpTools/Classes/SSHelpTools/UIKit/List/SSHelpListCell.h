//
//  SSHelpListCell.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Cell视图
@interface SSHelpListCell : UICollectionViewCell

/// 模型数据
@property(nonatomic, weak) SSListCellModel *cellModel;

/// 复用准备
- (void)prepareForReuse NS_REQUIRES_SUPER;

/// 刷新
- (void)refresh;

@end



/// 特殊的横向无限布局视图
@interface SSListHorizontalFlowCell : UICollectionViewCell

/// Section模型数据
@property(nonatomic, weak) SSListSectionModel *sectionModel;

/// 刷新
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
