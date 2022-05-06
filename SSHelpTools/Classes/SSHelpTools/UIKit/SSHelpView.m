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
    SSToolsLog(@"%@ dealloc ... ", self);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [SSHelpToolsConfig sharedConfig].viewDefaultBackgroundColor;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor =  [SSHelpToolsConfig sharedConfig].viewDefaultBackgroundColor;
    }
    return self;
}

@end
