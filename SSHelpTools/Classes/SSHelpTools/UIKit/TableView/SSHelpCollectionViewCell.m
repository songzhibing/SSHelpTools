//
//  SSHelpTableViewCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpCollectionViewCell.h"
#import <Masonry/Masonry.h>
#import "SSHelpDefines.h"

@interface SSHelpCollectionViewCell()
@property(nonatomic, strong) UILabel *debugTitleLab;
@end

@implementation SSHelpCollectionViewCell

- (void)dealloc
{
    _cellModel = nil;
    _indexPath = nil;
}

/// 被复用，这里应该做显示还原、网络取消...等操作
- (void)prepareForReuse
{
    [super prepareForReuse];
#ifdef DEBUG
    _debugTitleLab.text = @"";
#endif
}

/// 刷新
- (void)refresh
{
    if (_cellModel.cellBackgrounColor) {
        self.contentView.backgroundColor = _cellModel.cellBackgrounColor;
    }
#ifdef DEBUG
    if (!_debugTitleLab) {
        _debugTitleLab = [[UILabel alloc] init];
        _debugTitleLab.textAlignment = NSTextAlignmentCenter;
        _debugTitleLab.textColor = [UIColor blackColor];
        [self.contentView addSubview:_debugTitleLab];
        [_debugTitleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(2, 2, 2, 2));
        }];
    }
    _debugTitleLab.text = [NSString stringWithFormat:@"[%td,%td]",_cellModel.cellIndexPath.section,_cellModel.cellIndexPath.item];
#endif
}


@end
