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

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) SSHelpTabViewCellModel *modelData;

- (void)prepareForReuse;

- (void)refresh;

- (void)startMovingShakeAnimation;

- (void)stopMovingShakeAnimation;

@end
NS_ASSUME_NONNULL_END


