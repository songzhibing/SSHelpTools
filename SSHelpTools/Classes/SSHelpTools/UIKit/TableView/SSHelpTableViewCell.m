//
//  SSHelpTableViewCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTableViewCell.h"
#import <Masonry/Masonry.h>
#import "SSHelpDefines.h"
#import "SSHelpTableViewModel.h"

@interface SSHelpTableViewCell()


@end

@implementation SSHelpTableViewCell

- (void)dealloc
{
    SSLifeCycleLog(@"%@ (%td,%td) dealloc ... ",NSStringFromClass([self class]),_indexPath.section,_indexPath.item);
    _modelData = nil;
    _indexPath = nil;
}

/// 被复用，这里应该做显示还原、网络取消...等操作
- (void)prepareForReuse
{
    [super prepareForReuse];
    [self stopMovingShakeAnimation];
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
        self.debugTitleLab.text = [title stringByAppendingFormat:@"( %td-%td)",_indexPath.section,_indexPath.item];
    } else {
        self.debugTitleLab.text = [NSString stringWithFormat:@"( %td-%td)",_indexPath.section,_indexPath.item];
        self.contentView.backgroundColor = _kRandomColor;
    }
#endif
    
    if (self.modelData.backgroundColor) {
        self.contentView.backgroundColor = self.modelData.backgroundColor;
    } else {
#ifdef DEBUG
        self.contentView.backgroundColor = _kRandomColor;
        self.modelData.backgroundColor = self.contentView.backgroundColor ;
#endif
    }
    
    if (_modelData.refreshBlock) {
        _modelData.refreshBlock(self);
    }
    
    if (_modelData.cellMoving) {
        [self startMovingShakeAnimation];
    }
}

/// 开始摆动动画
- (void)startMovingShakeAnimation
{
    if (!_modelData.cellMoving) {
        return;
    }
    
    [self stopMovingShakeAnimation];
    CAKeyframeAnimation * keyAnimaion = [CAKeyframeAnimation animation];
    keyAnimaion.keyPath = @"transform.rotation";
    keyAnimaion.values = @[@(-3 / 180.0 * M_PI),@(3 /180.0 * M_PI),@(-3/ 180.0 * M_PI)];//度数转弧度
    keyAnimaion.removedOnCompletion = NO;
    keyAnimaion.fillMode = kCAFillModeForwards;
    keyAnimaion.duration = 0.3;
    keyAnimaion.repeatCount = MAXFLOAT;
    [self.layer addAnimation:keyAnimaion forKey:@"cellShake"];
}

/// 停止摆动动画
- (void)stopMovingShakeAnimation
{
    if ([self.layer.animationKeys containsObject:@"cellShake"]) {
        [self.layer removeAnimationForKey:@"cellShake"];
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
