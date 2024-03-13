//
//  SSTestNetworkViewController.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/5/11.
//

#import "SSTestNetworkViewController.h"
#import <SSHelpTools/SSHelpNetwork.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <Foundation/Foundation.h>
#import <stdlib.h>

@interface SSTestNetworkViewController ()
@property(nonatomic, strong) NSURLSessionDataTask *task ;
@end

@implementation SSTestNetworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TestNet";
    
    
    @Tweakify(self);
    
    SSCollectionViewSectionModel *section = [[SSCollectionViewSectionModel alloc] init];
    section.cellModels = [[NSMutableArray alloc] init];
    for (int index=0; index<3; index++) {
        SSCollectionViewCellModel *cell = [[SSCollectionViewCellModel alloc] init];
        cell.onClick = ^(__kindof UICollectionView * _Nullable collectionView, __kindof UICollectionReusableView * _Nullable reusableView, NSIndexPath * _Nullable indexPath, id  _Nullable data) {
            if (indexPath.item==0) {
                [self_weak_ testapp];
                
            }
        };
        [section.cellModels addObject:cell];
    }
    section.headerModel = [[SSCollectionViewHeaderModel alloc] init];
    section.headerModel.headerHeight = 20;
    section.footerModel = [[SSCollectionViewFooterModel alloc] init];
    section.footerModel.footerHeight = 10;
    self.collectionView.data = @[section].mutableCopy;
}

- (void)testapp
{
    AFHTTPSessionManager *session = AFHTTPSessionManager.manager;
    NSURLSessionDataTask *task = [session POST:@"https://api.vvhan.com/api/en" parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        SSLog(@"response=%@",responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        SSLog(@"error=%@",error);
    }];
    [task.rac_willDeallocSignal subscribeNext:^(id  _Nullable x) {
        SSLog(@"task will dealloc signal...");
    } completed:^{
        SSLog(@"task widll dealloc signal completed...")
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
