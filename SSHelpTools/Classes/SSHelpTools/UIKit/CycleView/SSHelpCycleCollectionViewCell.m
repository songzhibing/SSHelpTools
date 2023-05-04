//
//  SSHelpCycleCollectionViewCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/4/25.
//

#import "SSHelpCycleCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import <SDWebImage/SDWebImage.h>
#import "SSHelpDefines.h"

@implementation SSHelpCycleItem

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

@end


@interface SSHelpCycleCollectionViewCell()
@property(nonatomic, strong) UIImageView *imageView;
@end

@implementation SSHelpCycleCollectionViewCell

- (void)dealloc
{
    //SSLifeCycleLog(@"%@ dealloc ... ",self);
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self.imageView sd_cancelCurrentImageLoad];
}

- (void)refresh:(__kindof SSHelpCycleItem *)item
{
    if (!self.imageView) {
        self.imageView = UIImageView.new;
        self.imageView.frame = self.contentView.bounds;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:self.imageView];
    }
    [self.imageView sd_setImageWithURL:item.imageURL placeholderImage:item.placeholderImage];
}

@end
