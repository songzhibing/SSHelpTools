//
//  SSTestViewController.m
//  SSHelpTools_Example
//
//  Created by 宋直兵 on 2021/12/22.
//  Copyright © 2021 宋直兵. All rights reserved.
//

#import "SSTestViewController.h"
#import <SSHelpTools/SSHelpNetwork.h>
#import <SSHelpTools/SSHelpTableViewController.h>
#import <SSHelpTools/SSHelpDropdownMenu.h>

@interface SSTestViewController ()<SSHelpDropdownMenuDelegate>
//@property(nonatomic, strong) SSHelpLocationManager *locationManager;
@property(nonatomic, strong) SSHelpButton *tapBtn;
@property(nonatomic, strong) dispatch_semaphore_t t;
@property(nonatomic, strong) SSHelpDropdownMenu *selectMenu;
@end

@implementation SSTestViewController

- (void)dealloc
{
    SSLog(@"%@ dealloc ... ", self);
//    SSLog(@"Self reation count：%td",_kRetainCount(self));
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
        
    self.tapBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    self.tapBtn.frame = CGRectMake(10, 88, 88, 44);
    self.tapBtn.normalTitle = @"tapTest";
    self.tapBtn.normalTitleColor = [UIColor blueColor];
    self.tapBtn.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [self.view addSubview:self.tapBtn];

    @weakify(self);
    [self.tapBtn setOnClick:^(SSHelpButton *sender) {
        @strongify(self);
        [self testNetwork];
    }];
    
    CGRect frame = CGRectMake(10, 88*4, self.view.ss_width*0.8, 44);
    NSMutableArray *data= [[NSMutableArray alloc] init];
    for (NSInteger index=0; index<6; index++) {
        SSHelpDropdownMenuItem *item = [SSHelpDropdownMenuItem new];
        item.title = [NSString stringWithFormat:@"tt%td",index];
        [data addObject:item];
    }
    SSHelpDropdownMenu *selectMenu = [[SSHelpDropdownMenu alloc] initWithFrame:frame];
//    selectMenu.data = data;
//    selectMenu.title = @"请选择";
//    selectMenu.titleColor = [UIColor redColor];//UIColorFromRGB(0x666666);
//    selectMenu.titleFont = [UIFont systemFontOfSize:13];
//    selectMenu.rotateIcon = [UIImage imageNamed:@"TableViewArrow"];
//    
//    selectMenu.optionLineColor = [UIColor redColor];//UIColorFromRGB(0x666666);
//    selectMenu.optionBgColor = [UIColor whiteColor];
//    selectMenu.optionTextAlignment = NSTextAlignmentLeft;
    
    selectMenu.layer.borderWidth = 0.5f;
    selectMenu.layer.borderColor = [UIColor blackColor].CGColor;
    selectMenu.layer.cornerRadius = 6;
    
    selectMenu.delegate = self;
    self.selectMenu = selectMenu;
//    selectMenu.dataSource = self;
    [self.view addSubview:selectMenu];
    
//    @weakify(self);
//    [selectMenu setDidSelect:^(SSHelpDropdownMenu * _Nonnull menu, NSInteger index, SSHelpDropdownMenuItem * _Nonnull item) {
//        @strongify(self);
//        self.tapBtn.normalTitle = item.title;
//    }];
    
    
//    
//    SSHelpCheckBox *checkbok = [[SSHelpCheckBox alloc] initWithFrame:CGRectMake(100, 100, 88, 44)];
//    checkbok.dataSouce = [[NSMutableArray alloc] initWithCapacity:6];
//    [checkbok.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"123"]];
//    [checkbok.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"abc"]];
//    [checkbok.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"你好呀"]];
//    [checkbok.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"1a2c3你"]];
//
////    checkbok.title = @"123";
////    checkbok.optionBgColor = self.
//    [self.view addSubview:checkbok];
//    
//    
//    
//    SSHelpCheckBox *checkbokLeft = [[SSHelpCheckBox alloc] initWithFrame:CGRectMake(5, 120, 88, 44)];
//    checkbokLeft.dataSouce = [[NSMutableArray alloc] initWithCapacity:6];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"123"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"abc"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"你好呀"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"1a2c3你"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"123"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"abc"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"你好呀"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"1a2c3你"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"123"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"abc"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"你好呀"]];
//    [checkbokLeft.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"1a2c3你"]];
//    [self.view addSubview:checkbokLeft];
//    
//    SSHelpCheckBox *checkbok2 = [[SSHelpCheckBox alloc] initWithFrame:CGRectMake(100, self.view.ss_height-44*3, 88, 44)];
//    checkbok2.dataSouce = [[NSMutableArray alloc] initWithCapacity:6];
//    [checkbok2.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"123"]];
//    [checkbok2.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"abc"]];
//    [checkbok2.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"你好呀"]];
//    [checkbok2.dataSouce addObject:[SSHelpCheckBoxItem itemWithTitle:@"1a2c3你"]];
//
////    checkbok.title = @"123";
////    checkbok.optionBgColor = self.
//    [self.view addSubview:checkbok2];
}

