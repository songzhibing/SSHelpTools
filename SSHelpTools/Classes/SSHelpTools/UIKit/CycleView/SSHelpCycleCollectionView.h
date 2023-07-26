//
//  SSHelpCycleCollectionView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/4/25.
//

#import "SSHelpView.h"
#import "SSHelpCycleCollectionViewCell.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpCycleCollectionViewDelegate <NSObject>

- (void)didSelectItemAtIndex:(NSInteger)index;

@end

@interface SSHelpCycleCollectionView : SSHelpView

/// 自动滚动时间间隔，默认3秒
@property(nonatomic, assign) NSTimeInterval autoDragTimeInterval;

@property(nonatomic, weak  ) id<SSHelpCycleCollectionViewDelegate> delegate;

@property(nonatomic, strong) UIPageControl *pageControl;

/// 设置数据1
@property(nonatomic, strong) NSArray <NSString *> *imagePaths;

/// 设置数据2
@property(nonatomic, strong) NSMutableArray <__kindof SSHelpCycleItem *> *items;

@end

NS_ASSUME_NONNULL_END
