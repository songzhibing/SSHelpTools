//
//  SSHelpTableViewModel.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import "SSHelpTableViewModel.h"
#import "SSHelpTableViewHeaderView.h"
#import "SSHelpTabViewCell.h"
#import "SSHelpTableViewFooterView.h"

@implementation SSHelpTableViewModel

@end


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


@implementation SSHelpTableViewItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _height = 44;
    }
    return self;
}

@end


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


@implementation SSHelpTabViewCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellHeght = 44;
    }
    return self;
}

- (NSString *)cellIdentifier
{
    if (!_cellIdentifier) {
        _cellIdentifier = @"SSHelpTableView.Cell.Identifer";
    }
    return _cellIdentifier;
}

- (Class)cellClass
{
    if (!_cellClass) {
        _cellClass = [SSHelpTabViewCell class];
    }
    return _cellClass;
}

@end


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

