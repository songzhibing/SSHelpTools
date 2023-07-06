//
//  SSHelpTableViewCell.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import <UIKit/UIKit.h>
#import "SSHelpCollectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpCollectionViewCell : UICollectionViewCell

/// 索引
@property(nonatomic, strong) NSIndexPath *indexPath;

/// 模型数据
@property(nonatomic, strong) SSCollectionViewCellModel *cellModel;

/// 复用重置
- (void)prepareForReuse NS_REQUIRES_SUPER;

/// 刷新
- (void)refresh;

@end
NS_ASSUME_NONNULL_END


