//
//  SSTestPodsCell.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/10/28.
//

#import "SSTestPodsCell.h"
#import "SSTestPodsModel.h"

@implementation SSTestPodsCell

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)refresh
{
//    [super refresh];
    self.contentView.backgroundColor = [UIColor.blueColor colorWithAlphaComponent:0.5];
    
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.backgroundColor = [UIColor lightGrayColor];
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(2, 2, 2, 2));
        }];
    }
    
    SSTestPodsModel *model = self.cellModel.model;
    
    _titleLab.text = model.title;
}


@end
