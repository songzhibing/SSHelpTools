//
//  SSHelpView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "SSHelpView.h"

@implementation SSHelpView

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self)
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  SSHELPTOOLSCONFIG.backgroundColor;
    }
    return self;
}

@end
