//
//  SSHelpWebViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebViewController.h"
#import "SSHelpWebView.h"
#import "SSHelpWebTestBridgeModule.h"

@interface SSHelpWebViewController ()

@property(nonatomic, strong) UIProgressView *loadingPogressView;

@property(nonatomic, strong) SSHelpWebView *webView;

@end

@implementation SSHelpWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(goRefresh)];
    
    self.webView = [SSHelpWebView ss_new];
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

- (void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    CGRect layoutFrame = self.view.safeAreaLayoutGuide.layoutFrame;
    if (_webView && _webView.superview) {
        [_webView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(layoutFrame.origin.y);
            make.left.mas_offset(layoutFrame.origin.x);
            make.size.mas_equalTo(layoutFrame.size);
        }];
    }
}

- (void)goBack
{
    if ([self.webView canGoBack]) {
        [self.webView goBack];
    } else {
        [self tryGoBack];
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
