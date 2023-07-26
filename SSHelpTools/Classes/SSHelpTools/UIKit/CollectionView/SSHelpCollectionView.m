//
//  SSHelpCollectionView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/18.
//

#import "SSHelpCollectionView.h"
#import "SSHelpCollectionViewLayout.h"
#import "SSHelpDefines.h"
#import "SSHelpCollectionViewModel.h"

@interface SSHelpCollectionView ()<SSHelpCollectionViewLayoutDataSource,
UICollectionViewDelegate,
UICollectionViewDataSource,
UICollectionViewDragDelegate,
UICollectionViewDropDelegate>

@property(nonatomic, strong) NSMutableArray <NSString *>*reuseIdentifiers;

@property(nonatomic, assign) BOOL debugLogEnable;

// 设置拖放策略
@property(nonatomic, strong, nullable) SSCollectionVieMoveRule *moveRule;

@end

@implementation SSHelpCollectionView

+ (instancetype)ss_new
{
    return [[self class] creatWithFrame:CGRectZero];
}

+ (instancetype)creatWithFrame:(CGRect)frame
{
    SSHelpCollectionViewLayout *layout = [[SSHelpCollectionViewLayout alloc] init];
    __kindof UICollectionView *collectionView = [[[self class] alloc] initWithFrame:frame collectionViewLayout:layout];
    layout.dataSource = collectionView;
    return collectionView;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        _data = NSMutableArray.array;
        self.delegate = self;
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.automaticallyAdjustsScrollIndicatorInsets = NO;
        self.backgroundColor = SSHELPTOOLSCONFIG.groupedBackgroundColor;
#ifdef DEBUG
        self.debugLogEnable = YES;
#endif
    }
    return self;
}

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self)
}

- (void)setMoveRule:(SSCollectionVieMoveRule *)moveRule
{
    _moveRule = moveRule;
    if (moveRule.canMove) {
        // 开启系统拖放手势
        self.dragInteractionEnabled = YES;
        self.dragDelegate = self;
        self.dropDelegate = self;
    } else {
        self.dragInteractionEnabled = NO;
        self.dragDelegate = nil;
        self.dropDelegate = nil;
    }
}

#pragma mark -
#pragma mark - SSHelpCollectionViewLayoutDataSource Method

/// Return per section's column number(must be greater than 0).
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(SSHelpCollectionViewLayout*)layout
    numberOfColumnInSection:(NSInteger)section
{
    NSInteger columnNumber = 1;
    if (section < _data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        if (sectionModel.columnCount > 0) {
            columnNumber = sectionModel.columnCount;
        }
    }
    return columnNumber;
}

/// Return per item's height
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout
                itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _data.count) {
        if (indexPath.item < _data[indexPath.section].cellModels.count) {
            SSCollectionViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
            return model.cellHeight;
        } else {
            // Tip: 在跨Section区域移动item时，需要预模拟排版目标Section所在的item样式，
            // 导致目标数据源+1，会crash溢出，在这种情况下默认高度返回0，如果是单区间同尺寸内移动，
            // 可以返回固定值；

            // Tip: 这里返回最后一个item尺寸
            SSCollectionViewCellModel *model = _data[indexPath.section].cellModels.lastObject;
            if (model) {
                return model.cellHeight;
            }
        }
    }
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(SSHelpCollectionViewLayout*)layout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _data.count) {
        if (indexPath.item < _data[indexPath.section].cellModels.count) {
            SSCollectionViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
            return model.cellSize;
        }
    }
    return CGSizeZero;
}

///
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout insetForSectionAtIndex:(NSInteger)section
{
    if (section<_data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        if (sectionModel) {
            return sectionModel.sectionInset;
        }
    }
    return UIEdgeInsetsZero;
}

/// Return per section header view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section
{
    if (section<_data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        if (sectionModel && sectionModel.headerModel) {
            return sectionModel.headerModel.headerHeight;
        }
    }
    return 0;
}

/// Return per section footer view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout referenceHeightForFooterInSection:(NSInteger)section
{
    if (section<_data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        if (sectionModel && sectionModel.footerModel) {
            return sectionModel.footerModel.footerHeight;
        }
    }
    return 0;
}

/// Column spacing between columns
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    if (section<_data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        return sectionModel.minimumLineSpacing;
    }
    return 0;
}

/// The spacing between rows and rows
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
{
    if (section<_data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        return sectionModel.minimumInteritemSpacing;
    }
    return 0;
}

