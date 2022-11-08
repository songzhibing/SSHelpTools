//
//  SSHelpBlockTarget.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/14.
//

#import "SSHelpBlockTarget.h"

#ifdef DEBUG
    #import "SSHelpDefines.h"
#endif

@implementation SSHelpBlockTarget

- (void)dealloc
{
    _block = nil;
#ifdef DEBUG
    //SSLifeCycleLog(@"%@ dealloc ... ", self);
#endif
}

- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)event
{
    self = [super init];
    if (self) {
        _block = [block copy];
        _event = event;
    }
    return self;
}

- (id)initWithBlock:(void (^)(id sender))block
{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender
{
    if (_block) {
        _block(sender);
    }
}

@end
