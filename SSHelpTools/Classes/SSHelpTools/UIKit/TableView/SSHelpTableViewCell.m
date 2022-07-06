//
//  SSHelpTableViewCell.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTableViewCell.h"
#import <Masonry/Masonry.h>
#import "SSHelpDefines.h"

@interface SSHelpTableViewCell()
@end

@implementation SSHelpTableViewCell

- (void)dealloc
{
    _modelData = nil;
    _indexPath = nil;
}

/// 被复用，这里应该做显示还原、网络取消...等操作
- (void)prepareForReuse
{
    [super prepareForReuse];
    [self stopMovingShakeAnimation];
}

/// 刷新
- (void)refresh
{

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
