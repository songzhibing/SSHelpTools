//
//  SSTestCollectionViewController.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/11/2.
//

#import "SSTestCollectionViewController.h"
#import "SSTestPodsModel.h"
#import "SSTestPodsCell.h"
#import <SSHelpTools/SSHelpCycleCollectionView.h>

@interface SSTestCollectionViewController ()

@end

@implementation SSTestCollectionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self loadTestData];
    
//    SSHelpCycleCollectionView *View = [[SSHelpCycleCollectionView alloc] initWithFrame:CGRectMake(20, 100, self.view.ss_width-40, 100)];
//    View.imagePaths = @[@"https://www.bing.com/th?id=OHR.AdelieWPD_ZH-CN8434233391_1920x1080.jpg"];
//    View.backgroundColor = _kRandomColor;
//    [self.view addSubview:View];
}

#pragma mark -
#pragma mark - Private Method

- (void)loadTestData
{
    NSMutableArray <SSCollectionViewSectionModel *> *_testData = @[].mutableCopy;
    
    for (NSInteger sc=0; sc<8; sc++) {
        SSCollectionViewSectionModel *section = [[SSCollectionViewSectionModel alloc] init];
        section.cellModels = [[NSMutableArray alloc] init];
//        section.minimumLineSpacing = 10;
        section.minimumInteritemSpacing =4;
        section.columnCount = 3;
        section.applyLayoutCallback = ^(UIView * _Nonnull backgroundView) {
            backgroundView.backgroundColor = _kRandomColor;
        };
        
        if (sc%2==0) {
            section.layoutStyle = 1;
            section.sectionInset = UIEdgeInsetsMake(0, 10, 10, 10);
        } else {
            section.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

        }
        
        section.headerModel = [[SSCollectionViewHeaderModel alloc] init];
        section.headerModel.headerHeight = 44;
        
        section.footerModel = [[SSCollectionViewFooterModel alloc] init];
        //section.footerModel.footerHeight = 44;
        
        for (NSInteger item=0; item<10; item++) {
            
            SSTestPodsModel *pods = [[SSTestPodsModel alloc] init];
            pods.title = [NSString stringWithFormat:@"[%ld,%ld]",sc,item];
            
            SSCollectionViewCellModel *cellModel = [[SSCollectionViewCellModel alloc] init];
            cellModel.model = pods;
            cellModel.cellClass = [SSTestPodsCell class];
            cellModel.cellSize = CGSizeMake(80*item+10, 40);

            
            [section.cellModels  addObject:cellModel];
        }
        [_testData addObject:section];
    }


    self.collectionView.data = _testData;
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
