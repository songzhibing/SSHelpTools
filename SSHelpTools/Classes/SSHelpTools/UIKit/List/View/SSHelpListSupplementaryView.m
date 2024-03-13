//
//  SSHelpListSupplementaryView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2024/1/9.
//

#import "SSHelpListSupplementaryView.h"

/// 自定义装饰视图
@interface SSHelpListSupplementaryView()

@property(nonatomic, strong) UILabel *debugLab;

@end


@implementation SSHelpListSupplementaryView

- (void)refresh
{
}

- (void)willDisplay
{
}

- (void)didEndDisplaying
{
}

- (UILabel *)debugLab
{
    if (!_debugLab) {
        _debugLab = UILabel.new;
        _debugLab.textAlignment = NSTextAlignmentCenter;
        _debugLab.adjustsFontSizeToFitWidth = YES;
        _debugLab.backgroundColor =  _kRandomColor;
        [self addSubview:_debugLab];
        [_debugLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _debugLab;
}

@end



/// Section.Header视图
@implementation SSListHeader

- (void)refresh
{
    #ifdef DEBUG
    self.debugLab.text = [NSString stringWithFormat:@"Header(%ld)",self.headerModel.indexPath.section];
    #endif
}

@end



/// Section.Footer视图
@implementation SSListFooter

- (void)refresh
{
    #ifdef DEBUG
    self.debugLab.text = [NSString stringWithFormat:@"Footer(%td)",self.footerModel.indexPath.section];
    #endif
}

@end



/// Section.Backer视图
@implementation SSListBacker

- (void)refresh
{
    #ifdef DEBUG
    self.debugLab.text = [NSString stringWithFormat:@"Backer(%ld)",self.backerModel.indexPath.section];
    #endif
}

@end


