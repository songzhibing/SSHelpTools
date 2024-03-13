//
//  SSHelpListReusableViewModel.m
//  Pods
//
//  Created by 宋直兵 on 2024/1/4.
//

#import "SSHelpListReusableViewModel.h"

NSString *const _kSSListCellEventsDidSelect        = @"_kSSListCellEventsDidSelect";
NSString *const _kSSListCellEventsDidDeselect      = @"_kSSListCellEventsDidDeselect";
NSString *const _kSSListCellEventsWillDisplay      = @"_kSSListCellEventsWillDisplay";
NSString *const _kSSListCellEventsDidEndDisplaying = @"_kSSListCellEventsDidEndDisplaying";


@implementation SSHelpListReusableViewModel

/// 初始化
+ (instancetype)ss_new
{
    id model = [[self alloc] init];
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.height = 44;
        self.eventHandler = ^(NSString * _Nonnull events) {};
    }
    return self;
}

- (void)setViewClass:(Class)viewClass
{
    _viewClass = viewClass;
    _identifier = NSStringFromClass(viewClass);
}

@end


