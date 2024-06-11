//
//  SSHelpListLayout.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListLayout.h"
#import "SSHelpDefines.h"
#import "SSHelpListLayoutAttributes.h"

@interface SSHelpListLayout()
@property(nonatomic, strong) NSMutableArray <SSListLayoutAttributes *> *headerLayouts;
@property(nonatomic, strong) NSMutableArray <SSListLayoutAttributes *> *footerLayouts;
@property(nonatomic, strong) NSMutableArray <SSListLayoutAttributes *> *backerLayouts;
@property(nonatomic, strong) NSMutableArray <NSArray <SSListLayoutAttributes *> *> *cellLayouts;
@property(nonatomic, assign) CGFloat totalHeight;
@end


@implementation SSHelpListLayout

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    // 使用源生的self.collectionView.contentInset 会与MJRefresh库冲突
    // 要想控制Inset，推荐使用SSListSectionModel的属性控制
    UIEdgeInsets contentInset = UIEdgeInsetsZero; // self.collectionView.contentInset;
    CGFloat originX = contentInset.left;
    CGFloat originY = contentInset.top;
    CGFloat width = CGRectGetWidth(self.collectionView.frame) - contentInset.left - contentInset.right;
    self.totalHeight = originY;
    [self.headerLayouts removeAllObjects];
    [self.footerLayouts removeAllObjects];
    [self.backerLayouts removeAllObjects];
    [self.cellLayouts removeAllObjects];

    for (NSInteger section=0; section<self.collectionView.numberOfSections; section++) {
        SSListSectionModel *sectionModel = [self.delegate layout:self getSectionModelAtSection:section];
        UIEdgeInsets sectionInset = sectionModel.sectionInset;

        // 计算Header
        CGFloat x = originX+sectionInset.left;
        CGFloat y = self.totalHeight + sectionInset.top;
        CGFloat w = width-sectionInset.left-sectionInset.right;
        CGFloat h = sectionModel.headerModel.height;
        
        CGRect headerFrame = CGRectMake(x,y,w,h);
        SSListLayoutAttributes *headerLayout;
        headerLayout = [SSListLayoutAttributes ss_headerWithSection:section];
        headerLayout.frame = headerFrame;
        
        [self.headerLayouts addObject:headerLayout];
        self.totalHeight = headerFrame.origin.y + headerFrame.size.height;

        // 计算Cells
        x = headerFrame.origin.x + sectionModel.contentInset.left;
        y = self.totalHeight + sectionModel.contentInset.top;
        w = headerFrame.size.width - sectionModel.contentInset.left - sectionModel.contentInset.right;
        h = 0;
        NSMutableArray *cellLayouatAttributes = NSMutableArray.array;
        if (SSListSectionLayoutStyleDefault == sectionModel.layoutStyle)
        {
            // 竖向瀑布流排版
            NSInteger columns = sectionModel.columnsCount;
            __block NSMutableArray <NSNumber *> *offsetY = [NSMutableArray arrayWithCapacity:columns];
            for (NSInteger i=0; i<columns; i++) {
                    offsetY[i] = [NSNumber numberWithFloat:y];
            }
            // 单个cell宽度
            CGFloat itemW = (w-(columns-1)*sectionModel.minimumInteritemSpacing) / columns;
            for (NSInteger idx=0; idx<sectionModel.cellModels.count; idx++) {
                SSListCellModel *cellModel = sectionModel.cellModels[idx];
                // 找到最小Y偏移列
                NSInteger minColumn = 0;
                for (NSInteger i=1; i<columns; i++) {
                    if (offsetY[minColumn].floatValue > offsetY[i].floatValue) {
                        minColumn = i;
                    }
                }
                //单个cell尺寸
                CGFloat itemX = x + itemW*minColumn + sectionModel.minimumInteritemSpacing*minColumn;
                CGFloat itemY = offsetY[minColumn].floatValue + (idx>=columns ? sectionModel.minimumLineSpacing : 0.0);
                CGFloat itemH = cellModel.height;
                CGRect itemFrame = CGRectMake(itemX, itemY, itemW, itemH);
                SSListLayoutAttributes *itemLayout;
                itemLayout = [SSListLayoutAttributes ss_cellForItem:idx inSection:section];
                itemLayout.frame = itemFrame;
                // 更新最小Y偏移列值
                offsetY[minColumn] = [NSNumber numberWithFloat:itemY + itemH];
                // 存储
                [cellLayouatAttributes addObject:itemLayout];
            }
            // 存储
            [self.cellLayouts addObject:cellLayouatAttributes];
            // 找到所有列中最大Y轴偏移量
            CGFloat maxOffsetY = offsetY.firstObject.floatValue;
            for (int i=0; i<columns; i++) {
                CGFloat value = offsetY[i].floatValue;
                if (value > maxOffsetY) {
                    maxOffsetY = value;
                }
            }
            // 更新总高度
            self.totalHeight = maxOffsetY + sectionModel.contentInset.bottom;
        }
        else if (SSListSectionLayoutStyleHorizontalFinite == sectionModel.layoutStyle)
        {
            // 横向排版
            CGFloat itemX = x;
            CGFloat itemY = y;
            NSMutableArray *cellLayouatAttributes = NSMutableArray.array;

            for (NSInteger index=0; index<sectionModel.cellModels.count; index++) {
                SSListCellModel *cellModel = sectionModel.cellModels[index];
                CGFloat itemW = cellModel.size.width;
                CGFloat itemH = cellModel.size.height;
                if (index==0) {
                    // 第一个元素，限制宽度
                    itemW = itemX+itemW>w?w:itemW;
                } else {
                    if (itemX+itemW> x+w) {
                        // 横向超出，则换行
                        itemX = x;
                        itemY += itemH+sectionModel.minimumLineSpacing;
                        itemW = itemX+itemW>w?w:itemW;
                    }
                }
                CGRect itemFrame = CGRectMake(itemX, itemY, itemW, itemH);
                SSListLayoutAttributes *layout;
                layout = [SSListLayoutAttributes ss_cellForItem:index inSection:section];
                layout.frame = itemFrame;
                // 存储
                [cellLayouatAttributes addObject:layout];
                // 下个元素起点设置
                itemX += itemW+sectionModel.minimumInteritemSpacing;
                // 更新总高度
                self.totalHeight = itemY+itemH+sectionModel.contentInset.bottom;
            }
            // 存储
            [self.cellLayouts addObject:cellLayouatAttributes];
        }
        else if (SSListSectionLayoutStyleHorizontalInfinitely == sectionModel.layoutStyle)
        {
            // 横向无限排版
            // 由另外Layou绘制，这里提供一个占位即可
            h = sectionModel.cellModels.firstObject?sectionModel.cellModels.firstObject.size.height:0;
            CGRect itemFrame = CGRectMake(x, y, w, h);
            SSListLayoutAttributes *itemLayout;
            itemLayout = [SSListLayoutAttributes ss_cellForItem:0 inSection:section];
            itemLayout.frame = itemFrame;
            // 存储布局
            [self.cellLayouts addObject:@[itemLayout]];
            // 更新总高度
            self.totalHeight = y + h + sectionModel.contentInset.bottom;
        }
        
        // 计算Footer
        x = headerFrame.origin.x;
        y = self.totalHeight;
        w = headerFrame.size.width;
        h = sectionModel.footerModel.height;
        CGRect footerFrame = CGRectMake(x, y, w, h);
        SSListLayoutAttributes *footerLayout;
        footerLayout = [SSListLayoutAttributes ss_footerWithSection:section];
        footerLayout.frame = footerFrame;
        
        [self.footerLayouts addObject:footerLayout];
        self.totalHeight = footerFrame.origin.y + footerFrame.size.height + sectionInset.bottom;

        // 计算Backer
        x = headerFrame.origin.x-sectionInset.left;
        y = headerFrame.origin.y-sectionInset.top;
        w = width;
        h = self.totalHeight - y;
        CGRect backFrame = CGRectMake(x, y, w, h);
        SSListLayoutAttributes *backerLayout;
        backerLayout = [SSListLayoutAttributes ss_backerWithSection:section];
        backerLayout.zIndex = -1;
        backerLayout.frame = backFrame;
        [self.backerLayouts addObject:backerLayout];
    }
    // 最终总高度
    self.totalHeight += contentInset.bottom;
}

// Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
- (CGSize)collectionViewContentSize
{
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    width = width - self.collectionView.contentInset.left- self.collectionView.contentInset.right;

    CGFloat height = CGRectGetHeight(self.collectionView.frame);
    height = MAX(height, self.totalHeight);
    
    return CGSizeMake(width, height);
}

// return an array layout attributes instances for all the views in the given rect
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *result = NSMutableArray.array;
    [self.cellLayouts enumerateObjectsUsingBlock:^(NSArray <SSListLayoutAttributes *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(SSListLayoutAttributes * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectIntersectsRect(rect, item.frame)) {
                [result addObject:item];
            }
        }];
    }];
    [self.footerLayouts enumerateObjectsUsingBlock:^(SSListLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [result addObject:obj];
        }
    }];
    [self.backerLayouts enumerateObjectsUsingBlock:^(SSListLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [result addObject:obj];
        }
    }];
    NSMutableArray *headerResult = NSMutableArray.array;
    [self.headerLayouts enumerateObjectsUsingBlock:^(SSListLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(rect, obj.frame)) {
            [headerResult addObject:obj];
        }
    }];
    
    // Section.Header 悬浮
    if (self.sectionHeadersPinToVisibleBounds) {
        headerResult = self.headerLayouts; // 悬浮需整个数据！
        for (SSListLayoutAttributes *headerAttributes in headerResult) {
            CGFloat originY = CGRectGetMinY(headerAttributes.frame);
            CGFloat offsetY = self.collectionView.contentOffset.y;
            CGFloat dynamicY = MAX(originY,offsetY);

            SSListLayoutAttributes *footer = self.footerLayouts[headerAttributes.indexPath.section];
            CGFloat maxY = CGRectGetMinY(footer.frame)-CGRectGetHeight(headerAttributes.frame);

            CGRect frame = headerAttributes.frame;
            frame.origin.y = MIN(dynamicY,maxY);
            headerAttributes.frame = frame;
            headerAttributes.zIndex = 999;
        }
    }
    
    [result addObjectsFromArray:headerResult];
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellLayouts[indexPath.section][indexPath.item];
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:_kSSListElementKindSectionFooter]) {
        return self.footerLayouts[indexPath.section];
    } else if ([elementKind isEqualToString:_kSSListElementKindSectionBack]) {
        return self.backerLayouts[indexPath.section];
    } else if ([elementKind isEqualToString:_kSSListElementKindSectionHeader]) {
        return self.headerLayouts[indexPath.section];
    }
    return nil;
}

/// return YES to cause the collection view to requery the layout for geometry information
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark -
#pragma mark - Getter Method

- (NSMutableArray *)headerLayouts
{
    if (!_headerLayouts) {
        _headerLayouts = NSMutableArray.array;
    }
    return _headerLayouts;
}

- (NSMutableArray *)footerLayouts
{
    if (!_footerLayouts) {
        _footerLayouts = NSMutableArray.array;
    }
    return _footerLayouts;
}

- (NSMutableArray *)backerLayouts
{
    if (!_backerLayouts) {
        _backerLayouts = NSMutableArray.array;
    }
    return _backerLayouts;
}

- (NSMutableArray *)cellLayouts
{
    if (!_cellLayouts) {
        _cellLayouts = NSMutableArray.array;
    }
    return _cellLayouts;
}

@end

