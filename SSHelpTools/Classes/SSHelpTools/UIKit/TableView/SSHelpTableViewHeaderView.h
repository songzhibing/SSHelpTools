//
//  SSHelpTableViewHeaderView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <UIKit/UIKit.h>
@class SSHelpTabViewHeaderModel;

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableViewHeaderView : UICollectionReusableView

@property(nonatomic, strong) NSIndexPath *indexPath;

@property(nonatomic, strong) SSHelpTabViewHeaderModel*modelData;

/// 刷新
- (void)refresh;


@end

NS_ASSUME_NONNULL_END
