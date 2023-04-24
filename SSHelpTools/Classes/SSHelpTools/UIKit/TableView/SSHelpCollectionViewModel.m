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
#import "SSHelpDefines.h"

//******************************************************************************

@implementation SSHelpCollectionViewModel

@end

//******************************************************************************

@implementation SSCollectionVieMoveRule

+ (instancetype)ss_new
{
    SSCollectionVieMoveRule *model = [[SSCollectionVieMoveRule alloc] init];
    return model;
}

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

+ (instancetype)ss_new
{
    SSCollectionViewSectionModel *model = [[SSCollectionViewSectionModel alloc] init];
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _columnCount = 1;
        _sectionInset = UIEdgeInsetsZero;
        _layoutStyle = SSSectionLayoutStyleNormal;
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

+ (instancetype)ss_new
{
    SSCollectionViewHeaderModel *model = [[SSCollectionViewHeaderModel alloc] init];
    return model;
}

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

+ (instancetype)ss_new
{
    SSCollectionViewCellModel *model = [[SSCollectionViewCellModel alloc] init];
    return model;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _cellHeight = 44;
        _cellClass = [SSHelpCollectionViewCell class];
        _cellIdentifier = @"SSHelpTableViewCell";
#ifdef DEBUG
        _cellBackgroundColor = _kRandomColor;
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

+ (instancetype)ss_new
{
    SSCollectionViewFooterModel *model = [[SSCollectionViewFooterModel alloc] init];
    return model;
}

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


