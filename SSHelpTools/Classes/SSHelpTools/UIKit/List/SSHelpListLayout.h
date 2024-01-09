//
//  SSHelpListLayout.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 协议
@protocol SSListLayoutDelegate <NSObject>

@required

/// 返回指定Section数据模型
- (SSListSectionModel *)layout:(__kindof UICollectionViewLayout *)layout getSectionModelAtSection:(NSInteger)section;

@end


/// 自定义布局
@interface SSHelpListLayout : UICollectionViewLayout

/// 代理
@property(nonatomic, weak) id <SSListLayoutDelegate> delegate;

/// Section.Header 悬浮
@property(nonatomic, assign) BOOL sectionHeadersPinToVisibleBounds;

@end


NS_ASSUME_NONNULL_END
