//
//  SSHelpTabViewCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTabViewCell.h"
#import <Masonry/Masonry.h>
#import "SSHelpDefines.h"
#import "SSHelpTableViewModel.h"

@interface SSHelpTabViewCell()

@property(nonatomic, strong) UILabel *debugTitleLab;

@end

@implementation SSHelpTabViewCell

- (void)dealloc
{
    _modelData = nil;
    _indexPath = nil;
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

/// 被复用，这里应该做显示还原、网络取消...等操作
- (void)prepareForReuse
{
    [super prepareForReuse];
    self.contentView.backgroundColor = [UIColor clearColor];
    if (_debugTitleLab) {
        _debugTitleLab.text = @"";
    }
}

/// 刷新
- (void)refresh
{
    
#ifdef DEBUG
    NSString *title = [self.modelData.data objectForKey:@"title"];
    if (title.length) {
        self.debugTitleLab.text = title;
    } else {
        self.debugTitleLab.text = [NSString stringWithFormat:@"( %td-%td)",_indexPath.section,_indexPath.item];
        self.contentView.backgroundColor = _kRandomColor;
    }
#endif
    
    if (self.modelData.backgroundColor) {
        self.contentView.backgroundColor = self.modelData.backgroundColor;
    }
    
    if (_modelData.refreshBlock) {
        _modelData.refreshBlock(self);
    }
}

- (UILabel *)debugTitleLab
{
    if (!_debugTitleLab) {
        _debugTitleLab = [[UILabel alloc] init];
        _debugTitleLab.textAlignment = NSTextAlignmentLeft;
        _debugTitleLab.textColor = SSHELPTOOLSCONFIG.labelColor;
        _debugTitleLab.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_debugTitleLab];
        [_debugTitleLab mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(2, 2, 2, 2));
        }];
    }
    return _debugTitleLab;;
}

@end
