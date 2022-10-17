//
//  SSTestViewController.m
//  SSHelpTools_Example
//
//  Created by 宋直兵 on 2021/12/22.
//  Copyright © 2021 宋直兵. All rights reserved.
//

#import "SSTestViewController.h"

@interface  SSTestModel : NSObject

@property(nonatomic, copy) NSString *testAPI;

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary;

@end

@implementation SSTestModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionary
{
    return nil;
}

@end


@interface SSTestViewController ()
@end

@implementation SSTestViewController

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        SSHelpButtonModel *btnModel = [SSHelpButtonModel modelWithDictionary:@{}];
        SSTestModel *model = [SSTestModel modelWithDictionary:nil];
        SSTestModel *yymodel = [SSTestModel modelWithJSON:@""];
        SSLog(@"%@\%@\%@",model.testAPI,yymodel.testAPI,btnModel.icon);
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"TestTable";
    self.tableView.sectionHeaderHeight = 44;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"UITableViewCell"];
    }
    cell.backgroundColor = _kRandomColor;
    cell.textLabel.text = [NSString stringWithFormat:@"(%ld,%ld)",indexPath.section,indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SSLog(@"%@",indexPath.description);
    if (0==indexPath.row) {
        [SSHelpImagePickerController selectPhoto:^(NSArray<UIImage *> * _Nullable images) {
            SSLog(@"%@",images);
        } selectionLimit:4 presentingViewController:self];
    } else if (1==indexPath.row) {
        [SSHelpPhotoManager enableAccessPhotoAlbum:^(BOOL enable) {
            if (enable) {
                [SSHelpImagePickerController selectPhoto:^(UIImage * _Nullable image) {
                    SSLog(@"%@",image);
                } presentingViewController:self];
            }
        }];
    }
}

@end


