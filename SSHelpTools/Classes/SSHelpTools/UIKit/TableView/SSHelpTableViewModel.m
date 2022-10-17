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
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _canMove = NO;
        _canMoveTransSectionArea = NO;
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
        _headerClass = [SSHelpTableViewHeaderView class];
        _headerIdentifier = @"SSHelpTableViewHeaderView";
    }
    return self;
}

- (void)setHeaderClass:(Class)headerClass
{
    _headerClass = headerClass;
    _headerIdentifier = NSStringFromClass(headerClass);
}

@end

//******************************************************************************

@implementation SSHelpTabViewCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellHeght = 44;
        _cellClass = [SSHelpTableViewCell class];
        _cellIdentifier = @"SSHelpTableViewCell";
    }
    return self;
}

- (void)setCellClass:(Class)cellClass
{
    _cellClass = cellClass;
    _cellIdentifier = NSStringFromClass(cellClass);
}

@end

//******************************************************************************

@implementation SSHelpTabViewFooterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _footerClass = [SSHelpTableViewFooterView class];
        _footerIdentifier = @"SSHelpTableViewFooterView";
    }
    return self;
}

- (void)setFooterClass:(Class)footerClass
{
    _footerClass = footerClass;
    _footerIdentifier = NSStringFromClass(footerClass);
}

@end

//******************************************************************************


