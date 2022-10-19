//
//  SSHelpCollectionViewModel.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import "SSHelpCollectionViewModel.h"
#import "SSHelpCollectionViewHeader.h"
#import "SSHelpCollectionViewCell.h"
#import "SSHelpCollectionViewFooter.h"
#import "SSHelpTools/SSHelpDefines.h"

//******************************************************************************

@implementation SSHelpCollectionViewModel

@end

//******************************************************************************

@implementation SSCollectionVieDragDropRule

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

@implementation SSCollectionViewSectionModel

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

@implementation SSCollectionReusableViewModel

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

@implementation SSCollectionViewHeaderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _headerClass = [SSHelpCollectionViewHeader class];
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

@implementation SSCollectionViewCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellHeght = 44;
        _cellClass = [SSHelpCollectionViewCell class];
        _cellIdentifier = @"SSHelpTableViewCell";
#ifdef DEBUG
        _cellBackgrounColor = _kRandomColor;
#endif
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

@implementation SSCollectionViewFooterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _footerClass = [SSHelpCollectionViewFooter class];
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


