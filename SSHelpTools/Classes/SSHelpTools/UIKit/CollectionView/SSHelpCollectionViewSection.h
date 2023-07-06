//
//  SSHelpCollectionViewSection.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/4/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const _kSSHelpCollectionViewSection;

@interface SSCollectionSectionLayoutAttributes : UICollectionViewLayoutAttributes

@property(nonatomic, strong) void (^applyCallback) (UIView *backgroundView);

@end


@interface SSHelpCollectionViewSection : UICollectionReusableView

@end

NS_ASSUME_NONNULL_END
