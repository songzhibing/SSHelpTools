//
//  SSHelpListCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListCell.h"
#import "SSHelpListViewHorizontal.h"

/// 自定义Cell视图
@interface SSHelpListCell()

@property(nonatomic, strong) UILabel *debugLab;

@end


@implementation SSHelpListCell

- (void)refresh
{
}

- (UILabel *)debugLab
{
    if (!_debugLab) {
        _debugLab = UILabel.new;
        _debugLab.textAlignment = NSTextAlignmentCenter;
        _debugLab.adjustsFontSizeToFitWidth = YES;
        _debugLab.backgroundColor =  _kRandomColor;
        [self.contentView addSubview:_debugLab];
        [_debugLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _debugLab;
}

@end



/// 自定义Cell视图 [别名..]
@implementation SSListCell

- (void)refresh
{
    #ifdef DEBUG
    NSIndexPath *path = self.cellModel.indexPath;
    self.debugLab.text = [NSString stringWithFormat:@"(%td,%td)",path.section,path.item];
    #endif
}

@end



/// 自定义横向排版占位Cell视图
@interface SSListCellDirectionHorizontal()

@property(nonatomic, strong) SSHelpListViewHorizontal *listView;

@end


@implementation SSListCellDirectionHorizontal

- (void)refresh
{
    if (!self.listView) {
        self.listView = SSHelpListViewHorizontal.ss_new;
        self.listView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0];
        [self.contentView addSubview:self.listView];
        [self.listView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];;
    }
    self.listView.sectionModel = self.sectionModel;
    [self.listView reloadData];
}

@end


