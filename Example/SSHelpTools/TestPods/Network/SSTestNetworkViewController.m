//
//  SSTestNetworkViewController.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSTestNetworkViewController.h"
#import <SSHelpTools/SSHelpNetwork.h>

@interface SSTestNetworkViewController ()

@end

@implementation SSTestNetworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TestNet";
    
    
    NSMutableArray <SSCollectionViewSectionModel *> *sectionModels = [[NSMutableArray alloc] init];
    SSCollectionViewSectionModel *section = [[SSCollectionViewSectionModel alloc] init];
    section.cellModels = [[NSMutableArray alloc] init];
    for (int index=0; index<3; index++) {
        SSCollectionViewCellModel *cell = [[SSCollectionViewCellModel alloc] init];
        cell.onClick = ^(__kindof UICollectionView * _Nullable collectionView, __kindof UICollectionReusableView * _Nullable reusableView, NSIndexPath * _Nullable indexPath, id  _Nullable data) {
            [[SSHelpNetworkCenter defaultCenter] sendRequest:^(SSHelpNetworkRequest * _Nonnull request) {
                request.url = @"https://api.vvhan.com/api/en";
                //     request.url = @"https://updatecdn.meeting.qq.com/cos/65f61cbaa77157dfc47de068775210e3/TencentMeeting_0300000000_3.11.3.453.publish.x86_64.dmg";
            } success:^(id  _Nullable responseObject) {
                SSLog(@"接口：%@",responseObject);
            } failure:^(NSError * _Nullable error) {
                SSLog(@"接口：%@",error);
            }];
        };
        [section.cellModels addObject:cell];
    }
    section.headerModel = [[SSCollectionViewHeaderModel alloc] init];
    section.headerModel.headerHeight = 20;
    section.footerModel = [[SSCollectionViewFooterModel alloc] init];
    section.footerModel.footerHeight = 10;
    [sectionModels addObject:section];
    self.tableView.data = sectionModels;

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
