//
//  SSHelpTableViewHeaderView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <UIKit/UIKit.h>
#import "SSHelpCollectionViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpCollectionViewHeader : UICollectionReusableView

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) SSCollectionViewHeaderModel *headerModel;

- (void)prepareForReuse NS_REQUIRES_SUPER;

- (void)refresh;


@end

NS_ASSUME_NONNULL_END
