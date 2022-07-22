//
//  SSHelpTableViewHeaderView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <UIKit/UIKit.h>
#import "SSHelpTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableViewHeaderView : UICollectionReusableView

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) SSHelpTabViewHeaderModel*modelData;

- (void)refresh;


@end

NS_ASSUME_NONNULL_END
