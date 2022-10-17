//
//  SSHelpTableView+Drag.m
//  Pods
//
//  Created by 宋直兵 on 2022/6/13.
//

#import "SSHelpTableView+Drag.h"

@implementation SSHelpTableView (Drag)

- (void)collectionView:(UICollectionView *)collectionView longPressGestureRecognizerHandler:(UILongPressGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            CGPoint point = [gesture locationInView:collectionView];
            NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:point];
            if (indexPath) {
                // 记录-开始索引值
                self.moveRule.moveBeginIndexPath = indexPath;
                BOOL supporTransSectionAreaMove = self.moveRule.canMoveTransSectionArea;
                
                // 修改属性值
                [self.data enumerateObjectsUsingBlock:^(SSHelpTabViewSectionModel * _Nonnull sectionModel, NSUInteger section, BOOL * _Nonnull stop) {
                    if (supporTransSectionAreaMove) {
                        [sectionModel.cellModels enumerateObjectsUsingBlock:^(SSHelpTabViewCellModel * _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                            cellModel.cellMoving = YES;
                        }];
                    } else {
                        if (section==indexPath.section) {
                            [sectionModel.cellModels enumerateObjectsUsingBlock:^(SSHelpTabViewCellModel * _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                                cellModel.cellMoving = YES;
                            }];
                        }
                    }
                }];
                
                // 开始动画
                for (SSHelpTableViewCell *cell in [collectionView visibleCells]) {
                    [cell startMovingShakeAnimation];
                }
                
                // 系统
                [collectionView beginInteractiveMovementForItemAtIndexPath:indexPath];
                
                // 回调
                if (self.moveRule.beginBlock) {
                    self.moveRule.beginBlock(self.moveRule);
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            {
                CGPoint touchPoint = [gesture locationInView:collectionView];
                NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:touchPoint];
                SSHelpTableViewCell *cell = (SSHelpTableViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
                if (self.moveRule.canMoveTransSectionArea) {
                    // 全区可交换
                    [collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:collectionView]];
                } else {
                    
                    if ((indexPath.section==0) && (indexPath.item==0) && !cell) {
                        SSLifeCycleLog(@"当前在 header or footer area..");
                        break;
                    }
                    else {
                        SSLifeCycleLog(@"当前在  area..%td vs %td",self.moveRule.moveBeginIndexPath.section,indexPath.section);
                    }
                    // 同区可交换
                    if (self.moveRule.moveBeginIndexPath.section == indexPath.section) {
                            SSLifeCycleLog(@"当前在  area..");

                        [collectionView updateInteractiveMovementTargetPosition:[gesture locationInView:collectionView]];
                    }
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            {
                NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:[gesture locationInView:collectionView]];
                self.moveRule.moveEndIndexPath = indexPath;
                BOOL finish = YES;
                if (self.moveRule.endBlock) {
                    finish = self.moveRule.endBlock(self.moveRule);
                }
                if (finish) {
                    // 修改属性值
                    [self.data enumerateObjectsUsingBlock:^(SSHelpTabViewSectionModel * _Nonnull sectionModel, NSUInteger idx, BOOL * _Nonnull stop) {
                            [sectionModel.cellModels enumerateObjectsUsingBlock:^(SSHelpTabViewCellModel * _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                                cellModel.cellMoving = NO;
                            }];
                    }];
                    
                    // 停止动画
                    for (SSHelpTableViewCell *cell in [collectionView visibleCells]) {
                        [cell stopMovingShakeAnimation];
                    }
                    
                    // 系统
                    [collectionView endInteractiveMovement];
                }
            }
            break;
        default:
            {
                // 修改属性值
                [self.data enumerateObjectsUsingBlock:^(SSHelpTabViewSectionModel * _Nonnull sectionModel, NSUInteger idx, BOOL * _Nonnull stop) {
                        [sectionModel.cellModels enumerateObjectsUsingBlock:^(SSHelpTabViewCellModel * _Nonnull cellModel, NSUInteger idx, BOOL * _Nonnull stop) {
                            cellModel.cellMoving = NO;
                        }];
                }];
                
                // 停止动画
                for (SSHelpTableViewCell *cell in [collectionView visibleCells]) {
                    [cell stopMovingShakeAnimation];
                }
                
                // 系统
                [collectionView cancelInteractiveMovement];
            }
            break;
    }
}

#pragma mark - UICollectionViewDragDelegate Method

/// 拖动item
- (NSArray <UIDragItem *>*)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0))
{
    self.moveRule.moveBeginIndexPath = indexPath;
    
    SSHelpTabViewCellModel *cellModel = self.data[indexPath.section].cellModels[indexPath.item];
    NSItemProvider *itemProvider = [[NSItemProvider alloc] initWithObject:cellModel.cellIdentifier];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:itemProvider];
    dragItem.localObject = cellModel;
    return @[dragItem];
}

