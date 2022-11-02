//
//  SSTestPodsViewController.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/5/10.
//
#import "SSTestPodsViewController.h"
#import "SSTestHttpsServerViewController.h"
#import "SSTestNetworkViewController.h"
#import "SSTestProgressHudViewController.h"
#import "SSTestCollectionViewController.h"
#import "SSTestPodsModel.h"
#import "SSTestPodsCell.h"


@interface SSTestPodsViewController ()

@property(nonatomic, strong) SSHelpCollectionView *tableView;

@end


@implementation SSTestPodsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView = [SSHelpCollectionView creatWithFrame:self.contentView.bounds];
    self.tableView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
    [self loadTestData];
}

#pragma mark -
#pragma mark - Private Method

- (void)loadTestData
{
    @Tweakify(self);
    NSMutableArray <SSTestPodsModel *> *_testData = @[].mutableCopy;
    
    //
    SSTestPodsModel *pods = [[SSTestPodsModel alloc] init];
    pods.title = @"pods";
    pods.push = ^{
        SSTestPodsViewController *vc = [[SSTestPodsViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:pods];
    
    //
    SSTestPodsModel *collectionView = [[SSTestPodsModel alloc] init];
    collectionView.title = @"CollectionView";
    collectionView.push = ^{
        SSTestCollectionViewController *vc = [[SSTestCollectionViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:collectionView];
    
    
    //
    SSTestPodsModel *httpServer = [[SSTestPodsModel alloc] init];
    httpServer.title = @"Https Server";
    httpServer.push = ^{
        SSTestHttpsServerViewController *vc = [[SSTestHttpsServerViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:httpServer];
    
    //
    SSTestPodsModel *network = [[SSTestPodsModel alloc] init];
    network.title = @"Network";
    network.push = ^{
        SSTestNetworkViewController *vc = [[SSTestNetworkViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:network];
        
    //
    SSTestPodsModel *webSoku = [[SSTestPodsModel alloc] init];
    webSoku.title = @"Web Soku";
    webSoku.push = ^{
        SSHelpWebViewController *vc = [[SSHelpWebViewController alloc] init];
        vc.indexString = @"http://www.soku.com/m/y/video?q=阿凡达%20片段#loaded";
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:webSoku];
    
    
    //
    SSTestPodsModel *progressHUD = [[SSTestPodsModel alloc] init];
    progressHUD.title = @"ProgressHUD";
    progressHUD.push = ^{
        SSTestProgressHudViewController *vc = [[SSTestProgressHudViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:progressHUD];
    
    
    
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

    self.tableView.data = @[section].mutableCopy;
    [self.tableView reloadData];
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
