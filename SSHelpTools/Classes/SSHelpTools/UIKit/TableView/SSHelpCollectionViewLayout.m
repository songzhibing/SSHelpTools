//
//  SSHelpTableViewLayout.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/10/29.
//

#import "SSHelpCollectionViewLayout.h"
#import "SSHelpDefines.h"
#import "SSHelpCollectionViewSection.h"

@interface SSHelpCollectionViewLayout()

@property(nonatomic, strong) NSMutableArray <NSMutableArray <UICollectionViewLayoutAttributes *> *> *itemLayoutAttributes;

@property(nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *> *headerLayoutAttributes;

@property(nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *> *footerLayoutAttributes;

@property(nonatomic, strong) NSMutableArray <UICollectionViewLayoutAttributes *> *sectionLayoutAttributes;

/// Per section heights.
@property(nonatomic, strong) NSMutableArray<NSNumber *> *heightOfSections;

/// UICollectionView content height.
@property(nonatomic, assign) CGFloat contentHeight;

@end

@implementation SSHelpCollectionViewLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self registerClass:[SSHelpCollectionViewSection class] forDecorationViewOfKind:_kSSHelpCollectionViewSection];
    }
    return self;
}

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self)
}

- (void)prepareLayout
{
    [super prepareLayout];
    
    NSAssert(self.dataSource != nil, @"GCFlowLayout.dataSource cann't be nil.");
    if (self.collectionView.isDecelerating || self.collectionView.isDragging) {
        return;
    }
    
    _contentHeight = 0.0;
    _itemLayoutAttributes = [NSMutableArray array];
    _headerLayoutAttributes = [NSMutableArray array];
    _footerLayoutAttributes = [NSMutableArray array];
    _sectionLayoutAttributes = [NSMutableArray array];
    _heightOfSections = [NSMutableArray array];

    UICollectionView *collectionView = self.collectionView;
    NSInteger const numberOfSections = collectionView.numberOfSections;
    UIEdgeInsets const contentInset = collectionView.contentInset;
    CGFloat const contentWidth = collectionView.bounds.size.width - contentInset.left - contentInset.right;
    
    for (NSInteger section=0; section < numberOfSections; section++)
    {
        NSInteger const columnOfSection = [self.dataSource collectionView:collectionView
                                                                   layout:self
                                                  numberOfColumnInSection:section];
        NSAssert(columnOfSection > 0, @"[GCFlowLayout collectionView:layout:numberOfColumnInSection:] must be greater than 0.");
        UIEdgeInsets const contentInsetOfSection = [self contentInsetForSection:section];
        CGFloat const minimumLineSpacing = [self minimumLineSpacingForSection:section];
        CGFloat const minimumInteritemSpacing = [self minimumInteritemSpacingForSection:section];
        CGFloat const contentWidthOfSection = contentWidth - contentInsetOfSection.left - contentInsetOfSection.right;
        CGFloat const itemWidth = (contentWidthOfSection-(columnOfSection-1)*minimumInteritemSpacing) / columnOfSection;
        NSInteger const numberOfItems = [collectionView numberOfItemsInSection:section];
        
        // Per section header
        CGFloat headerHeight = 0.0;
        if ([self.dataSource respondsToSelector:@selector(collectionView:layout:
                                                          referenceHeightForHeaderInSection:)])
        {
            headerHeight = [self.dataSource collectionView:collectionView
                                                    layout:self
                         referenceHeightForHeaderInSection:section];
        }
        UICollectionViewLayoutAttributes *headerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        headerLayoutAttribute.frame = CGRectMake(0.0, _contentHeight, contentWidth, headerHeight);
        [_headerLayoutAttributes addObject:headerLayoutAttribute];
        
        CGFloat maxOffsetValue = 0;
        SSSectionLayoutStyle sectionLayoutStyle = [self layoutStyleForSection:section];
        if (SSSectionLayoutStyleHorizontalFinite == sectionLayoutStyle)
        {
            //横向有限布局
            maxOffsetValue = headerHeight+contentInsetOfSection.top;
            NSMutableArray *layoutAttributeOfSection = [NSMutableArray arrayWithCapacity:numberOfItems];
            CGFloat originX = contentInsetOfSection.left+0;
            CGFloat originY = headerHeight+contentInsetOfSection.top+0;
            for (NSInteger item=0; item<numberOfItems; item++)
            {
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                CGSize itemSize = [self.dataSource collectionView:collectionView layout:self sizeForItemAtIndexPath:indexPath];
                if (0==item)
                {
                    if (originX+itemSize.width>contentWidthOfSection)
                    {
                        //限制首个宽度
                        itemSize.width = contentWidthOfSection;
                    }
                }
                
                if ((originX+itemSize.width+minimumInteritemSpacing*item)>contentWidthOfSection)
                {
                    //横向已经超出,换行
                    originX = contentInsetOfSection.left+0;
                    if (originX+itemSize.width>contentWidthOfSection)
                    {
                        //如果单独一行都超，则限制正好一行宽度
                        itemSize.width = contentWidthOfSection;
                    }
                    originY += itemSize.height+minimumLineSpacing;
                }
                UICollectionViewLayoutAttributes *layoutAttbiture = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttbiture.frame = CGRectMake(originX, originY+_contentHeight, itemSize.width, itemSize.height);
                [layoutAttributeOfSection addObject:layoutAttbiture];
                
                //next itemCell orginX
                originX += itemSize.width+minimumInteritemSpacing;
                
                // Update y offset in current column
                maxOffsetValue = originY+itemSize.height;
            }
            [_itemLayoutAttributes addObject:layoutAttributeOfSection];
            maxOffsetValue += contentInsetOfSection.bottom;

        }
        else
        {
            // The current section's offset for per column.
            CGFloat offsetOfColumns[columnOfSection];
            for (NSInteger i=0; i<columnOfSection; i++) {
                offsetOfColumns[i] = headerHeight + contentInsetOfSection.top;
            }
            
            NSMutableArray *layoutAttributeOfSection = [NSMutableArray arrayWithCapacity:numberOfItems];
            for (NSInteger item=0; item<numberOfItems; item++) {
                // Find minimum offset and fill to it.
                NSInteger currentColumn = 0;
                for (NSInteger i=1; i<columnOfSection; i++) {
                    if (offsetOfColumns[currentColumn] > offsetOfColumns[i]) {
                        currentColumn = i;
                    }
                }
                
                NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:section];
                CGFloat itemHeight = [self.dataSource collectionView:collectionView layout:self itemWidth:itemWidth heightForItemAtIndexPath:indexPath];
                CGFloat x = contentInsetOfSection.left + itemWidth*currentColumn + minimumInteritemSpacing*currentColumn;
                CGFloat y = offsetOfColumns[currentColumn] + (item>=columnOfSection ? minimumLineSpacing : 0.0);
                
                UICollectionViewLayoutAttributes *layoutAttbiture = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
                layoutAttbiture.frame = CGRectMake(x, y+_contentHeight, itemWidth, itemHeight);
                [layoutAttributeOfSection addObject:layoutAttbiture];
                
                // Update y offset in current column
                offsetOfColumns[currentColumn] = (y + itemHeight);
            }
            [_itemLayoutAttributes addObject:layoutAttributeOfSection];
            
            // Get current section height from offset record.
            maxOffsetValue = offsetOfColumns[0];
            for (int i=1; i<columnOfSection; i++) {
                if (offsetOfColumns[i] > maxOffsetValue) {
                    maxOffsetValue = offsetOfColumns[i];
                }
            }
            maxOffsetValue += contentInsetOfSection.bottom;
        }
        
        
        // Per section footer
        CGFloat footerHeader = 0.0;
        if ([self.dataSource respondsToSelector:@selector(collectionView:layout:referenceHeightForFooterInSection:)]) {
            footerHeader = [self.dataSource collectionView:collectionView layout:self referenceHeightForFooterInSection:section];
        }
        UICollectionViewLayoutAttributes *footerLayoutAttribute = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        footerLayoutAttribute.frame = CGRectMake(0.0, _contentHeight+maxOffsetValue, contentWidth, footerHeader);
        [_footerLayoutAttributes addObject:footerLayoutAttribute];
        
        //获取属性
        SSCollectionSectionLayoutAttributes *sectionAttribute = [SSCollectionSectionLayoutAttributes layoutAttributesForDecorationViewOfKind:_kSSHelpCollectionViewSection withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
        //设置frame
        sectionAttribute.frame = CGRectMake(0, _contentHeight, contentWidth, maxOffsetValue + footerHeader);
        //纵向坐标调整到底下
        sectionAttribute.zIndex = -1;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(collectionView:setionLayoutAttributes:inSection:)]) {
            [self.dataSource collectionView:self.collectionView setionLayoutAttributes:sectionAttribute inSection:section];
        }
        [_sectionLayoutAttributes addObject:sectionAttribute];
        
        /**
         Update UICollectionView content height.
         Section height contain from the top of the headerView to the bottom of the footerView.
         */
        CGFloat currentSectionHeight = maxOffsetValue + footerHeader;
        [_heightOfSections addObject:@(currentSectionHeight)];
        
        _contentHeight += currentSectionHeight;
    }
}

