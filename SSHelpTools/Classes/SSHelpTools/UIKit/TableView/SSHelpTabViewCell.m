//
//  SSHelpTabViewCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTabViewCell.h"
#import <Masonry/Masonry.h>
#import "SSHelpDefines.h"

@implementation SSHelpTabViewCell

/// 被复用，这里应该做显示还原、网络取消...等操作
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.titleLab.text = @"";
}

/// 刷新
- (void)refresh
{
    self.titleLab.text = [NSString stringWithFormat:@"Title index %td-%td",_currentIndexPath.section,_currentIndexPath.item];
    self.contentView.backgroundColor = [_kRandomColor colorWithAlphaComponent:0.25f];
}

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(2, 2, 2, 2));
        }];
    }
    return _titleLab;;
}

@end
