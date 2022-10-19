//
//  SSHelpTableViewController.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpViewController.h"
#import "SSHelpCollectionView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableViewController : SSHelpViewController

@property(nonatomic, strong) SSHelpCollectionView *tableView;

@end

NS_ASSUME_NONNULL_END
