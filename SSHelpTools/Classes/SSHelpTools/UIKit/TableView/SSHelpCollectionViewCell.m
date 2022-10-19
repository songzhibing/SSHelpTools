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
    _dataModel = nil;
    _indexPath = nil;
}

/// 被复用，这里应该做显示还原、网络取消...等操作
- (void)prepareForReuse
{
    [super prepareForReuse];
    [self stopMovingShakeAnimation];
    _debugTitleLab.text = @"";
}

/// 刷新
- (void)refresh
{
    if (_dataModel.cellBackgrounColor) {
        self.contentView.backgroundColor = _dataModel.cellBackgrounColor;
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
    _debugTitleLab.text = [NSString stringWithFormat:@"[%td,%td]",_dataModel.cellIndexPath.section,_dataModel.cellIndexPath.item];
#endif
}

/// 开始摆动动画
- (void)startMovingShakeAnimation
{
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

@end
