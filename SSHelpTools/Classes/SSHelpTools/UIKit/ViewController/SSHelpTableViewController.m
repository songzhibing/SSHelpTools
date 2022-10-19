//
//  SSHelpTableViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSHelpTableViewController.h"

@interface SSHelpTableViewController ()

@end

@implementation SSHelpTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _tableView = [SSHelpCollectionView creatWithFrame:self.contentView.bounds];
    [self.contentView addSubview:_tableView];
    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
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
