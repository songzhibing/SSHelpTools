//
//  SSHelpWebViewController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebViewController.h"
#import "SSHelpWebView.h"
#import "SSHelpWebLocationModule.h"
#import "SSHelpWebPhotoModule.h"
#import "SSHelpWebTestJsBridgeModule.h"

@interface SSHelpWebViewController ()<SSHelpWebViewDelegate>

@property(nonatomic, strong) SSHelpWebView *webView;

@end

@implementation SSHelpWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[SSHelpWebView alloc] initWithFrame:self.view.bounds];
    self.webView.webViewDelegate = self;
    [self.view addSubview:self.webView];

    [self.webView registerJsHandlerImpClass:[SSHelpWebTestJsBridgeModule class]];
    [self.webView registerJsHandlerImpClass:[SSHelpWebLocationModule class]];
    [self.webView registerJsHandlerImpClass:[SSHelpWebPhotoModule class]];

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

#pragma mark - WebView Delegate

/// 标题变更
- (void)webviewDidChangeTitle:(NSString * _Nullable)title
{
    self.title = title;
}

/// 当接收到主frame的服务器重定向时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    SSWebLog(@"导航重定向时：%@",webView.URL);

}
/// 当主frame导航开始时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    SSWebLog(@"导航开始：%@",webView.URL);

}
/// 当主frame导航完成时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (@available(iOS 11.0, *)) {
        [webView.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull item) {
            //SSWebLog(@"cookie:%@",item);
        }];
    }
    SSWebLog(@"加载完成：%@",webView.URL);
}

/// 在提交的主frame导航期间发生错误时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
/// @param error 错误信息
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    SSWebLog(@"加载失败：%@",error.localizedDescription);
}

/// 当开始为主frame加载数据时发生错误时调用。
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
/// @param error 错误信息
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    SSWebLog(@"加载失败：%@",error.localizedDescription);
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
