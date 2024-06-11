//
//  SSTestListViewController.m
//  SSHelpTools_Example
//
//  Created by 宋直兵 on 2024/6/7.
//  Copyright © 2024 宋直兵. All rights reserved.
//

#import "SSTestListViewController.h"

@interface SSTestListViewController ()

@end

@implementation SSTestListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    SSListView *listView = SSListView.ss_new;
    listView.layout.sectionHeadersPinToVisibleBounds = YES;
    
    [self.containerView addSubview:listView];
    [listView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    for (NSInteger section=0; section<5; section++) {
        SSListSectionModel *sectionModel = SSListSectionModel.ss_new;
        if (2==section) {
            sectionModel.layoutStyle = SSListSectionLayoutStyleHorizontalInfinitely;
        } else if (3==section) {
            sectionModel.layoutStyle = SSListSectionLayoutStyleHorizontalFinite;
        }
        for (NSInteger cellIndex=0; cellIndex<6; cellIndex++) {
            SSListCellModel *cellModel = SSListCellModel.ss_new;
            cellModel.size = CGSizeMake(60, 30); // SSListSectionLayoutStyleHorizontalFinite
            [sectionModel.cellModels addObject:cellModel];
        }
        [listView.sections addObject:sectionModel];
    }
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
