//
//  SSHelpTableViewCell.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import <UIKit/UIKit.h>
#import "SSHelpTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableViewCell : UICollectionViewCell

/// 索引
@property(nonatomic, strong) NSIndexPath *indexPath;

/// 模型数据
@property(nonatomic, strong) SSHelpTabViewCellModel *modelData;

/// 复用重置
- (void)prepareForReuse NS_REQUIRES_SUPER;

/// 刷新
- (void)refresh;

/// 开始"摆动"动画
- (void)startMovingShakeAnimation;

/// 停止"摆动"动画
- (void)stopMovingShakeAnimation;

@end
NS_ASSUME_NONNULL_END


