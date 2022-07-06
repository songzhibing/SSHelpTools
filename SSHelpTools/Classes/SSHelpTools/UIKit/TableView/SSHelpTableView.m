//
//  SSHelpTableView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTableView.h"
#import "SSHelpTableView+Drag.h"
#import <Masonry/Masonry.h>

@interface SSHelpTableView()<SSHelpTableViewLayoutDataSource, UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) SSHelpTableViewLayout *flowLayout;

@property(nonatomic, strong) NSMutableArray <NSString *>*cellsOfIdentifierCache;

@end


@implementation SSHelpTableView

- (void)dealloc
{
    _collectionView = nil;
    _data = nil;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_setupCollectionView];
    }
    return self;
}

- (void)reload
{
    [_collectionView reloadData];
}

#pragma mark - Private Method

- (void)p_setupCollectionView
{
    if (_collectionView) return;
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = SSHELPTOOLSCONFIG.groupedBackgroundColor;
    
    _cellsOfIdentifierCache = [[NSMutableArray alloc] initWithCapacity:1];

    _flowLayout = [[SSHelpTableViewLayout alloc] init];
    _flowLayout.dataSource = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_flowLayout];
    _collectionView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0];
    _collectionView.contentInset = UIEdgeInsetsZero;
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.showsVerticalScrollIndicator = NO;
    if ([_collectionView respondsToSelector:@selector(setPrefetchingEnabled:)]) {
        _collectionView.prefetchingEnabled = NO;
    }
    if (@available(iOS 11.0, *)) {
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    if (@available(iOS 13.0, *)) {
        _collectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
    }
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)setContentInset:(UIEdgeInsets)contentInset
{
    _collectionView.contentInset = contentInset;
}

- (void)setMoveRule:(SSHelpTableViewMoveRule *)moveRule
{
    _moveRule = moveRule;
    if (moveRule.canMove) {
        if (@available(iOS 11.0, *)) {
            // 开启系统拖放手势，设置代理。
            _collectionView.dragInteractionEnabled = YES;
            _collectionView.dragDelegate = self;
            _collectionView.dropDelegate = self;
        } else {
            UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesture:)];
            [_collectionView addGestureRecognizer:longPressGesture];
        }
    }
}

- (void)longPressGesture:(UILongPressGestureRecognizer *)gesture
{
    [self collectionView:_collectionView longPressGestureRecognizerHandler:gesture];
}

#pragma mark - SSHelpFlowLayoutDataSource Method

/// Return per section's column number(must be greater than 0).
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(SSHelpTableViewLayout*)layout
    numberOfColumnInSection:(NSInteger)section
{
    SSHelpTabViewSectionModel *sectionModel = _data[section];
    if (sectionModel.columnCount!= NSNotFound) {
        return sectionModel.columnCount;
    }
    return 1;
}

/// Return per item's height
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpTableViewLayout*)layout
                itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section < _data.count) {
        if (indexPath.item < _data[indexPath.section].cellModels.count) {
            SSHelpTabViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
            return model.cellHeght;
        } else {
            /// 特殊，跨Section移动item时，需要预模拟排版当前Section所在的item样式，这里会
            /// 加上"被移动的Item",数据+1，导致这里cellModels溢出，因此这里特殊处理
            return _data[indexPath.section].cellModels.lastObject.cellHeght;
        }
    }
    return 0;
}

/// Return per section header view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpTableViewLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section
{
    SSHelpTabViewSectionModel *sectionModel = _data[section];
    if (sectionModel.headerModel) {
        return sectionModel.headerModel.headerHeight;
    }
    return 0;
}

/// Return per section footer view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpTableViewLayout*)layout referenceHeightForFooterInSection:(NSInteger)section
{
    SSHelpTabViewSectionModel *sectionModel = _data[section];
    if (sectionModel.footerModel) {
        return sectionModel.footerModel.footerHeight;
    }
    return 0;
}

/// Column spacing between columns
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpTableViewLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    SSHelpTabViewSectionModel *sectionModel = _data[section];
    return sectionModel.minimumLineSpacing;
}

