//
//  SSHelpListFooter.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// Footer视图
@interface SSHelpListFooter : UICollectionReusableView

/// 模型数据
@property(nonatomic, weak) SSListFooterModel *footerModel;

/// 复用准备
- (void)prepareForReuse NS_REQUIRES_SUPER;

/// 刷新
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
