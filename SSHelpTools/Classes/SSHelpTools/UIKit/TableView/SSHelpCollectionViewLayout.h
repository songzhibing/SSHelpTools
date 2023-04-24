//
//  SSHelpTableViewLayout.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/10/29.
//  自定义瀑布流布局
//

#import <UIKit/UIKit.h>
#import "SSHelpCollectionViewSection.h"
@class SSHelpCollectionViewLayout;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SSSectionLayoutStyle) {
    SSSectionLayoutStyleNormal = 0,                 //常规布局
    SSSectionLayoutStyleHorizontalFinite = 1,       //横向有限布局
    //SSSectionLayoutStyleHorizontalInfinitely = 2, //横向无限布局
};

@protocol SSHelpCollectionViewLayoutDataSource<NSObject>

@required

/// Return per section's column number(must be greater than 0).
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(SSHelpCollectionViewLayout*)layout
    numberOfColumnInSection:(NSInteger)section;

/// Return per item's height, 常规布局必须返回
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

/// Return per item's size，横向限制布局必须返回
- (CGSize)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpCollectionViewLayout*)layout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;
@optional

/// Column spacing between columns
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

/// The spacing between rows and rows
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
///
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout insetForSectionAtIndex:(NSInteger)section;

/// Return per section header view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section;

/// Return per section footer view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout referenceHeightForFooterInSection:(NSInteger)section;

/// Section区域布局方式
- (SSSectionLayoutStyle)collectionView:(UICollectionView *)collectionView layout:(SSHelpCollectionViewLayout*)layout layoutStyle:(NSInteger)section;

/// Section区域背景可自定义
- (void)collectionView:(UICollectionView *)collectionView setionLayoutAttributes:(SSCollectionSectionLayoutAttributes *)attributes inSection:(NSInteger)section;

@end


@interface SSHelpCollectionViewLayout : UICollectionViewLayout

@property(nonatomic, weak) id<SSHelpCollectionViewLayoutDataSource> dataSource;

/// default 0.0
@property(nonatomic, assign) CGFloat minimumLineSpacing;

/// default 0.0
@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

/// default 0
@property(nonatomic, assign) SSSectionLayoutStyle layoutStyle;

/// default NO
@property(nonatomic, assign)  BOOL sectionHeadersPinToVisibleBounds;

@end

NS_ASSUME_NONNULL_END
