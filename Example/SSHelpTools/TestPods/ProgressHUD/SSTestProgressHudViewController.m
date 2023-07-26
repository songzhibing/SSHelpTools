//
//  SSTestProgressHudVC.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/10/27.
//

#import "SSTestProgressHudViewController.h"
#import "SSTestPodsModel.h"
#import "SSTestPodsCell.h"

#import <SSHelpTools/SSHelpProgressHUD.h>
#import <ReactiveObjC/ReactiveObjC.h>

@interface SSTestProgressHudViewController ()

@end

@implementation SSTestProgressHudViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self loadTestData];
}

#pragma mark -
#pragma mark - Private Method

- (void)loadTestData
{
    @Tweakify(self);
    NSMutableArray <SSTestPodsModel *> *_testData = @[].mutableCopy;
    
    //
    SSTestPodsModel *test01 = [[SSTestPodsModel alloc] init];
    test01.title = @"show and 3s after dismiss";
    test01.push = ^{
        [SSHelpProgressHUD ss_show];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD ss_dismiss];
        });
    };
    [_testData addObject:test01];
    
    
    SSTestPodsModel *test02 = [[SSTestPodsModel alloc] init];
    test02.title = @"most show and 6 after dismiss";
    test02.push = ^{
        [SSHelpProgressHUD ss_show];
        [SSHelpProgressHUD ss_show];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD ss_show];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD ss_show];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD ss_show];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD ss_dismiss];
            [SSHelpProgressHUD ss_dismiss];
        });
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD ss_dismiss];
        });
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD ss_dismiss];
            [SSHelpProgressHUD ss_dismiss];
        });
    };
    [_testData addObject:test02];
    

    
    SSTestPodsModel *test03 = [[SSTestPodsModel alloc] init];
    test03.title = @"showMessage";
    test03.push = ^{
        [SSHelpProgressHUD showMessage:@"我只是一条信息"];
    };
    [_testData addObject:test03];
    
    //
    SSTestPodsModel *test04 = [[SSTestPodsModel alloc] init];
    test04.title = @"showSuccess";
    test04.push = ^{
        [SSHelpProgressHUD showSuccess:@"成功啦"];
    };
    [_testData addObject:test04];
    
    
    //
    SSTestPodsModel *test05 = [[SSTestPodsModel alloc] init];
    test05.title = @"showError";
    test05.push = ^{
        [SSHelpProgressHUD showError:@"失败"];
    };
    [_testData addObject:test05];
    
    //
    SSTestPodsModel *test06 = [[SSTestPodsModel alloc] init];
    test06.title = @"showWarning";
    test06.push = ^{
        [SSHelpProgressHUD showWarning:@"showWarning"];
    };
    [_testData addObject:test06];
    
    
    SSTestPodsModel *test07 = [[SSTestPodsModel alloc] init];
    test07.title = @"showActivityMessage";
    test07.push = ^{
        [SSHelpProgressHUD showActivityMessage:@"下载中..."];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SSHelpProgressHUD hideHUD];
        });
    };
    [_testData addObject:test07];
    
    SSTestPodsModel *test08 = [[SSTestPodsModel alloc] init];
    test08.title = @"showProgressBarToView";
    test08.push = ^{
        
        __weak SSProgressHUD *hud = [SSHelpProgressHUD showProgressBar];
        hud.mode = MBProgressHUDModeDeterminateHorizontalBar;
        __block CGFloat progressNumber = 0.2;
        [[[RACSignal interval:1 onScheduler:[RACScheduler mainThreadScheduler]] takeUntil:hud.rac_willDeallocSignal] subscribeNext:^(NSDate * _Nullable x) {
            progressNumber += 0.2;
            hud.progress = progressNumber;
        }] ;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            //[SSHelpProgressHUD hideHUD];
        });
    };
    [_testData addObject:test08];
    
    
    SSCollectionViewSectionModel *section = [[SSCollectionViewSectionModel alloc] init];
    section.cellModels = [[NSMutableArray alloc] init];
    section.minimumLineSpacing = 8;
    
    [_testData enumerateObjectsUsingBlock:^(SSTestPodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSCollectionViewCellModel *cellModel = [[SSCollectionViewCellModel alloc] init];
        cellModel.model = obj;
        cellModel.cellClass = [SSTestPodsCell class];
        cellModel.onClick = ^(__kindof SSHelpCollectionView * _Nullable collectionView, __kindof UICollectionReusableView * _Nullable reusableView, NSIndexPath * _Nullable indexPath, id  _Nullable data) {
            if (obj.push) {
                obj.push();
            }
        };
        [section.cellModels addObject:cellModel];
    }];

    self.collectionView.data = @[section].mutableCopy;
    [self.collectionView reloadData];
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
