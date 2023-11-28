//
//  SSHelpListView.h
//  Pods
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"
#import "SSHelpListLayout.h"
#import "SSHelpListFooter.h"
#import "SSHelpListHeader.h"
#import "SSHelpListCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpListView : UICollectionView

/// 初始化
+ (instancetype)ss_new;

/// 布局对象
@property(nonatomic, strong) SSHelpListLayout *layout;

/// 分组数据模型
@property(nonatomic, strong) NSMutableArray <SSListSectionModel *> *sections;

@end

NS_ASSUME_NONNULL_END
