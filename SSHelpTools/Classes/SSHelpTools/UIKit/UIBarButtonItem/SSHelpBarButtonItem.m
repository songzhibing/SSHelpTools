//
//  SSHelpBarButtonItem.m
//  Pods
//
//  Created by 宋直兵 on 2023/8/10.
//

#import "SSHelpBarButtonItem.h"
#import "UIBarButtonItem+SSHelp.h"

@implementation SSHelpBarButtonItem

- (void)dealloc
{
    
}

+ (instancetype)ss_sapce
{
    SSHelpBarButtonItem *item = [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    return item;
}

+ (instancetype)ss_fixedSapce:(CGFloat)width
{
    SSHelpBarButtonItem *item = [[self alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:NULL];
    item.width = width;
    return item;
}

+ (instancetype)ss_customButton
{
    SSHelpButton *button = [SSHelpButton buttonWithStyle:SSButtonStyleCustom];
    SSHelpBarButtonItem *item = [[self alloc] initWithCustomView:button];
    item.customButton = button;
    return item;
}


+ (instancetype)ss_newBy:(NSString *)title onClick:(void(^)(SSHelpBarButtonItem *item))click
{
    SSHelpBarButtonItem *item = [[self alloc] initWithTitle:title style:UIBarButtonItemStylePlain target:nil action:NULL];
    item.ss_onClick = click;
    return item;
}

@end
