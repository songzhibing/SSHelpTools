//
//  SSHelpListLayout.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListLayout.h"
#import "SSHelpDefines.h"

@interface SSHelpListLayout()

@property(nonatomic, strong) NSMutableArray <NSMutableArray <UICollectionViewLayoutAttributes *> *> *itemLayoutAttributes;

@property(nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *> *headerLayoutAttributes;

@property(nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *> *footerLayoutAttributes;

@property(nonatomic, strong) NSMutableArray <SSListDecorationViewLayoutAttributes *> *decorationViewLayoutAttributes;

@property(nonatomic, assign) CGFloat availableContentHeight;

@end


@implementation SSHelpListLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerClass:SSHelpListDecorationView.class forDecorationViewOfKind:_kSSListDecorationViewKind];
    }
    return self;
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    /// 重置缓存数据
    [self.headerLayoutAttributes removeAllObjects];
    [self.itemLayoutAttributes   removeAllObjects];
    [self.footerLayoutAttributes removeAllObjects];
    [self.decorationViewLayoutAttributes removeAllObjects];
    
    self.availableContentHeight = 0;

    UIEdgeInsets contentInset = self.collectionView.contentInset;
    /// 起始Y轴偏移量
    CGFloat contentMaxY = contentInset.top;
    CGFloat contentWidth = CGRectGetWidth(self.collectionView.frame) - contentInset.left - contentInset.right;
    /// 构造Section布局
    for (NSInteger section=0; section<self.collectionView.numberOfSections; section++)
    {
        /// Section布局风格
        NSInteger layoutStyle = [self getLayoutStyleInSection:section];
        /// Section内间距
        UIEdgeInsets sectionInset = [self getSectionInsetInSection:section];
        /// Section宽度
        CGFloat sectionWidth = contentWidth - sectionInset.left - sectionInset.right;

        /// 获取header布局
        CGFloat headerHeight = [self getHeightForHeaderInSection:section];
        CGRect headerFrame = CGRectMake(sectionInset.left, sectionInset.top+contentMaxY, sectionWidth, headerHeight);
        NSIndexPath *headerIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *headerLayout = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:headerIndexPath];
        headerLayout.frame = headerFrame;
        /// 缓存header布局
        [self.headerLayoutAttributes addObject:headerLayout];
        
        /// 更新Y轴偏移量
        contentMaxY += sectionInset.top + headerHeight;
        
        /// 内容内间距
        UIEdgeInsets contentInset = [self getContentInsetInSection:section];
        /// 行间距
        CGFloat minimumLineSpacing = [self getMinimumLineSpacingInSection:section];
        /// 列间距
        CGFloat minimumInteritemSpacing = [self getMinimumInteritemSpacingInSection:section];
        /// 元素个数
        NSInteger itemsCount = [self getNumberOfItemsInSection:section];
        
        /// items布局方式：默认布局
        if (layoutStyle==SLSectionLayoutStyleDefault)
        {
            /// 列数
            NSInteger columnsCount = [self getNumberOfColumnInSection:section];
            /// 内容有效宽度
            CGFloat contentWidth = sectionWidth-contentInset.left-contentInset.right;
            /// item宽度
            CGFloat itemWidth = (contentWidth-(columnsCount-1)*minimumInteritemSpacing) / columnsCount;
            
            /// 先更新总高度
            contentMaxY += contentInset.top;
            
            /// 初始每列Y轴偏移量
            CGFloat offsetY[columnsCount];
            for (NSInteger i=0; i<columnsCount; i++) {
                offsetY[i] = contentMaxY;
            }
            
            NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:itemsCount];
            for (NSInteger index=0; index<itemsCount; index++) {
                /// 找到最小Y偏移列
                NSInteger minColumn = 0;
                for (NSInteger i=1; i<columnsCount; i++) {
                    if (offsetY[minColumn] > offsetY[i]) {
                        minColumn = i;
                    }
                }
                /// item布局
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
                CGFloat itemHeight = [self getHeightForItemAtIndexPath:indexPath];
                CGFloat x = contentInset.left + itemWidth*minColumn + minimumInteritemSpacing*minColumn;
                CGFloat y = offsetY[minColumn] + (index>=columnsCount ? minimumLineSpacing : 0.0);
                CGRect itemFrame = CGRectMake(x, y, itemWidth, itemHeight);
                UICollectionViewLayoutAttributes *layout = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layout.frame = itemFrame;
                [attributes addObject:layout];
                
                /// 更新偏移量
                offsetY[minColumn] = (y + itemHeight);
            }
            /// 缓存items布局
            [self.itemLayoutAttributes addObject:attributes];
            
            /// 找到所有列中最大Y轴偏移量
            CGFloat maxOffset = offsetY[0];
            for (int i=1; i<columnsCount; i++) {
                if (offsetY[i] > maxOffset) {
                    maxOffset = offsetY[i];
                }
            }
            /// 后更新总高度
            contentMaxY = maxOffset+contentInset.bottom;
            
        }
        /// items布局方式：横向有限布局,类似搜索历史记录布局样式
        else if (layoutStyle==SLSectionLayoutStyleHorizontalFinite)
        {
            /// 内容有效宽度
            CGFloat contentWidth = sectionWidth-contentInset.left-contentInset.right;
            CGFloat originX = sectionInset.left+contentInset.left;
            CGFloat originY = contentMaxY+contentInset.top;
            
            NSMutableArray *attributes = [NSMutableArray arrayWithCapacity:itemsCount];
            for (NSInteger index=0; index<itemsCount; index++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
                CGSize itemSize = [self getSizeForItemAtIndexPath:indexPath];
                if (index==0) {
                    // 第一个元素，限制宽度
                    if (originX+itemSize.width>contentWidth) {
                        itemSize.width = contentWidth;
                    }
                } else {
                    if (originX+itemSize.width+minimumInteritemSpacing*index > contentWidth) {
                        // 横向超出，则换行
                        originX = sectionInset.left+contentInset.left;
                        if (originX+itemSize.width>contentWidth) {
                            // 如果单独一行都超，则限制宽度
                            itemSize.width = contentWidth;
                        }
                        originY += itemSize.height+minimumLineSpacing;
                    }
                }
                CGRect itemFrame = CGRectMake(originX, originY, itemSize.width, itemSize.height);
                UICollectionViewLayoutAttributes *layout = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layout.frame = itemFrame;
                [attributes addObject:layout];
                
                /// 下个元素起点设置
                originX += itemSize.width+minimumInteritemSpacing;
                
                /// (以最后一个元素位置)更新总高度
                contentMaxY = originY+itemSize.height+contentInset.bottom;
            }
            /// 缓存item布局
            [self.itemLayoutAttributes addObject:attributes];
        }
        /// items布局方式：横向无限布局,由另外Layou绘制
        else if (layoutStyle==SLSectionLayoutStyleHorizontalInfinitely)
        {
            /// 横向无限布局：
            /// 由另外Layou绘制，这里提供一个占位即可
            CGFloat contentWidth = sectionWidth-contentInset.left-contentInset.right;
            CGFloat originX = sectionInset.left+contentInset.left;
            CGFloat originY = contentMaxY+contentInset.top;
            
            CGFloat maxHeight = 0;
            for (NSInteger index=0; index<itemsCount; index++) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:section];
                CGSize itemSize = [self getSizeForItemAtIndexPath:indexPath];
                if (itemSize.height>maxHeight) {
                    maxHeight = itemSize.height;
                }
            }
            CGRect itemFrame = CGRectMake(originX, originY, contentWidth, maxHeight);
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *layout = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
            layout.frame = itemFrame;
            
            [self.itemLayoutAttributes addObject:@[layout].mutableCopy];
            
            /// 更新总高度
            contentMaxY += contentInset.top+maxHeight+contentInset.bottom;
        }
        
        /// 获取footer布局
        CGFloat footerHeight = [self getHeightForFooterInSection:section];
        CGRect footerFrame = CGRectMake(sectionInset.left, contentMaxY, contentWidth, footerHeight);
        NSIndexPath *footerIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
        UICollectionViewLayoutAttributes *footerLayout= [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:footerIndexPath];
        footerLayout.frame = footerFrame;
        /// 缓存footer布局
        [self.footerLayoutAttributes addObject:footerLayout];
        
        /// 更新Y轴偏移量
        contentMaxY += footerHeight+sectionInset.bottom;
        
        
        /// 最后处理装饰图(Section背景)
        CGFloat originY = CGRectGetMinY(headerLayout.frame) - sectionInset.top;
        SSListDecorationViewLayoutAttributes *decorationViewLayout = nil;
        decorationViewLayout = [SSListDecorationViewLayoutAttributes layoutAttributesForDecorationViewOfKind:_kSSListDecorationViewKind withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        decorationViewLayout.frame = CGRectMake(contentInset.left,originY, contentWidth, CGRectGetMaxY(footerLayout.frame)-originY);
        decorationViewLayout.zIndex = -1;
        decorationViewLayout.applyCallback = [self getDecorationViewApplyInSection:section];
        [self.decorationViewLayoutAttributes addObject:decorationViewLayout];
    }
    
    /// 最终Y轴偏移量
    contentMaxY += contentInset.bottom;

    self.availableContentHeight  = contentMaxY;
}

