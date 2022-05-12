//
//  SSHelpTableView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpView.h"
#import "SSHelpTableViewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableView : SSHelpView

- (instancetype)initWithFrame:(CGRect)frame;

@property(nonatomic, strong) NSMutableArray <SSHelpTabViewSectionModel *> *data;

- (void)reload;

@end

NS_ASSUME_NONNULL_END
