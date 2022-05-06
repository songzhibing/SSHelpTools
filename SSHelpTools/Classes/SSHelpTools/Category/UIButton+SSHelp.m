//
//  UIButton+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import "UIButton+SSHelp.h"
#import <objc/runtime.h>

static const int block_target_key;

@interface _SSHelpUIButtonBlockTarget : NSObject

@property (nonatomic, copy) void (^block)(id sender);
@property (nonatomic, assign) UIControlEvents events;

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events;
- (void)invoke:(id)sender;

@end

@implementation _SSHelpUIButtonBlockTarget

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)events {
    self = [super init];
    if (self) {
        _block = [block copy];
        _events = events;
    }
    return self;
}

- (void)invoke:(id)sender {
    if (_block) _block(sender);
}

@end


@implementation UIButton (SSHelp)

- (void)dealloc
{
    [[self _allBlockTargets] removeAllObjects];
}

- (void)ss_addTouchUpInsideBlock:(void (^)(id sender))block
{
    [self ss_addBlockForControlEvents:UIControlEventTouchUpInside block:block];
}

- (void)ss_removeTouchUpInsideBlock
{
    [self ss_removeAllBlocksForControlEvents:UIControlEventTouchUpInside];
}

- (void)ss_addBlockForControlEvents:(UIControlEvents)controlEvents block:(void (^)(id sender))block
{
    if (!controlEvents) return;
    
    _SSHelpUIButtonBlockTarget *target = nil;
    target = [[_SSHelpUIButtonBlockTarget alloc] initWithBlock:block events:controlEvents];

    [self addTarget:target action:@selector(invoke:) forControlEvents:controlEvents];
    NSMutableArray *targets = [self _allBlockTargets];
    [targets addObject:target];
}

- (void)ss_removeAllBlocksForControlEvents:(UIControlEvents)controlEvents
{
    if (!controlEvents) return;
    
    NSMutableArray *targets = [self _allBlockTargets];
    NSMutableArray *removes = [NSMutableArray array];
    for (_SSHelpUIButtonBlockTarget *target in targets) {
        if (target.events & controlEvents) {
            UIControlEvents newEvent = target.events & (~controlEvents);
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