// Subclasses must override this method and use it to return the width and height of the collection view’s content. These values represent the width and height of all the content, not just the content that is currently visible. The collection view uses this information to configure its own content size to facilitate scrolling.
- (CGSize)collectionViewContentSize
{
    CGFloat width = CGRectGetWidth(self.collectionView.frame);
    width = width - self.collectionView.contentInset.left- self.collectionView.contentInset.right;

    CGFloat height = CGRectGetHeight(self.collectionView.frame);
    height = MAX(height, self.availableContentHeight);
    
    return CGSizeMake(width, height);
}

// return an array layout attributes instances for all the views in the given rect
- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray<UICollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    [self.itemLayoutAttributes enumerateObjectsUsingBlock:^(NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributeOfSection, NSUInteger idx, BOOL *stop) {
        [layoutAttributeOfSection enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
            if (CGRectIntersectsRect(rect, attribute.frame)) {
                [result addObject:attribute];
            }
        }];
    }];
    
    [self.headerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    
    [self.footerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    
    [self.decorationViewLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    
    
    // Section.Header 悬浮
    if (self.sectionHeadersPinToVisibleBounds) {
        [result enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull header, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([header.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                NSInteger section = header.indexPath.section;
                
                CGFloat originY = CGRectGetMinY(header.frame);
                CGFloat offsetY = self.collectionView.contentOffset.y;
                CGFloat dynamicY = MAX(originY,offsetY);
               
                UICollectionViewLayoutAttributes *footer= self.footerLayoutAttributes[section];
                CGFloat maxY = CGRectGetMinY(footer.frame)-CGRectGetHeight(header.frame);

                CGRect frame = header.frame;
                frame.origin.y = MIN(dynamicY,maxY);
                header.frame = frame;
                header.zIndex = 99;
            }
        }];
    }
    return result;
}

/// return YES to cause the collection view to requery the layout for geometry information
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    //BOOL result = [super shouldInvalidateLayoutForBoundsChange:newBounds];
    return YES;
}

#pragma mark -
#pragma mark - Private Method

- (SSListLayoutDelegateReturn *)delegateByOption:(NSInteger)option indexPath:(NSIndexPath *)indexPath
{
    SSListLayoutDelegateReturn *returnModel = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(layout:option:indexPath:)]) {
        returnModel = [self.delegate layout:self option:option indexPath:indexPath];
    }
    return returnModel;
}

