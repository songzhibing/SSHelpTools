//
//  SSHelpTableView+Drag.h
//  Pods
//
//  Created by 宋直兵 on 2022/6/13.
//  移动Cell: 如果自定义Cell尺寸且每个尺寸不尽相同，尽量设置成不允许跨Section
//

#import "SSHelpTableView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableView (Drag) <UICollectionViewDragDelegate,UICollectionViewDropDelegate>

/// 长按手势识别，用于移动Cell
- (void)collectionView:(UICollectionView *)collectionView longPressGestureRecognizerHandler:(UILongPressGestureRecognizer *)gesture;

@end

NS_ASSUME_NONNULL_END
