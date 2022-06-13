//
//  SSHelpTableViewModel.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import "SSHelpTableViewModel.h"
#import "SSHelpTableViewHeaderView.h"
#import "SSHelpTableViewCell.h"
#import "SSHelpTableViewFooterView.h"
#import "SSHelpTools/SSHelpDefines.h"

//******************************************************************************

@implementation SSHelpTableViewModel

@end

//******************************************************************************

@implementation SSHelpTableViewMoveRule

- (void)dealloc
{
    _endBlock = NULL;
    _beginBlock = NULL;
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _canMove = NO;
        _canMoveTransSectionArea = YES;
    }
    return self;
}

@end

//******************************************************************************

@implementation SSHelpTabViewSectionModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _columnCount = 1;
    }
    return self;
}

@end

//******************************************************************************

@implementation SSHelpTableViewItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        //_height = 44;
    }
    return self;
}

@end

//******************************************************************************

@implementation SSHelpTabViewHeaderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headerIdentifier = @"SSHelpTableView.Header.Identifer";
        _headerClass = [SSHelpTableViewHeaderView class];
    }
    return self;
}

@end

//******************************************************************************

@implementation SSHelpTabViewCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellHeght = 44;
        _cellIdentifier = @"SSHelpTableView.Cell.Identifer";
        _cellClass = [SSHelpTableViewCell class];
    }
    return self;
}

@end

//******************************************************************************

@implementation SSHelpTabViewFooterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _footerIdentifier = @"SSHelpTableView.Footer.Identifer";
        _footerClass = [SSHelpTableViewFooterView class];
    }
    return self;
}

@end

//******************************************************************************