- (SSListDecorationViewApply)getDecorationViewApplyInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfDecorationViewApply indexPath:indexPath];
    return model?model.decorationViewApply:nil;
}

- (NSInteger)getLayoutStyleInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfLayoutStyle indexPath:indexPath];
    return  model?model.integeValue:SLSectionLayoutStyleDefault;
}

- (UIEdgeInsets)getSectionInsetInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfSectionInset indexPath:indexPath];
    return  model?model.insetsValue:UIEdgeInsetsZero;
}

- (UIEdgeInsets)getContentInsetInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfContentInset indexPath:indexPath];
    return  model?model.insetsValue:UIEdgeInsetsZero;
}

- (CGFloat)getMinimumLineSpacingInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfMinimumLineSpacing indexPath:indexPath];
    return  model?model.floatValue:0;
}

- (CGFloat)getMinimumInteritemSpacingInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfMinimumInteritemSpacing indexPath:indexPath];
    return  model?model.floatValue:0;
}

- (NSInteger)getNumberOfColumnInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfNumberOfColumn indexPath:indexPath];
    return MAX(model.integeValue, 1);
}

- (NSInteger)getNumberOfItemsInSection:(NSInteger)section
{
    return [self.collectionView numberOfItemsInSection:section];
}

- (CGFloat)getHeightForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfHeightForItem indexPath:indexPath];
    return  model?model.floatValue:44;
}

- (CGSize)getSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfSizeForItem indexPath:indexPath];
    return  model?model.sizeValue:CGSizeZero;
}

#pragma mark - header

- (CGFloat)getHeightForHeaderInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfHeightForHeader indexPath:indexPath];
    return  model?model.floatValue:0;
}

#pragma mark - footer

- (CGFloat)getHeightForFooterInSection:(NSInteger)section
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
    SSListLayoutDelegateReturn *model = [self delegateByOption:SSListSectionOfHeightForFooter indexPath:indexPath];
    return  model?model.floatValue:0;
}

#pragma mark -
#pragma mark - Getter Method

- (NSMutableArray<NSMutableArray<UICollectionViewLayoutAttributes *> *> *)itemLayoutAttributes
{
    if (!_itemLayoutAttributes) {
        _itemLayoutAttributes = NSMutableArray.array;
    }
    return _itemLayoutAttributes;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)headerLayoutAttributes
{
    if (!_headerLayoutAttributes){
        _headerLayoutAttributes = NSMutableArray.array;
    }
    return _headerLayoutAttributes;
}

- (NSMutableArray<UICollectionViewLayoutAttributes *> *)footerLayoutAttributes
{
    if (!_footerLayoutAttributes){
        _footerLayoutAttributes = NSMutableArray.array;
    }
    return _footerLayoutAttributes;
}

- (NSMutableArray<SSListDecorationViewLayoutAttributes *> *)decorationViewLayoutAttributes
{
    if (!_decorationViewLayoutAttributes){
        _decorationViewLayoutAttributes = NSMutableArray.array;
    }
    return _decorationViewLayoutAttributes;
}

@end


///*****************************************************************************
///*****************************************************************************

@implementation SSListLayoutDelegateReturn

@end
