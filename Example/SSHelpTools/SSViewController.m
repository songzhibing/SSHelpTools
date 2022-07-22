//
//  SSViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 12/17/2021.
//  Copyright (c) 2021 宋直兵. All rights reserved.
//

#import "SSViewController.h"
#import "SSTestViewController.h"

@interface SSViewController ()

@end

@implementation SSViewController

- (void)dealloc
{
    SSLogDebug(@"%@ dealloc ... ", self);
}

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = YES;
    self.title = @"12";
//    [UIApplication sharedApplication].statusBarHidden = YES;
//    [UIViewController prefersStatusBarHidden];
    //    SSHelpView *backView = [[SSHelpView alloc] initWithFrame:CGRectZero];
//    backView.backgroundColor = [UIColor darkGrayColor];
//    [self.view addSubview:backView];
//    [backView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(_kStatusBarHeight);
//        make.left.mas_equalTo(2);
//        make.right.mas_equalTo(-2);
//        make.bottom.mas_equalTo(-(_kHomeIndicatorHeight)-2);
//    }];
    
    
    __block SSHelpButton *tapBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    tapBtn.frame = CGRectMake(10, 88, 88, 44);
    tapBtn.normalTitle = @"PushTest";
    tapBtn.normalTitleColor = [UIColor blueColor];
    tapBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:tapBtn];

    @weakify(self);
    [tapBtn setOnClick:^(SSHelpButton *sender) {
        SSTestViewController *testVC = [SSTestViewController new];
        [self_weak_.navigationController pushViewController:testVC animated:YES];
    }];
    
    __block SSHelpButton *webBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    webBtn.frame = CGRectMake(10, 88+44+20, 88, 44);
    webBtn.normalTitle = @"PushWeb";
    webBtn.normalTitleColor = [UIColor blueColor];
    webBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:webBtn];

    [webBtn setOnClick:^(SSHelpButton *sender) {
        SSHelpWebViewController *webVC = [[SSHelpWebViewController alloc] init];

        NSString *path = [[NSBundle mainBundle] pathForResource:@"ExampleApp" ofType:@"html"];
        NSURL *URL = [NSURL fileURLWithPath:path];
        webVC.indexRequest = [NSMutableURLRequest requestWithURL:URL];
        [self_weak_.navigationController pushViewController:webVC animated:YES];
    }];
    
    __block SSHelpButton *dowBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    dowBtn.frame = CGRectMake(10, 88+(44+20)*2, 88, 44);
    dowBtn.normalTitle = @"Download";
    dowBtn.normalTitleColor = [UIColor blueColor];
    dowBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:dowBtn];
    [dowBtn setOnClick:^(SSHelpButton * _Nonnull sender) {
        [[SSHelpNetworkCenter defaultCenter] sendRequest:^(SSHelpNetworkRequest * _Nonnull request) {
            request.url = @"https://camo.githubusercontent.com/a17b4fe76167f7782bc6e339f76543743422027dab002197bbccbfaa3aa10b6a/68747470733a2f2f7261772e6769746875622e636f6d2f41464e6574776f726b696e672f41464e6574776f726b696e672f6173736574732f61666e6574776f726b696e672d6c6f676f2e706e67";
            request.httpMethod = SSNetHTTPMethodGET;
            request.requestType = SSNetRequestDownload;
            request.downloadSavePath = [_kLibPath stringByAppendingPathComponent:@"123"];
        } progress:^(NSProgress * _Nullable progress) {
            CGFloat gress = 1.0 * progress.completedUnitCount / progress.totalUnitCount;
            SSLogDebug(@"下载进度：%.4f",gress);
        } success:^(id  _Nullable responseObject) {
            SSLogDebug(@"下载成功：%@",responseObject);
        } failure:^(NSError * _Nullable error) {
            SSLogDebug(@"下载失败：%@",error);
        }];
    }];
    
    


}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
