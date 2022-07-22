//
//  SSHelpSlidePageView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/10/22.
//  自定义带标题栏的可滑动视图
//

#import "SSHelpView.h"

NS_ASSUME_NONNULL_BEGIN

@class SSHelpSlidePageView;

@protocol GCSlidePageViewDataSource <NSObject>

@required

/// 标题栏数据
- (NSArray <NSString *> *)titlesInSlidePageView:(SSHelpSlidePageView *)pageView;

@end


@protocol GCSlideScrollViewDelegate <NSObject>

/// 进入焦点
- (void)slidePageView:(SSHelpSlidePageView *)pageView displayView:(UIView *)contentView atIndex:(NSInteger)index;

/// 离开焦点
- (void)slidePageView:(SSHelpSlidePageView *)pageView didEndDisplayingView:(UIView *)contentView atIndex:(NSInteger)index;

@end


@interface SSHelpSlidePageView : SSHelpView

@property(nonatomic, weak) id <GCSlidePageViewDataSource> dataSource;

@property(nonatomic, weak) id <GCSlideScrollViewDelegate> delegate;

/// 刷新
- (void)reload;

/// 加载第几页
/// @param index 索引
- (void)loadViewAtIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
