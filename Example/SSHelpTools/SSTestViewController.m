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

- (instancetype)init
{
    self = [super init];
    if (self) {
        SSTestModel *model = [SSTestModel modelWithDictionary:nil];
        SSTestModel *yymodel = [SSTestModel modelWithJSON:@""];
        SSLog(@"%@\%@",model.testAPI,yymodel.testAPI);
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
}

@end