/// The spacing between rows and rows
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpTableViewLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
{
    SSHelpTabViewSectionModel *sectionModel = _data[section];
    return sectionModel.minimumInteritemSpacing;
}

#pragma mark - UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _data.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _data?_data[section].cellModels.count:0;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    SSHelpTabViewSectionModel *sectionModel = _data[indexPath.section];
    
    if (UICollectionElementKindSectionHeader == kind) {
        if (sectionModel.headerModel) {
            NSString *_identifier = sectionModel.headerModel.headerIdentifier;

            if (![_cellsOfIdentifierCache containsObject:_identifier]) {
                [_cellsOfIdentifierCache addObject:_identifier];
                [collectionView registerClass:sectionModel.headerModel.headerClass
                   forSupplementaryViewOfKind:kind
                          withReuseIdentifier:_identifier];
            }
            SSHelpTableViewHeaderView *headerView = nil;
            headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_identifier forIndexPath:indexPath];
            headerView.modelData = sectionModel.headerModel;
            headerView.indexPath = indexPath;
            if (headerView && [headerView respondsToSelector:@selector(refresh)]) {
                [headerView refresh];
            }
            return headerView;
        }
    } else if (UICollectionElementKindSectionFooter == kind) {
        if (sectionModel.footerModel) {
            NSString *_identifier = sectionModel.footerModel.footerIdentifier;
            if (![_cellsOfIdentifierCache containsObject:_identifier]) {
                [_cellsOfIdentifierCache addObject:_identifier];
                [collectionView registerClass:sectionModel.footerModel.footerClass
                   forSupplementaryViewOfKind:kind
                          withReuseIdentifier:_identifier];
            }
            
            SSHelpTableViewFooterView *footerView = nil;
            footerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:_identifier forIndexPath:indexPath];
            footerView.modelData = sectionModel.footerModel;
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
    __kindof SSHelpTabViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
    model.cellIndexPath = indexPath;
    
    if (![_cellsOfIdentifierCache containsObject:model.cellIdentifier]) {
        [_cellsOfIdentifierCache addObject:model.cellIdentifier];
        [collectionView registerClass:model.cellClass forCellWithReuseIdentifier:model.cellIdentifier];
    }
    
    SSHelpTableViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:model.cellIdentifier forIndexPath:indexPath];
    cell.modelData = model;
    cell.indexPath = indexPath;
    [cell refresh];
    return cell;
}

/// 是否可以移动Cell
- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _moveRule.canMove;
}

/// 移动完成后的方法，交换数据
- (void)collectionView:(UICollectionView *)collectionView moveItemAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    if (sourceIndexPath.section == destinationIndexPath.section ) {
        SSHelpTabViewSectionModel *sectionModel =_data[destinationIndexPath.section];

        SSHelpTabViewCellModel *sourceModel =sectionModel.cellModels[sourceIndexPath.item];
        [sectionModel.cellModels removeObject:sourceModel];
        [sectionModel.cellModels insertObject:sourceModel atIndex:destinationIndexPath.item];
        
    } else {
        
        SSHelpTabViewSectionModel *sectionModel =_data[destinationIndexPath.section];

        SSHelpTabViewCellModel *sourceModel =sectionModel.cellModels[sourceIndexPath.item];
        [sectionModel.cellModels removeObject:sourceModel];
        [sectionModel.cellModels insertObject:sourceModel atIndex:destinationIndexPath.item];
    }
    
    // 需要主动调整数据内部索引值
    [_data enumerateObjectsUsingBlock:^(SSHelpTabViewSectionModel * _Nonnull sectionModel, NSUInteger section, BOOL * _Nonnull stop) {
        [sectionModel.cellModels enumerateObjectsUsingBlock:^(SSHelpTabViewCellModel * _Nonnull cellModel, NSUInteger item, BOOL * _Nonnull stop) {
            cellModel.cellIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
        }];
    }];
}

#pragma mark - UICollectionViewDelegate Method

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSLog(@"DidSelect item : %ld-%ld",indexPath.section,indexPath.item);
    SSHelpTabViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
    if (model.onClick) {
        __kindof UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
        model.onClick(self, cell, indexPath);
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