/// The section layout style
- (SSSectionLayoutStyle)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout layoutStyle:(NSInteger)section
{
    if (section<_data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        return sectionModel.layoutStyle;
    }
    return SSSectionLayoutStyleNormal;
}

#pragma mark - UICollectionViewDataSource Method

- (void)collectionView:(UICollectionView *)collectionView sectionLayoutAttributes:(SSCollectionSectionLayoutAttributes *)attributes inSection:(NSInteger)section
{
    if (section<_data.count) {
        SSCollectionViewSectionModel *sectionModel = _data[section];
        attributes.applyCallback = sectionModel.applyLayoutCallback;
    }
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section<_data.count) {
        return _data[section].cellModels.count;
    }
    return 0;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SSCollectionViewSectionModel *sectionModel = _data[indexPath.section];
    
    if (UICollectionElementKindSectionHeader == kind) {
        if (sectionModel.headerModel) {
            NSString *_identifier = sectionModel.headerModel.headerIdentifier;
            if (![_reuseIdentifiers containsObject:_identifier]) {
                [_reuseIdentifiers addObject:_identifier];
                [collectionView registerClass:sectionModel.headerModel.headerClass
                   forSupplementaryViewOfKind:kind
                          withReuseIdentifier:_identifier];
            }
            SSHelpCollectionViewHeader *headerView = nil;
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_identifier forIndexPath:indexPath];
            headerView.headerModel = sectionModel.headerModel;
            headerView.indexPath = indexPath;
            if (headerView && [headerView respondsToSelector:@selector(refresh)]) {
                [headerView refresh];
            }
            return headerView;
        }
    } else if (UICollectionElementKindSectionFooter == kind) {
        if (sectionModel.footerModel) {
            NSString *_identifier = sectionModel.footerModel.footerIdentifier;
            if (![_reuseIdentifiers containsObject:_identifier]) {
                [_reuseIdentifiers addObject:_identifier];
                [collectionView registerClass:sectionModel.footerModel.footerClass
                   forSupplementaryViewOfKind:kind
                          withReuseIdentifier:_identifier];
            }
            
            SSHelpCollectionViewFooter *footerView = nil;
            footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_identifier forIndexPath:indexPath];
            footerView.footerModel = sectionModel.footerModel;
            footerView.indexPath = indexPath;
            if (footerView && [footerView respondsToSelector:@selector(refresh)]) {
                [footerView refresh];
            }
            return footerView;
        }
    }
    return nil;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    __kindof SSCollectionViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
    model.cellIndexPath = indexPath;
    
    if (![_reuseIdentifiers containsObject:model.cellIdentifier]) {
        [_reuseIdentifiers addObject:model.cellIdentifier];
        [collectionView registerClass:model.cellClass forCellWithReuseIdentifier:model.cellIdentifier];
    }
    
    SSHelpCollectionViewCell *cell = (__kindof SSHelpCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:model.cellIdentifier forIndexPath:indexPath];
    cell.cellModel = model;
    cell.indexPath = indexPath;
    [cell refresh];
    return cell;
}

/// 是否可以移动Cell
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL canMode = _moveRule?_moveRule.canMove:NO;
    return canMode;
}

