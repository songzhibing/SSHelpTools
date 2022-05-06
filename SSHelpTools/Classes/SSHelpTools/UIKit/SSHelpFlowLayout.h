//
//  SSHelpFlowLayout.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/10/29.
//  自定义瀑布流布局
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class SSHelpFlowLayout;

@protocol SSHelpFlowLayoutDataSource<NSObject>

@required

/// Return per section's column number(must be greater than 0).
- (NSInteger)collectionView:(UICollectionView *)collectionView
                     layout:(SSHelpFlowLayout*)layout
    numberOfColumnInSection:(NSInteger)section;

/// Return per item's height
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpFlowLayout*)layout itemWidth:(CGFloat)width
 heightForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional

/// Column spacing between columns
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpFlowLayout*)layout minimumLineSpacingForSectionAtIndex:(NSInteger)section;

/// The spacing between rows and rows
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpFlowLayout*)layout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section;
///
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView
                        layout:(SSHelpFlowLayout*)layout insetForSectionAtIndex:(NSInteger)section;

/// Return per section header view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpFlowLayout*)layout referenceHeightForHeaderInSection:(NSInteger)section;

/// Return per section footer view height.
- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(SSHelpFlowLayout*)layout referenceHeightForFooterInSection:(NSInteger)section;

@end


@interface SSHelpFlowLayout : UICollectionViewLayout

@property(nonatomic, weak) id<SSHelpFlowLayoutDataSource> dataSource;

/// default 0.0
@property(nonatomic, assign) CGFloat minimumLineSpacing;

/// default 0.0
@property(nonatomic, assign) CGFloat minimumInteritemSpacing;

/// default NO
@property(nonatomic, assign)  BOOL sectionHeadersPinToVisibleBounds;

@end

NS_ASSUME_NONNULL_END
