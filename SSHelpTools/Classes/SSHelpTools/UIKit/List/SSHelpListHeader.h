//
//  SSHelpListHeader.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Header视图
@interface SSHelpListHeader : UICollectionReusableView

/// 模型数据
@property(nonatomic, weak) SSListHeaderModel *headerModel;

/// 复用准备
- (void)prepareForReuse NS_REQUIRES_SUPER;

/// 刷新
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
