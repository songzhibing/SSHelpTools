//
//  SSHelpTableView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTableView.h"
#import "SSHelpTableViewLayout.h"
#import "SSHelpTabViewCell.h"
#import "SSHelpTableViewModel.h"
#import "SSHelpTableViewHeaderView.h"
#import "SSHelpTableViewFooterView.h"

#import <Masonry/Masonry.h>

@interface SSHelpTableView()<SSHelpTableViewLayoutDataSource, UICollectionViewDelegate,UICollectionViewDataSource>

@property(nonatomic, strong) UICollectionView *collectionView;

@property(nonatomic, strong) SSHelpTableViewLayout *flowLayout;

@property(nonatomic, strong) NSMutableArray <NSString *>*cellsOfIdentifierCache;

@end


@implementation SSHelpTableView

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc .... ",self);
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
    self.userInteractionEnabled = YES;
    
    _cellsOfIdentifierCache = [[NSMutableArray alloc] initWithCapacity:1];

    _flowLayout = [[SSHelpTableViewLayout alloc] init];
    _flowLayout.dataSource = self;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:_flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.backgroundColor = self.backgroundColor;
    [self addSubview:_collectionView];
    [_collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - SSHelpFlowLayoutDataSource Protocol Method

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
    SSHelpTabViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
    return model.cellHeght;
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

#pragma mark - UICollectionViewDataSource Protocol Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return _data?_data.count:0;
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
            headerView.currentModel = sectionModel.headerModel;
            headerView.currentIndexPath = indexPath;
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
            footerView.currentModel = sectionModel.footerModel;
            footerView.currentIndexPath = indexPath;
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
    SSHelpTabViewCellModel *model = _data[indexPath.section].cellModels[indexPath.item];
    
    if (![_cellsOfIdentifierCache containsObject:model.cellIdentifier]) {
        [_cellsOfIdentifierCache addObject:model.cellIdentifier];
        [collectionView registerClass:model.cellClass forCellWithReuseIdentifier:model.cellIdentifier];
    }
    
    SSHelpTabViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:model.cellIdentifier forIndexPath:indexPath];
    cell.currentModel = model;
    cell.currentIndexPath = indexPath;
    [cell refresh];
    return cell;
}

#pragma mark - UICollectionViewDelegate Protocol Method

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
