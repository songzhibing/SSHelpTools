//
//  SSHelpListViewModel.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import "SSHelpListViewModel.h"
#import "SSHelpListHeader.h"
#import "SSHelpListFooter.h"
#import "SSHelpListCell.h"

NSString *const _kSSListCellEventsDidSelect        = @"_kSSListCellEventsDidSelect";
NSString *const _kSSListCellEventsDidDeselect      = @"_kSSListCellEventsDidDeselect";
NSString *const _kSSListCellEventsWillDisplay      = @"_kSSListCellEventsWillDisplay";
NSString *const _kSSListCellEventsDidEndDisplaying = @"_kSSListCellEventsDidEndDisplaying";

//******************************************************************************

@implementation SSHelpListViewModel

@end

//******************************************************************************

@implementation SSListSectionModel

+ (instancetype)ss_new
{
    SSListSectionModel *section = [[SSListSectionModel alloc] init];
    return section;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.layoutStyle  = SLSectionLayoutStyleDefault;
        self.sectionInset = UIEdgeInsetsZero;
        self.contentInset = UIEdgeInsetsZero;
        self.cellModels   = NSMutableArray.array;
        self.columnsCount = 1;
    }
    return self;
}

@end

//******************************************************************************

@implementation SSListHeaderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.identifier = NSStringFromClass(SSHelpListHeader.class);
        self.class = SSHelpListHeader.class;
    }
    return self;
}

@end

//******************************************************************************

@implementation SSListFooterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.identifier = NSStringFromClass(SSHelpListFooter.class);
        self.class = SSHelpListFooter.class;
    }
    return self;
}

@end

//******************************************************************************

@implementation SSListCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.identifier = NSStringFromClass(SSHelpListCell.class);
        self.class = SSHelpListCell.class;
        self.size = CGSizeZero;
    }
    return self;
}

@end

//******************************************************************************

@implementation SSListReusableViewModel

/// 初始化
+ (instancetype)ss_new
{
    id model = [[self.class alloc] init];
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.height = 44;
        self.callback = ^(NSString *event) {};
        
        self.isDebug = NO;
        #ifdef DEBUG
        self.isDebug = YES;
        #endif
    }
    return self;
}

@end


