//
//  UIBarButtonItem+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/14.
//

#import <objc/runtime.h>
#import "UIBarButtonItem+SSHelp.h"
#import "SSHelpBlockTarget.h"

static char block_key;

@implementation UIBarButtonItem (SSHelp)

- (void (^)(id _Nonnull))gc_actionBlock
{
    SSHelpBlockTarget *target = objc_getAssociatedObject(self, &block_key);
    return target.block;
}

- (void)setGc_actionBlock:(void (^)(id _Nonnull))gc_actionBlock
{
    SSHelpBlockTarget *target = [[SSHelpBlockTarget  alloc] initWithBlock:gc_actionBlock];
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}
@end
