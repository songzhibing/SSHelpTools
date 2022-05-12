//
//  SSHelpTabViewCell.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import <UIKit/UIKit.h>
@class SSHelpTabViewCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTabViewCell : UICollectionViewCell

@property(nonatomic, strong) UILabel *titleLab;

@property(nonatomic, strong) NSIndexPath *currentIndexPath;

@property(nonatomic, strong) SSHelpTabViewCellModel *currentModel;

/// 刷新
- (void)refresh;

@end
NS_ASSUME_NONNULL_END


