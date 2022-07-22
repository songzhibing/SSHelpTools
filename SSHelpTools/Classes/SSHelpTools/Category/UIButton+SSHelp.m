//
//  UIButton+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import "UIButton+SSHelp.h"
#import <objc/runtime.h>

static const int block_target_key;

@interface _UIButtonBlockTarget : NSObject

@property(nonatomic, copy) void (^block)(id sender);

@property(nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events;

- (void)invoke:(id)sender;

@end

@implementation _UIButtonBlockTarget

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events
{
    self = [super init];
    if (self) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender
{
    if (_block) _block(sender);
}

@end

//******************************************************************************

@implementation UIButton (SSHelp)

- (void)dealloc
{
    [[self _allBlockTargets] removeAllObjects];
}

- (void)ss_addTouchUpInsideBlock:(void (^)(id sender))block
{
    [self ss_addControlEvents:UIControlEventTouchUpInside block:block];
}

- (void)ss_removeTouchUpInsideBlock
{
    [self ss_removeAllBlocksForControlEvents:UIControlEventTouchUpInside];
}

/// 添加*事件回调
- (void)ss_addControlEvents:(UIControlEvents)event block:(void (^)(id sender))block
{
    _UIButtonBlockTarget *target = [[_UIButtonBlockTarget alloc] initWithBlock:block events:event];

    [self addTarget:target action:@selector(invoke:) forControlEvents:event];
    [[self _allBlockTargets] addObject:target];
}

/// 移除*事件回调
- (void)ss_removeAllBlocksForControlEvents:(UIControlEvents)event
{
    NSMutableArray *targets = [self _allBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (_UIButtonBlockTarget *target in targets) {
        if (target.events & event) {
            UIControlEvents newEvent = target.events & (~event);
            if (newEvent) {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                target.events = newEvent;
                [self addTarget:target action:@selector(invoke:) forControlEvents:target.events];
            } else {
                [self removeTarget:target action:@selector(invoke:) forControlEvents:target.events];
                [removes addObject:target];
            }
        }
    }
    [targets removeObjectsInArray:removes];
}

- (NSMutableArray *)_allBlockTargets
{
    NSMutableArray *targets = objc_getAssociatedObject(self, &block_target_key);
    if (!targets) {
        targets = [NSMutableArray array];
        objc_setAssociatedObject(self, &block_target_key, targets, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return targets;
}

@end
