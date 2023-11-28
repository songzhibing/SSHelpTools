//
//  SSHelpListFooter.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListFooter.h"
#import "UIColor+SSHelp.h"
#import <Masonry/Masonry.h>

@interface SSHelpListFooter()

@property(nonatomic, strong) UILabel *debugLab;

@end


@implementation SSHelpListFooter

- (void)prepareForReuse
{
    [super prepareForReuse];
    #ifdef DEBUG
    if (self.footerModel.isDebug) {
        self.debugLab.text = @"(Footer Prepare)";
    }
    #endif
}

- (void)refresh
{
    #ifdef DEBUG
    if (self.footerModel.isDebug) {
        self.debugLab.text = [NSString stringWithFormat:@"Footer-%td",self.footerModel.indexPath.section];
    }
    #endif
}

- (UILabel *)debugLab
{
    if (!_debugLab) {
        _debugLab = UILabel.new;
        _debugLab.backgroundColor =  [UIColor.ss_randomColor colorWithAlphaComponent:0.7f];
        [self addSubview:_debugLab];
        [_debugLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
    }
    return _debugLab;
}

@end


