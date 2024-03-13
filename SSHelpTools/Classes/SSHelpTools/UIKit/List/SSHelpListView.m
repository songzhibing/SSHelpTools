//
//  SSHelpListView.m
//  Pods
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <Masonry/Masonry.h>
#import "SSHelpListView.h"

/// 自定义列表视图 [别名...]
@implementation SSListView

@end


/// 自定义列表视图
@interface SSHelpListView()<UICollectionViewDataSource,UICollectionViewDelegate,SSListLayoutDelegate>

@property(nonatomic, strong) NSMutableArray *reusableViewIdentifiers;

@end


@implementation SSHelpListView

/// 初始化
+ (instancetype)ss_new
{
    SSHelpListLayout *layout = [[SSHelpListLayout alloc] init];
    SSHelpListView *list = [[self.class alloc] initWithFrame:UIScreen.mainScreen.bounds collectionViewLayout:layout];
    return list;
}

- (instancetype)initWithFrame:(CGRect)frame collectionViewLayout:(nonnull UICollectionViewLayout *)layout
{
    self = [super initWithFrame:frame collectionViewLayout:layout];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.alwaysBounceVertical = YES;
        self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.automaticallyAdjustsScrollIndicatorInsets = NO;
        self.backgroundColor = UIColor.systemGroupedBackgroundColor;
        
        self.layout = (SSHelpListLayout *)layout;
        self.layout.delegate = self;
        
        self.sections = NSMutableArray.array;
        self.reusableViewIdentifiers = NSMutableArray.array;
    }
    return self;
}

- (void)dealloc
{
    if (_reusableViewIdentifiers) {
        [_reusableViewIdentifiers removeAllObjects];
        _reusableViewIdentifiers = nil;
    }
    if (_layout) {
        _layout.delegate = nil;
        _layout = nil;
    }
}

#pragma mark -
#pragma mark - Private Method

- (SSListSectionModel *)getSectionModelAtSection:(NSInteger)section
{
    if (section<self.sections.count) {
        return self.sections[section];
    }
    return nil;
}

- (SSListCellModel *)getCellModelAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section<self.sections.count) {
        SSListSectionModel *section = self.sections[indexPath.section];
        if (indexPath.item<section.cellModels.count) {
            return section.cellModels[indexPath.item];
        }
    }
    SSListCellModel *empty = SSListCellModel.ss_new;
    return empty;
}

#pragma mark -
#pragma mark - SSListLayoutDelegate Method

- (SSListSectionModel *)layout:(__kindof UICollectionViewLayout *)layout getSectionModelAtSection:(NSInteger)section
{
    return [self getSectionModelAtSection:section];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource Method

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.sections.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section<self.sections.count) {
        return self.sections[section].cellModels.count;
    }
    return 0;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    @Tweakify(self);
    __kindof UICollectionReusableView *(^__register)(SSHelpListReusableViewModel *) = ^(SSHelpListReusableViewModel *model){
        if ([self_weak_.reusableViewIdentifiers containsObject:model.identifier]==NO){
            [self_weak_.reusableViewIdentifiers addObject:model.identifier];
            [collectionView registerClass:model.viewClass forSupplementaryViewOfKind:kind withReuseIdentifier:model.identifier];
        }
        id view = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:model.identifier forIndexPath:indexPath];
        return view;

    };
    SSListSectionModel *sectionModel = [self getSectionModelAtSection:indexPath.section];
    if (sectionModel) {
        if ([kind isEqualToString:_kSSListElementKindSectionHeader]) {
            sectionModel.headerModel.indexPath = indexPath;
            SSListHeader *header = __register(sectionModel.headerModel);
            header.headerModel = sectionModel.headerModel;
            [header refresh];
            return header;
        } else if ([kind isEqualToString:_kSSListElementKindSectionFooter]) {
            sectionModel.footerModel.indexPath = indexPath;
            SSListFooter *footer = __register(sectionModel.footerModel);
            footer.footerModel = sectionModel.footerModel;
            [footer refresh];
            return footer;
        } else if ([kind isEqualToString:_kSSListElementKindSectionBack]) {
            sectionModel.backerModel.indexPath = indexPath;
            SSListBacker *backer = __register(sectionModel.backerModel);
            backer.backerModel = sectionModel.backerModel;
            [backer refresh];
            return backer;
        }
    }
    // 异常
    SSHelpListReusableViewModel *emptyModel = SSHelpListReusableViewModel.ss_new;
    emptyModel.viewClass = UICollectionReusableView.class;
    return __register(emptyModel);;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    @Tweakify(self);
    __kindof UICollectionViewCell *(^__register)(NSString *, Class) = ^(NSString *fier, Class viewClass){
        if ([self_weak_.reusableViewIdentifiers containsObject:fier]==NO){
            [self_weak_.reusableViewIdentifiers addObject:fier];
            [collectionView registerClass:viewClass forCellWithReuseIdentifier:fier];
        }
        id cell = [collectionView dequeueReusableCellWithReuseIdentifier:fier forIndexPath:indexPath];
        return cell;
    };
    
    SSListSectionModel *sectionModel = [self getSectionModelAtSection:indexPath.section];
    if (sectionModel) {
        if (sectionModel.layoutStyle == SSListSectionLayoutStyleHorizontalInfinitely) {
            // 处理indexPath值
            [sectionModel.cellModels enumerateObjectsUsingBlock:^(SSListCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                obj.indexPath = [NSIndexPath indexPathForItem:idx inSection:indexPath.section];
            }];
            NSString *ids = @"_SSListCellDirectionHorizontal";
            SSListCellDirectionHorizontal *cell = __register(ids,SSListCellDirectionHorizontal.class);
            cell.sectionModel = sectionModel;
            [cell refresh];
            return cell;
        } else {
            SSListCellModel *cellModel = [self getCellModelAtIndexPath:indexPath];
            cellModel.indexPath = indexPath;
            SSListCell *cell = __register(cellModel.identifier, cellModel.viewClass);
            cell.cellModel = cellModel;
            [cell refresh];
            return cell;
        }
    }
    // 异常
    UICollectionViewCell *cell =__register(@"_SSListEmptyCell",UICollectionViewCell.class);
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

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(SSHelpListSupplementaryView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0))
{
    [view willDisplay];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingSupplementaryView:(SSHelpListSupplementaryView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    [view didEndDisplaying];
}

@end


