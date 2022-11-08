//
//  UIButton+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import "UIButton+SSHelp.h"
#import <objc/runtime.h>
#import "SSHelpBlockTarget.h"

#ifdef DEBUG
    #import "SSHelpDefines.h"
#endif

static int _ss_targets_key;

@implementation UIButton (SSHelp)

- (void)dealloc
{
    NSMutableArray *targets = objc_getAssociatedObject(self, &_ss_targets_key);
    if (targets) {
        [targets removeAllObjects];
    }
#ifdef DEBUG
    //SSLifeCycleLog(@"%@ dealloc ... ", self);
#endif
}

/// 添加事件回调
- (void)ss_addControlEvents:(UIControlEvents)event block:(void (^)(id sender))block
{
    SSHelpBlockTarget *target = [[SSHelpBlockTarget alloc] initWithBlock:block events:event];
    [self addTarget:target action:@selector(invoke:) forControlEvents:event];
    [[self _targets] addObject:target];
}

/// 移除事件回调
- (void)ss_removeBlockForControlEvents:(UIControlEvents)event
{
    __weak typeof (self) weak_self = self;
    //倒序删除，才能全部删除掉
    [[self _targets] enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(SSHelpBlockTarget * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.event == event) {
            [weak_self removeTarget:obj action:@selector(invoke:) forControlEvents:event];
            [[weak_self _targets] removeObject:obj];
        }
    }];
}

- (NSMutableArray <SSHelpBlockTarget *> *)_targets
{
    NSMutableArray *targets = objc_getAssociatedObject(self, &_ss_targets_key);
    if (!targets) {
        targets = [[NSMutableArray alloc] initWithCapacity:1];
        objc_setAssociatedObject(self, &_ss_targets_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
