//
//  SSHelpTableView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpView.h"
#import "SSHelpTableViewModel.h"
#import "SSHelpTableViewLayout.h"
#import "SSHelpTableViewCell.h"
#import "SSHelpTableViewHeaderView.h"
#import "SSHelpTableViewFooterView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableView : SSHelpView

@property(nonatomic, assign) UIEdgeInsets contentInset;

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewSectionModel *> *data;

@property(nonatomic, strong) SSHelpTableViewMoveRule *moveRule;

- (void)reload;

@end

NS_ASSUME_NONNULL_END
