//
//  SSHelpListDecorationView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/22.
//

#import "SSHelpListDecorationView.h"
#import <Masonry/Masonry.h>

NSString *const _kSSListDecorationViewKind = @"_kSSListDecorationViewKind";


@implementation SSListDecorationViewLayoutAttributes

@end


@implementation SSHelpListDecorationView

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)applyLayoutAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes
{
    [super applyLayoutAttributes:layoutAttributes];
    if ([layoutAttributes isKindOfClass:[SSListDecorationViewLayoutAttributes class]]) {
        SSListDecorationViewLayoutAttributes *attributes = (SSListDecorationViewLayoutAttributes *)layoutAttributes;
        if (attributes.applyCallback) {
            if (!self.backgroundView) {
                self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
                [self addSubview:self.backgroundView];
                [self.backgroundView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(UIEdgeInsetsZero);
                }];
            }
            attributes.applyCallback(self.backgroundView);
        }
    }
}

@end
