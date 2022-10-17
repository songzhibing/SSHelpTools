//
//  SSHelpWebViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebViewController.h"
#import "SSHelpWebView.h"
#import "SSHelpWebTestJsBridgeModule.h"

@interface SSHelpWebViewController ()

@property(nonatomic, strong) UIProgressView *loadingPogressView;

@property(nonatomic, strong) SSHelpWebView *webView;

@end

@implementation SSHelpWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(goRefresh)];
    
    self.webView = [SSHelpWebView defauleWebView];
    [self.view addSubview:self.webView];

    if (SSEqualToNotEmptyString(self.indexString)) {
        NSString *url = [self.indexString stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        self.indexRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    }

    if (self.indexRequest) {
        [self.webView loadRequest:self.indexRequest];
    }

    if (self.fileURL && self.readAccessURL) {
        [self.webView loadFileURL:self.fileURL allowingReadAccessToURL:self.readAccessURL];
    }
}

- (void)adjustSubviewsDisplay
{
    [super adjustSubviewsDisplay];
    // 调整位置
    [self.webView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(self.viewSafeAreaInsets.top, self.viewSafeAreaInsets.left, 0, self.viewSafeAreaInsets.right));
    }];
}

- (void)goBack
{
    if ([self.webView canGoBack]) {
        [self.webView.backForwardList.backList enumerateObjectsUsingBlock:^(WKBackForwardListItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            SSLog(@"第%ld页：%@",idx,obj.URL);
        }];
        [self.webView goBack];
    } else {
        if (self.navigationController && self.navigationController.viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

- (void)goRefresh
{
    [self.webView reload];
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
