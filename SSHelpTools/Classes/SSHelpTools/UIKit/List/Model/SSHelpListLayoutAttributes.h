//
//  SSHelpListLayoutAttributes.h
//  Pods
//
//  Created by 宋直兵 on 2024/1/2.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const _kSSListElementKindSectionHeader;
UIKIT_EXTERN NSString *const _kSSListElementKindSectionFooter;
UIKIT_EXTERN NSString *const _kSSListElementKindSectionBack;

@interface SSHelpListLayoutAttributes : UICollectionViewLayoutAttributes

+ (instancetype)ss_headerWithSection:(NSInteger)section;

+ (instancetype)ss_footerWithSection:(NSInteger)section;

+ (instancetype)ss_backerWithSection:(NSInteger)section;

+ (instancetype)ss_cellForItem:(NSInteger)idx inSection:(NSInteger)section;

@end



@interface SSListLayoutAttributes : SSHelpListLayoutAttributes

@end

NS_ASSUME_NONNULL_END
