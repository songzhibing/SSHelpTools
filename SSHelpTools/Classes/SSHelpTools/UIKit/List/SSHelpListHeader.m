//
//  SSHelpListHeader.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListHeader.h"
#import "UIColor+SSHelp.h"
#import <Masonry/Masonry.h>

@interface SSHelpListHeader()

@property(nonatomic, strong) UILabel *debugLab;

@end


@implementation SSHelpListHeader

- (void)prepareForReuse
{
    [super prepareForReuse];
    #ifdef DEBUG
    if (self.headerModel.isDebug) {
        self.debugLab.text = @"(Header Prepare)";
    }
    #endif
}

- (void)refresh
{
    #ifdef DEBUG
    if (self.headerModel.isDebug) {
        self.debugLab.text = [NSString stringWithFormat:@"Header-%td",self.headerModel.indexPath.section];
    }
    #endif
}

- (UILabel *)debugLab
{
    if (!_debugLab) {
        _debugLab = UILabel.new;
        _debugLab.backgroundColor = [UIColor.ss_randomColor colorWithAlphaComponent:0.7f];
        [self addSubview:_debugLab];
        [_debugLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _debugLab;
}

@end