#pragma mark -
#pragma mark - UICollectionViewDelegate Method

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _data.count) {
        if (indexPath.item < _data[indexPath.section].cellModels.count) {
            //SSLog(@"DidSelectedItem (%ld,%ld)",indexPath.section,indexPath.item);
            
            SSCollectionViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
            if (model.onClick) {
                __kindof UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
                model.onClick(collectionView, cell, indexPath, model.data);
            }
            
            if (model.didSelect) {
                model.didSelect();
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0))
{
    if (_viewDelegate && [_viewDelegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)]) {
        [_viewDelegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_viewDelegate && [_viewDelegate respondsToSelector:@selector(collectionView:didEndDisplayingCell:forItemAtIndexPath:)]) {
        [_viewDelegate collectionView:collectionView didEndDisplayingCell:cell forItemAtIndexPath:indexPath];
    }
}

#pragma mark -
#pragma mark - UICollectionViewDragDelegate Method

/// 拖动
- (NSArray <UIDragItem *>*)collectionView:(UICollectionView *)collectionView itemsForBeginningDragSession:(id<UIDragSession>)session atIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(11.0))
{
    _moveRule.moveBeginIndexPath = indexPath;
    _moveRule.moveEndIndexPath = nil;
    if (_moveRule.beginBlock) {
        _moveRule.beginBlock(_moveRule);
    }
    if (_debugLogEnable) {
        SSLog(@"拖动起始位置:(%td,%td)",indexPath.section,indexPath.item);
    }
    SSCollectionViewCellModel *cellModel = _data[indexPath.section].cellModels[indexPath.item];
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


#pragma mark -
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
                        withDestinationIndexPath:(NSIndexPath *)destinationIndexPath
{
    UICollectionViewDropProposal *dropProposal;
    if (session.localDragSession) {
        // 拖动手势源自同一app。
        BOOL transSectionArea = NO;
        if (_moveRule.moveBeginIndexPath.section != destinationIndexPath.section) {
            transSectionArea = YES;
            if (_debugLogEnable) {
                SSLog(@"拖动跨区:(%td,%td) -> (%td,%td)",_moveRule.moveBeginIndexPath.section,_moveRule.moveBeginIndexPath.item,destinationIndexPath.section,destinationIndexPath.row);
            }
        } else {
            if (self.moveRule.moveEndIndexPath.section != 0 && destinationIndexPath.section ==0) {
                transSectionArea = YES;
                if (_debugLogEnable) {
                    SSLog(@"拖动位于header or footer区:(%td,%td) -> (%td,%td)",_moveRule.moveBeginIndexPath.section,_moveRule.moveBeginIndexPath.item,destinationIndexPath.section,destinationIndexPath.row);
                }
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
        //dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationCopy intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
        dropProposal = [[UICollectionViewDropProposal alloc] initWithDropOperation:UIDropOperationForbidden intent:UICollectionViewDropIntentInsertAtDestinationIndexPath];
    }
    return dropProposal;
}

/// 当手指离开屏幕时，UICollectionView会调用collectionView:performDropWithCoordinator:方法，
/// 必须实现该方法以接收拖动的数据。实现步骤如下：
- (void)collectionView:(UICollectionView *)collectionView performDropWithCoordinator:(id<UICollectionViewDropCoordinator>)coordinator  API_AVAILABLE(ios(11.0))
{
    _moveRule.moveEndIndexPath = coordinator.destinationIndexPath;
    if (_debugLogEnable) {
        SSLog(@"拖动最终位置：(%td,%td) -> (%td,%td)",_moveRule.moveBeginIndexPath.section,_moveRule.moveBeginIndexPath.item,coordinator.destinationIndexPath.section,coordinator.destinationIndexPath.item);
    }

    // 如果coordinator.destinationIndexPath存在，直接返回；如果不存在，则返回（0，0)位置。
    NSIndexPath *destinationIndexPath = coordinator.destinationIndexPath ?: [NSIndexPath indexPathForItem:0 inSection:0];
    
    // 在collectionView内，重新排序时只能拖动一个cell。
    if (coordinator.items.count == 1 && coordinator.items.firstObject.sourceIndexPath) {
        NSIndexPath *sourceIndexPath = coordinator.items.firstObject.sourceIndexPath;
        // 将多个操作合并为一个动画。
        [collectionView performBatchUpdates:^{
            // 将拖动内容从数据源删除，插入到新的位置。
            SSCollectionViewCellModel *cellModel = coordinator.items.firstObject.dragItem.localObject;
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

/*
 Called when the drop session completed, regardless of outcome. Useful for performing any cleanup.
 */
- (void)collectionView:(UICollectionView *)collectionView dropSessionDidEnd:(id<UIDropSession>)session API_AVAILABLE(ios(11.0))
{
    if (_debugLogEnable) {
        SSLog(@"拖动流程完成...");
    }
    
    // 需要主动调整数据内部索引值
    [_data enumerateObjectsUsingBlock:^(SSCollectionViewSectionModel * _Nonnull sectionModel, NSUInteger section, BOOL * _Nonnull stop) {
        [sectionModel.cellModels enumerateObjectsUsingBlock:^(SSCollectionViewCellModel * _Nonnull cellModel, NSUInteger item, BOOL * _Nonnull stop) {
            cellModel.cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        }];
    }];
    //
    [[collectionView visibleCells] enumerateObjectsUsingBlock:^(__kindof SSHelpCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj refresh];
    }];
    if (self.moveRule.endBlock) {
        self.moveRule.endBlock(self.moveRule);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


@end
