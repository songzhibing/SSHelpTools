//
//  SSHelpListViewHorizontal.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2024/1/9.
//

#import "SSHelpListViewHorizontal.h"
#import "SSHelpListCell.h"

@interface SSHelpListViewHorizontal() <UICollectionViewDataSource,UICollectionViewDelegate>

@property(nonatomic, strong) NSMutableArray *reusableViewIdentifiers;

@end



@implementation SSHelpListViewHorizontal

/// 初始化
+ (instancetype)ss_new
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;

    SSHelpListViewHorizontal *list = [[self alloc] initWithFrame:UIScreen.mainScreen.bounds collectionViewLayout:layout];
    return list;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.automaticallyAdjustsScrollIndicatorInsets = NO;
        self.delegate = self;
        self.dataSource = self;
        self.reusableViewIdentifiers = [[NSMutableArray array] init];
    }
    return self;
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

    // 注册class
    if (![self.reusableViewIdentifiers containsObject:model.identifier]) {
        [self.reusableViewIdentifiers addObject:model.identifier];
        [collectionView registerClass:model.viewClass forCellWithReuseIdentifier:model.identifier];
    }
    // 刷新cell
    SSHelpListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:model.identifier forIndexPath:indexPath];
    cell.cellModel = model;
    [cell refresh];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    model.eventHandler(_kSSListCellEventsDidSelect);
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    model.eventHandler(_kSSListCellEventsDidDeselect);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0))
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    model.eventHandler(_kSSListCellEventsWillDisplay);
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    model.eventHandler(_kSSListCellEventsDidEndDisplaying);
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return self.sectionModel.minimumInteritemSpacing;
}

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section;

//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section;

@end
