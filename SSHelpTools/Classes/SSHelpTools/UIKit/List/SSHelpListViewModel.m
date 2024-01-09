//
//  SSHelpListViewModel.m
//  Pods
//
//  Created by 宋直兵 on 2024/1/9.
//

#import "SSHelpListViewModel.h"
#import "SSHelpListSupplementaryView.h"
#import "SSHelpListCell.h"

/// Header数据模型
@implementation SSListHeaderModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewClass = SSListHeader.class;
    }
    return self;
}

@end

/// Footer数据模型
@implementation SSListFooterModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewClass = SSListFooter.class;
    }
    return self;
}

@end

/// Backer数据模型
@implementation SSListBackerModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.height = 0;
        self.viewClass = SSListBacker.class;
    }
    return self;
}

@end

/// Cell数据模型
@implementation SSListCellModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.viewClass = SSListCell.class;
    }
    return self;
}

@end


/// Section数据模型
@implementation SSListSectionModel

+ (instancetype)ss_new
{
    SSListSectionModel *section = [[self alloc] init];
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

- (SSListHeaderModel *)headerModel
{
    if (!_headerModel) {
        _headerModel = SSListHeaderModel.ss_new;
    }
    return _headerModel;
}

- (SSListFooterModel *)footerModel
{
    if (!_footerModel) {
        _footerModel = SSListFooterModel.ss_new;
    }
    return _footerModel;
}

- (SSListBackerModel *)backerModel
{
    if (!_backerModel) {
        _backerModel = SSListBackerModel.ss_new;
    }
    return _backerModel;
}

@end

/// ViewModel
@implementation SSHelpListViewModel

@end