/// 设置拖动预览信息
- (nullable UIDragPreviewParameters *)collectionView:(UICollectionView *)collectionView dragPreviewParametersForItemAtIndexPath:(NSIndexPath *)indexPath  API_AVAILABLE(ios(11.0))
{
    // 预览图为圆角，背景色为clearColor。
//    UIDragPreviewParameters *previewParameters = [[UIDragPreviewParameters alloc] init];
//    SSHelpTableViewCell *cell = (SSHelpTableViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
//    cell.transform = CGAffineTransformMakeScale(0.8f, 0.8f);
//    previewParameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:cell.bounds cornerRadius:10];
//    previewParameters.backgroundColor = [UIColor clearColor];
//    return previewParameters;
    return nil;
}

#pragma mark - UICollectionViewDropDelegate Method

/// 是否接收拖动的item。
/// 当内容被拖入集合视图边界内时，集合视图会调用collectonView:canHandleDropSession:方法，
/// 查看当前数据模型是否可以接收拖动的内容。如果可以接收拖动的内容，集合视图会继续调用其它方法。
- (BOOL)collectionView:(UICollectionView *)collectionView
  canHandleDropSession:(id<UIDropSession>)session  API_AVAILABLE(ios(11.0))
{
    return [session canLoadObjectsOfClass:[NSString class]];
}

/// 拖动过程中不断反馈item位置。
/// 当用户手指移动时，集合视图跟踪手势，检测可能的drop位置，
/// 并通知collectionView:dropSessionDidUpdate:withDestinationIndexPath:代理方法。
/// 该方法可选实现，但一般推荐实现。实现该方法后，UICollectonView会及时反馈将如何合并、
/// 放置拖动的cell到当前视图。该方法会被频繁调用，实现过程要尽可能快速、简单。
- (UICollectionViewDropProposal *)collectionView:(UICollectionView *)collectionView
                            dropSessionDidUpdate:(id<UIDropSession>)session
                        withDestinationIndexPath:(NSIndexPath *)destinationIndexPath API_AVAILABLE(ios(11.0))
{
    UICollectionViewDropProposal *dropProposal;
    if (session.localDragSession) {
        // 拖动手势源自同一app。

        BOOL transSectionArea = NO;
        if (self.moveRule.moveBeginIndexPath.section != destinationIndexPath.section) {
            transSectionArea = YES;
        } else {
            if (self.moveRule.moveEndIndexPath.section != 0 && destinationIndexPath.section ==0) {
                // 位于 header or footer 区域
                transSectionArea = YES;
            }
        }
        
        if (transSectionArea && !self.moveRule.canMoveTransSectionArea) {
            // 不允许跨 Section
            dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
        } else {
            dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationMove intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
        }
    } else {
        // 拖动手势源自其它app。
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }
    return dropProposal;
}

/*
 Called when the drop session begins tracking in the collection view's coordinate space.
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnter:(id<UIDropSession>)session
API_AVAILABLE(ios(11.0))
{
}

/*
 Called when the drop session is no longer being tracked inside the collection view's coordinate space.
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidExit:(id<UIDropSession>)session API_AVAILABLE(ios(11.0))
{
}

/*
 Called when the drop session completed, regardless of outcome. Useful for performing any cleanup.
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnd:(id<UIDropSession>)session API_AVAILABLE(ios(11.0))
{
    if (self.moveRule.endBlock) {
        self.moveRule.endBlock(self.moveRule);
    }
}

/// 当手指离开屏幕时，UICollectionView会调用collectionView:performDropWithCoordinator:方法，
/// 必须实现该方法以接收拖动的数据。实现步骤如下：
- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator  API_AVAILABLE(ios(11.0))
{
    // nullable
    self.moveRule.moveEndIndexPath = coordinator.destinationIndexPath;
    
    SSLifeCycleLog(@"开始目标(%td,%td)-最终目标 (%td,%td)",self.moveRule.moveBeginIndexPath.section,self.moveRule.moveBeginIndexPath.item,coordinator.destinationIndexPath.section,coordinator.destinationIndexPath.item);
    // 如果coordinator.destinationIndexPath存在，直接返回；如果不存在，则返回（0，0)位置。
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath ?: [NSIndexPath indexPathForItem:0 inSection:0];
    
    // 在collectionView内，重新排序时只能拖动一个cell。
    if (coordinator.items.count == 1 && coordinator.items.firstObject.sourceIndexPath) {
        NSIndexPath *sourceIndexPath = coordinator.items.firstObject.sourceIndexPath;
        // 将多个操作合并为一个动画。
        [collectionView performBatchUpdates:^{
            // 将拖动内容从数据源删除，插入到新的位置。
            SSHelpTabViewCellModel *cellModel = coordinator.items.firstObject.dragItem.localObject;
            [self.data[sourceIndexPath.section].cellModels removeObjectAtIndex:sourceIndexPath.item];
            [self.data[destinationIndexPath.section].cellModels insertObject:cellModel atIndex:destinationIndexPath.item];

            // 更新collectionView。
            [collectionView moveItemAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
        } completion:^(BOOL finished) {

        }];
        // 以动画形式移动cell。
        [coordinator dropItem:coordinator.items.firstObject.dragItem toItemAtIndexPath:destinationIndexPath];
    }
}

@end
