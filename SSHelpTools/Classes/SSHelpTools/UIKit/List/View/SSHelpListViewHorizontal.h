//
//  SSHelpListViewHorizontal.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2024/1/9.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 自定义横向排版列表视图 [不建议单独使用..]
@interface SSHelpListViewHorizontal : UICollectionView

/// 初始化
+ (instancetype)ss_new;

/// Section数据模型
@property(nonatomic, weak) SSListSectionModel *sectionModel;

@end

NS_ASSUME_NONNULL_END
