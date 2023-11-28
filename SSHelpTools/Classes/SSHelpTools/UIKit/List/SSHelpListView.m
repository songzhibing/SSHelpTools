//
//  SSHelpListView.m
//  Pods
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListView.h"
#import "SSHelpDefines.h"

@interface SSHelpListView() <UICollectionViewDataSource,UICollectionViewDelegate,SSListLayoutDelegate>

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

- (SSListLayoutDelegateReturn *)layout:(SSHelpListLayout *)layout
                                option:(SSListLayoutDelegateOptions)option
                             indexPath:(NSIndexPath *)indexPath
{
    SSListSectionModel *sectionModel = [self getSectionModelAtSection:indexPath.section];
    SSListCellModel *cellModel = [self getCellModelAtIndexPath:indexPath];
    SSListLayoutDelegateReturn *returnModel = SSListLayoutDelegateReturn.new;

    switch (option) {
        case SSListSectionOfLayoutStyle:
            /// 布局风格
            returnModel.integeValue = sectionModel.layoutStyle;
            break;
        case SSListSectionOfNumberOfColumn:
            /// 列数
            returnModel.integeValue = sectionModel.columnsCount;
            break;
        case SSListSectionOfSizeForItem:
            /// item尺寸
            returnModel.sizeValue = cellModel.size;
            break;
        case SSListSectionOfHeightForItem:
            /// item高度
            returnModel.floatValue = cellModel.height;
            break;
            
        case SSListSectionOfSectionInset:
            /// 内间距
            returnModel.insetsValue = sectionModel.sectionInset;
            break;
        case SSListSectionOfContentInset:
            /// 内容内间距
            returnModel.insetsValue = sectionModel.contentInset;
            break;
        case SSListSectionOfMinimumLineSpacing:
            /// 行间距
            returnModel.floatValue = sectionModel.minimumLineSpacing;
            break;
        case SSListSectionOfMinimumInteritemSpacing:
            /// 列间距
            returnModel.floatValue = sectionModel.minimumInteritemSpacing;
            break;
            
        case SSListSectionOfHeightForHeader:
            /// Header 高度
            returnModel.floatValue = sectionModel.headerModel.height;
            break;
        case SSListSectionOfHeightForFooter:
            /// Footer 高度
            returnModel.floatValue = sectionModel.footerModel.height;
            break;
        case SSListSectionOfDecorationViewApply:
            /// DecorationView 布局自定义回调
            returnModel.decorationViewApply = sectionModel.decorationViewApply;
            break;
        default:
            returnModel = nil;
            break;
    }
    return returnModel;
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
    SSListSectionModel *sectionModel = [self getSectionModelAtSection:indexPath.section];
    if (sectionModel) {
        
        if (kind == UICollectionElementKindSectionHeader && sectionModel.headerModel) {
            sectionModel.headerModel.indexPath = indexPath;
            if (![self.reusableViewIdentifiers containsObject:sectionModel.headerModel.identifier]) {
                [self.reusableViewIdentifiers addObject:sectionModel.headerModel.identifier];
                [collectionView registerClass:sectionModel.headerModel.class
                   forSupplementaryViewOfKind:kind
                          withReuseIdentifier:sectionModel.headerModel.identifier];
            }
            SSHelpListHeader *header = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:sectionModel.headerModel.identifier forIndexPath:indexPath];
            header.headerModel = sectionModel.headerModel;
            [header refresh];
            return header;
        } else if (kind == UICollectionElementKindSectionFooter && sectionModel.footerModel) {
            sectionModel.footerModel.indexPath = indexPath;
            if (![self.reusableViewIdentifiers containsObject:sectionModel.footerModel.identifier]) {
                [self.reusableViewIdentifiers addObject:sectionModel.footerModel.identifier];
                [collectionView registerClass:sectionModel.footerModel.class
                   forSupplementaryViewOfKind:kind
                          withReuseIdentifier:sectionModel.footerModel.identifier];
            }
            SSHelpListFooter *footer = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:sectionModel.footerModel.identifier forIndexPath:indexPath];
            footer.footerModel = sectionModel.footerModel;
            [footer refresh];
            return footer;
        }
    }
    return nil;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /// 获取model
    SSListSectionModel *sectionModel = [self getSectionModelAtSection:indexPath.section];
    SSListCellModel *model = [self getCellModelAtIndexPath:indexPath];
    model.indexPath = indexPath;
    
    /// 注册class
    if (![self.reusableViewIdentifiers containsObject:model.identifier]) {
        [self.reusableViewIdentifiers addObject:model.identifier];
        [collectionView registerClass:model.class forCellWithReuseIdentifier:model.identifier];
    }
    
    if (sectionModel && sectionModel.layoutStyle==SLSectionLayoutStyleHorizontalInfinitely) {
        NSString *ids = @"_SSListHorizontalFlowCell";
        if (![self.reusableViewIdentifiers containsObject:ids]) {
            [self.reusableViewIdentifiers addObject:ids];
            [collectionView registerClass:SSListHorizontalFlowCell.class forCellWithReuseIdentifier:ids];
        }
        /// 刷新cell
        SSListHorizontalFlowCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:ids forIndexPath:indexPath];
        cell.sectionModel = sectionModel;
        [cell refresh];
        return cell;
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

@end


