//
//  SSHelpTableViewCell.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import <UIKit/UIKit.h>
@class SSHelpTabViewCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableViewCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *debugTitleLab;

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) SSHelpTabViewCellModel *modelData;

- (void)prepareForReuse;

/// 刷新
- (void)refresh;

- (void)startMovingShakeAnimation;

- (void)stopMovingShakeAnimation;

@end
NS_ASSUME_NONNULL_END


