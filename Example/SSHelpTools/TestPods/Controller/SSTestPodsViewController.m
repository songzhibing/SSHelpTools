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
#import "SSTestDocViewController.h"
#import "SSTestPodsModel.h"
#import "SSTestPodsCell.h"
#import "HomeServiceProtocol.h"
#import "SSTestListViewController.h"

#import <FLEX/FLEX.h>

@interface SSTestPodsViewController ()

@end


@implementation SSTestPodsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.collectionView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self loadTestData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[FLEXManager sharedManager] showExplorer];
    });
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
    SSTestPodsModel *listView = [[SSTestPodsModel alloc] init];
    listView.title = @"ListView";
    listView.push = ^{
        SSTestListViewController *vc = [[SSTestListViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:listView];
    
    
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
    
    
    SSTestPodsModel *webBaidu = [[SSTestPodsModel alloc] init];
    webBaidu.title = @"Web Baidu";
    webBaidu.push = ^{
        SSHelpWebViewController *vc = [[SSHelpWebViewController alloc] init];
        vc.indexString = @"https://www.baidu.com";
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:webBaidu];

    SSTestPodsModel *webLoc = [[SSTestPodsModel alloc] init];
    webLoc.title = @"Local Example Html";
    webLoc.push = ^{
        NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"ExampleApp.html"];
        SSHelpWebViewController *vc = [[SSHelpWebViewController alloc] init];
        vc.fileURL = [NSURL fileURLWithPath:path];
        vc.readAccessURL = [NSURL fileURLWithPath:NSBundle.mainBundle.bundlePath];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:webLoc];
    
    
    //
    SSTestPodsModel *progressHUD = [[SSTestPodsModel alloc] init];
    progressHUD.title = @"ProgressHUD";
    progressHUD.push = ^{
        SSTestProgressHudViewController *vc = [[SSTestProgressHudViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:progressHUD];
    
    SSTestPodsModel *docModel = [[SSTestPodsModel alloc] init];
    docModel.title = @"Document";
    docModel.push = ^{
        SSTestDocViewController *vc = [[SSTestDocViewController alloc] init];
        [self_weak_.navigationController pushViewController:vc animated:YES];
    };
    [_testData addObject:docModel];
    
    // BeeHive
    SSTestPodsModel *bhModel = [[SSTestPodsModel alloc] init];
    bhModel.title = @"BeeHive";
    bhModel.push = ^{
        id<HomeServiceProtocol> homeVc = [[SSBeeHive shareInstance] createService:@protocol(HomeServiceProtocol)];
        [self_weak_.navigationController pushViewController:homeVc animated:YES];
    };
    [_testData addObject:bhModel];
    
    

    
    
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
