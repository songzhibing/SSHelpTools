//
//  SSTestCollectionViewController.m
//  SSTestCode
//
//  Created by 宋直兵 on 2022/11/2.
//

#import "SSTestCollectionViewController.h"
#import "SSTestPodsModel.h"
#import "SSTestPodsCell.h"

@interface SSTestCollectionViewController ()

@property(nonatomic, strong) SSHelpCollectionView *tableView;

@end

@implementation SSTestCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView = [SSHelpCollectionView creatWithFrame:self.contentView.bounds];
    //self.tableView.contentInset = UIEdgeInsetsMake(8, 8, 8, 8);
    [self.contentView addSubview:self.tableView];
    [self.tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.mas_equalTo(0);
    }];
    
//    SSCollectionVieMoveRule *dragDrop = [[SSCollectionVieMoveRule alloc] init];
//    dragDrop.canMove = YES;
//    dragDrop.canMoveTransSectionArea = YES;
//    self.tableView.moveRule = dragDrop;
    
    [self loadTestData];
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
        
        if (sc%2==0) {
            section.layoutStyle = 1;
            section.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
        } else {
            section.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);

        }
        
//        section.headerModel = [[SSCollectionViewHeaderModel alloc] init];
//        section.headerModel.headerHeight = 44;
        
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


    self.tableView.data = _testData;
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
