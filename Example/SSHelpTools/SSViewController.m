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
@property(nonatomic, strong) SSHelpNetworkCenter *netCenter;

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
    self.title = @"Demo";
    
    __block SSHelpButton *tapBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    tapBtn.frame = CGRectMake(10, 88, 88, 44);
    tapBtn.normalTitle = @"PushTest";
    tapBtn.normalTitleColor = [UIColor blueColor];
    tapBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:tapBtn];

    @Tweakify(self);
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
        [self_weak_ testRequest];
    }];
    
    _netCenter = [SSHelpNetworkCenter center];

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

- (void)testRequest
{
    __block NSString *requestId = @"";
    requestId = [_netCenter sendRequest:^(SSHelpNetworkRequest * _Nonnull request) {
        request.url = @"https://api.vvhan.com/api/en";

    } success:^(id  _Nullable responseObject) {
        /**
         {
             data =     {
                 day = 13;
                 en = "I dreamed a lot when I was a child, but now I just want to get rich overnight.";
                 month = Oct;
                 pic = "https://staticedu-wps.cache.iciba.com/image/b42419f347ac7f02d5c8a8fa27a0b4b0.jpg";
                 zh = "\U5c0f\U65f6\U5019\U7684\U6211\U68a6\U60f3\U6709\U5f88\U591a\Uff0c\U53ef\U73b0\U5728\U6211\U53ea\U60f3\U4e00\U591c\U66b4\U5bcc\U3002";
             };
             success = 1;
         }
         */

    } failure:^(NSError * _Nullable error) {
        //SSLog(@"下载失败：%@",error);
    }];
}

@end
