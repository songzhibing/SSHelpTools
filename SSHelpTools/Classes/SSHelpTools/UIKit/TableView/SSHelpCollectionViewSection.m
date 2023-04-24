//
//  SSHelpCollectionViewSection.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/4/8.
//

#import "SSHelpCollectionViewSection.h"

NSString *const _kSSHelpCollectionViewSection = @"SSHelpCollectionViewSection";

@implementation SSCollectionSectionLayoutAttributes

@end

//******************************************************************************

@interface SSHelpCollectionViewSection ()

@property(nonatomic, strong) UIView *backgroundView;

@end

@implementation SSHelpCollectionViewSection

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[SSCollectionSectionLayoutAttributes class]]) {
        SSCollectionSectionLayoutAttributes *attributes = (SSCollectionSectionLayoutAttributes *)layoutAttributes;
        if (attributes.applyCallback) {
            
            if (!self.backgroundView) {
                self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
                [self addSubview:self.backgroundView];
            }
            
            attributes.applyCallback(self.backgroundView);
        }
    }
}

@end
