//
//  SSHelpListCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListCell.h"
#import "UIColor+SSHelp.h"
#import <Masonry/Masonry.h>

@interface SSHelpListCell()

@property(nonatomic, strong) UILabel *debugLab;

@end



@implementation SSHelpListCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    #ifdef DEBUG
    if (self.cellModel.isDebug) {
        self.debugLab.text = @"(-,-)";
    }
    #endif
}

- (void)refresh
{
    #ifdef DEBUG
    if (self.cellModel.isDebug) {
        self.debugLab.text = [NSString stringWithFormat:@"(%td,%td)",self.cellModel.indexPath.section,self.cellModel.indexPath.item];
    }
    #endif
}

- (UILabel *)debugLab
{
    if (!_debugLab) {
        _debugLab = UILabel.new;
        _debugLab.backgroundColor =  [UIColor.ss_randomColor colorWithAlphaComponent:0.7f];
        [self.contentView addSubview:_debugLab];
        [_debugLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _debugLab;
}

@end


//******************************************************************************
//******************************************************************************


@interface SSListHorizontalFlowCell()<UICollectionViewDataSource,UICollectionViewDelegate>
@property(nonatomic, strong) UICollectionViewFlowLayout *flowLayout;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray *reusableViewIdentifiers;
@end


@implementation SSListHorizontalFlowCell

- (void)refresh
{
    if (!self.flowLayout) {
        self.flowLayout = [[UICollectionViewFlowLayout alloc] init];
        self.flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

        self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.flowLayout];
        self.collectionView.showsHorizontalScrollIndicator = NO;
        self.collectionView.showsVerticalScrollIndicator = NO;
        self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.collectionView.automaticallyAdjustsScrollIndicatorInsets = NO;
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0];
        [self.contentView addSubview:self.collectionView];
        [self.collectionView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];;
    }
    //self.flowLayout.sectionInset = self.sectionModel.sectionInset;
    //self.flowLayout.minimumLineSpacing = self.sectionModel.minimumLineSpacing;
    self.flowLayout.minimumInteritemSpacing = self.sectionModel.minimumInteritemSpacing;
    
    [self.collectionView reloadData];
}

- (SSListCellModel *)getCellModelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.item<self.sectionModel.cellModels.count) {
        return self.sectionModel.cellModels[indexPath.item];
    }
    SSListCellModel *empty = SSListCellModel.ss_new;
    return empty;
}

#pragma mark -
#pragma mark - UICollectionViewDataSource Method

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.sectionModel.cellModels.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    model.indexPath = indexPath;
    /// 注册class
    if (![self.reusableViewIdentifiers containsObject:model.identifier]) {
        [self.reusableViewIdentifiers addObject:model.identifier];
        [collectionView registerClass:model.class forCellWithReuseIdentifier:model.identifier];
    }
    /// 刷新cell
    SSHelpListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:model.identifier forIndexPath:indexPath];
    cell.cellModel = model;
    [cell refresh];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    if (model.callback) {
        model.callback(_kSSListCellEventsDidSelect);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    if (model.callback) {
        model.callback(_kSSListCellEventsDidDeselect);
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0))
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    if (model.callback) {
        model.callback(_kSSListCellEventsWillDisplay);
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    if (model.callback) {
        model.callback(_kSSListCellEventsDidEndDisplaying);
    }
}

#pragma mark -
#pragma mark - UICollectionViewDelegateFlowLayout Method

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    return model.size;
}

//- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section;
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end


