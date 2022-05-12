//
//  SSHelpTableViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTableViewController.h"
#import "SSHelpTableView.h"

@interface SSHelpTableViewController ()

@end

@implementation SSHelpTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [[SSHelpTableView alloc] initWithFrame:self.safeContentView.bounds];
    [self.safeContentView addSubview:_tableView];
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