- (CGSize)collectionViewContentSize
{
    UIEdgeInsets contentInset = self.collectionView.contentInset;
    CGFloat width = CGRectGetWidth(self.collectionView.bounds) - contentInset.left - contentInset.right;
    CGFloat height = MAX(CGRectGetHeight(self.collectionView.bounds), _contentHeight);
    return CGSizeMake(width, height);
}

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray<UICollectionViewLayoutAttributes *> *result = [NSMutableArray array];
    [_itemLayoutAttributes enumerateObjectsUsingBlock:^(NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributeOfSection, NSUInteger idx, BOOL *stop) {
        [layoutAttributeOfSection enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
            if (CGRectIntersectsRect(rect, attribute.frame)) {
                [result addObject:attribute];
            }
        }];
    }];
    [_headerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    [_footerLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    
    [_sectionLayoutAttributes enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes *attribute, NSUInteger idx, BOOL *stop) {
        if (attribute.frame.size.height && CGRectIntersectsRect(rect, attribute.frame)) {
            [result addObject:attribute];
        }
    }];
    
    // Header view hover.
    if (_sectionHeadersPinToVisibleBounds)
    {
        for (UICollectionViewLayoutAttributes *attriture in result) {
            if (![attriture.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) continue;
            NSInteger section = attriture.indexPath.section;
            UIEdgeInsets contentInsetOfSection = [self contentInsetForSection:section];
            NSIndexPath *firstIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            UICollectionViewLayoutAttributes *itemAttribute = [self layoutAttributesForItemAtIndexPath:firstIndexPath];
            CGFloat headerHeight = CGRectGetHeight(attriture.frame);
            CGRect frame = attriture.frame;
            frame.origin.y = MIN(
                                 MAX(self.collectionView.contentOffset.y, CGRectGetMinY(itemAttribute.frame)-headerHeight-contentInsetOfSection.top),
                                 CGRectGetMinY(itemAttribute.frame)+[_heightOfSections[section] floatValue]
                                 );
            attriture.frame = frame;
            attriture.zIndex = (NSIntegerMax/2)+section;
        }
    }
    
    return result;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return _itemLayoutAttributes[indexPath.section][indexPath.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath
{
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        return _headerLayoutAttributes[indexPath.section];
    }
    if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        return _footerLayoutAttributes[indexPath.section];
    }
    return nil;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForDecorationViewOfKind:(NSString*)elementKind atIndexPath:(NSIndexPath *)indexPath;
{
    if(indexPath.item<_sectionLayoutAttributes.count) {
        return _sectionLayoutAttributes[indexPath.section];
    }
    return nil;
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

#pragma mark Private

- (UIEdgeInsets)contentInsetForSection:(NSInteger)section
{
    UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
        edgeInsets = [self.dataSource collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
    }
    return edgeInsets;
}

- (CGFloat)minimumLineSpacingForSection:(NSInteger)section
{
    CGFloat minimumLineSpacing = self.minimumLineSpacing;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
        minimumLineSpacing = [self.dataSource collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
    }
    return minimumLineSpacing;
}

- (CGFloat)minimumInteritemSpacingForSection:(NSInteger)section
{
    CGFloat minimumInteritemSpacing = self.minimumInteritemSpacing;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
        minimumInteritemSpacing = [self.dataSource collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
    }
    return minimumInteritemSpacing;
}

- (SSSectionLayoutStyle)layoutStyleForSection:(NSInteger)section
{
    SSSectionLayoutStyle layoutStyle = self.layoutStyle;
    if ([self.dataSource respondsToSelector:@selector(collectionView:layout:layoutStyle:)]) {
        layoutStyle = [self.dataSource collectionView:self.collectionView layout:self layoutStyle:section];
    }
    return layoutStyle;
}

@end


