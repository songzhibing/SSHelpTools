//
//  UIBarButtonItem+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/14.
//

#import <objc/runtime.h>
#import "UIBarButtonItem+SSHelp.h"
#import "SSHelpBlockTarget.h"
#import "SSHelpDefines.h"

@implementation UIBarButtonItem (SSHelp)

- (void (^)(id _Nonnull))ss_onClick
{
    SSHelpBlockTarget *target = objc_getAssociatedObject(self, _cmd);
    return target.block;
}

- (void)setSs_onClick:(void (^)(id _Nonnull))ss_onClick
{
    SSHelpBlockTarget *target = [[SSHelpBlockTarget  alloc] initWithBlock:ss_onClick];
    objc_setAssociatedObject(self, @selector(ss_onClick), target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self setTarget:target];
    [self setAction:@selector(invoke:)];
}

@end