- (void)testSSHelpViewController
{
//    SSHelpViewController *vc = [[SSHelpViewController alloc] init];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)testNetwork
{

//    [[SSHelpNetworkCenter defaultCenter] setupConfig:^(SSHelpNetworkConfig * _Nonnull config) {
//        config.generalServer = @"http://wwww.baidu.con";
//    }];
//    
//    [[SSHelpNetworkCenter defaultCenter] setResponseProcessBlock:^id _Nullable(SSHelpNetworkRequest * _Nullable request, id  _Nullable responseObject, NSError * _Nullable __autoreleasing * _Nullable error) {
//        return responseObject;
//    }];
//    
//    [[SSHelpNetworkCenter defaultCenter] setErrorProcessBlock:^(SSHelpNetworkRequest * _Nullable request, NSError *__autoreleasing  _Nullable * _Nullable error) {
//        //
//    }];
    
    [[SSHelpNetworkCenter defaultCenter] sendRequest:^(SSHelpNetworkRequest * _Nonnull request) {
        request.url = @"http://81.68.126.34/sentences";

    } success:^(id  _Nullable responseObject) {
        SSLogDebug(@"请求：%@",responseObject);

    } failure:^(NSError * _Nullable error) {
        SSLogDebug(@"请求：%@",error);
    }];
    
//    return;
    
    [[SSHelpNetworkCenter defaultCenter] sendBatchRequest:^(SSHelpNetworkBatchRequest * _Nonnull batchRequest) {
        SSHelpNetworkRequest *request1 = [SSHelpNetworkRequest request];
        request1.url = @"http://poetry.apiopen.top/sentences";
        request1.url = @"http://81.68.126.34/sentences";
        request1.failureBlock = ^(NSError * _Nullable error) {
            SSLogDebug(@"请求失败：%@",error);
        };
          // set other properties for request1

        SSHelpNetworkRequest *request2 = [SSHelpNetworkRequest request];
        request2.url = @"https://www.bing.com/HPImageArchive.aspx?format=js&idx=1&n=1&mkt=en-US";
          // set other properties for request2

//        SSHelpNetworkRequest *request3 = [SSHelpNetworkRequest request];
//        request3.url = @"https://www.bing.com/HPImageArchive.aspx?format=js";
          // set other properties for request2

        [batchRequest addRequest:request1];
//        [batchRequest addRequest:request3];
        [batchRequest addRequest:request2];
    } finished:^(NSArray * _Nullable responseObjects) {
        SSLogDebug(@"请求结果：%@",responseObjects);
    }];
//
//    [[SSHelpNetworkCenter defaultCenter] sendChainRequest:^(SSHelpNetworkChainRequest * _Nonnull chainRequest) {
//        [[[chainRequest setupFirst:^(SSHelpNetworkRequest * _Nonnull request) {
//                    request.url = @"http://poetry.apiopen.top/sentences";
//                    request.failureBlock = ^(NSError * _Nullable error) {
//                        SSLogDebug(@"请求失败：%@",error);
//                    };
//                }] toNext:^(SSHelpNetworkRequest * _Nonnull request, id  _Nullable responseObject, BOOL * _Nullable sendNext) {
//                    SSLogDebug(@"上一个请求：%@",responseObject);
//
//                    request.url = @"https://www.bing.com/HPImageArchive.aspx?format=js&idx=1&n=1&mkt=en-US";
//                }] toNext:^(SSHelpNetworkRequest * _Nonnull request, id  _Nullable responseObject, BOOL * _Nullable sendNext) {
//                    request.url = @"http://poetry.apiopen.top/sentences";
//                }] ;
//        //
//    } success:^(NSArray * _Nullable responseObjects) {
//        SSLogDebug(@"请求success结果：%@",responseObjects);
//    } failure:^(NSArray * _Nullable errors) {
//        SSLogDebug(@"请求failure结果：%@",errors);
//    } finished:^(NSArray * _Nullable responseObjects, NSArray * _Nullable errors) {
//        SSLogDebug(@"请求结果：%@ +++%@",responseObjects,errors);
//    }];

    /**
     批量请求

     XMNetworking 支持同时发一组批量请求，这组请求在业务逻辑上相关，但请求本身是互相独立的，success block 会在所有请求都成功结束时才执行，而一旦有一个请求失败，则会执行 failure block。注：回调 Block 中的 responseObjects 和 errors 中元素的顺序与每个 XMRequest 对象在 batchRequest.requestArray 中的顺序一致。

     [XMCenter sendBatchRequest:^(XMBatchRequest *batchRequest) {
         XMRequest *request1 = [XMRequest request];
         request1.url = @"server url 1";
         // set other properties for request1
             
         XMRequest *request2 = [XMRequest request];
         request2.url = @"server url 2";
         // set other properties for request2
             
         [batchRequest.requestArray addObject:request1];
         [batchRequest.requestArray addObject:request2];
     } onSuccess:^(NSArray *responseObjects) {
         NSLog(@"onSuccess: %@", responseObjects);
     } onFailure:^(NSArray *errors) {
         NSLog(@"onFailure: %@", errors);
     } onFinished:^(NSArray *responseObjects, NSArray *errors) {
         NSLog(@"onFinished");
     }];

     [XMCenter sendBatchRequest:...] 方法会返回刚发起的新的 XMBatchRequest 对象对应的唯一标识符 identifier，你通过 identifier 调用 XMCenter 的 cancelRequest: 方法取消这组批量请求。
     链式请求

     XMNetworking 同样支持发一组链式请求，这组请求之间互相依赖，下一请求是否发送以及请求的参数取决于上一个请求的结果，success block 会在所有的链式请求都成功结束时才执行，而中间一旦有一个请求失败，则会执行 failure block。注：回调 Block 中的 responseObjects 和 errors 中元素的顺序与每个链式请求 XMRequest 对象的先后顺序一致。

     [XMCenter sendChainRequest:^(XMChainRequest *chainRequest) {
         [[[[chainRequest onFirst:^(XMRequest *request) {
             request.url = @"server url 1";
             // set other properties for request
         }] onNext:^(XMRequest *request, id responseObject, BOOL *sendNext) {
             NSDictionary *params = responseObject;
             if (params.count > 0) {
                 request.url = @"server url 2";
                 request.parameters = params;
             } else {
                 *sendNext = NO;
             }
         }] onNext:^(XMRequest *request, id responseObject, BOOL *sendNext) {
             request.url = @"server url 3";
             request.parameters = @{@"param1": @"value1", @"param2": @"value2"};
         }] onNext: ...];
     } onSuccess:^(NSArray *responseObjects) {
         NSLog(@"onSuccess: %@", responseObjects);
     } onFailure:^(NSArray *errors) {
         NSLog(@"onFailure: %@", errors);
     } onFinished:^(NSArray *responseObjects, NSArray *errors) {
         NSLog(@"onFinished");
     }];

     [XMCenter sendChainRequest:...] 方法会返回刚发起的新的 XMChainRequest 对象对应的唯一标识符 identifier，你通过 identifier 调用 XMCenter 的 cancelRequest: 方法取消这组链式请求。
     */
//    [[SSHelpNetworkCenter defaultCenter] sendChainRequest:^(SSHelpNetworkChainRequest *chainRequest) {
//        [[[[chainRequest onFirst:^(SSHelpNetworkRequest *request) {
//            request.url = @"server url 1";
//            // set other properties for request
//        }] onNext:^(XMRequest *request, id responseObject, BOOL *sendNext) {
//            NSDictionary *params = responseObject;
//            if (params.count > 0) {
//                request.url = @"server url 2";
//                request.parameters = params;
//            } else {
//                *sendNext = NO;
//            }
//        }] onNext:^(XMRequest *request, id responseObject, BOOL *sendNext) {
//            request.url = @"server url 3";
//            request.parameters = @{@"param1": @"value1", @"param2": @"value2"};
//        }] onNext: ...];
//    } onSuccess:^(NSArray *responseObjects) {
//        NSLog(@"onSuccess: %@", responseObjects);
//    } onFailure:^(NSArray *errors) {
//        NSLog(@"onFailure: %@", errors);
//    } onFinished:^(NSArray *responseObjects, NSArray *errors) {
//        NSLog(@"onFinished");
//    }];
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
