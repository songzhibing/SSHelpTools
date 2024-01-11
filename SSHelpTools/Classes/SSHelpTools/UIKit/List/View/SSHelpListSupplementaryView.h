//
//  SSHelpListSupplementaryView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2024/1/9.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 自定义装饰视图
@interface SSHelpListSupplementaryView : UICollectionReusableView

/// 视图刷新
- (void)refresh;

/// 视图即将显示
- (void)willDisplay;

/// 视图结束显示
- (void)didEndDisplaying;

@end


/// Section.Header视图
@interface SSListHeader : SSHelpListSupplementaryView

/// 模型数据
@property(nonatomic, weak) SSListHeaderModel *headerModel;

@end


/// Section.Footer视图
@interface SSListFooter : SSHelpListSupplementaryView

/// 模型数据
@property(nonatomic, weak) SSListFooterModel *footerModel;

@end


/// Section.Backer视图
@interface SSListBacker : SSHelpListSupplementaryView

/// 模型数据
@property(nonatomic, weak) SSListBackerModel *backerModel;

@end

NS_ASSUME_NONNULL_END


