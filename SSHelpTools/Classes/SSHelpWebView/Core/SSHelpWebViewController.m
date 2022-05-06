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

@interface SSHelpWebViewController ()<SSWebViewDelegate>

@property(nonatomic, strong) SSHelpWebView *webView;

@end

@implementation SSHelpWebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView = [[SSHelpWebView alloc] initWithFrame:self.view.bounds];
    self.webView.webViewDelegate = self;
    [self.view addSubview:self.webView];
    
//    NSString *cookieValue = @"document.cookie = 'sessionid=971650594598141';";
//    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:cookieValue injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
//    self.webView.customUserScripts = @[cookieScript];
    [self.webView registerJsHandlerImpClass:[SSHelpWebTestJsBridgeModule class]];
    [self.webView registerJsHandlerImpClass:[SSHelpWebLocationModule class]];
    [self.webView registerJsHandlerImpClass:[SSHelpWebPhotoModule class]];
    
    [self.webView restorationIdentifier];
    [self.webView loadRequest:self.indexRequest];
}

//// 可在初始化时进行设置
//- (NSString *)ajaxCookieScripts {
//    NSMutableString *cookieScript = [[NSMutableString alloc] init];
//    // 为JS增加设置、获取、删除Cookie的方法（需要用到删除方法）
//    NSString *JSCookieFuncString =
//    @"function setCookie(name,value,expires)\
//    {\
//    var oDate=new Date();\
//    oDate.setDate(oDate.getDate()+expires);\
//    document.cookie=name+'='+value+';expires='+oDate+';path=/'\
//    }\
//    function getCookie(name)\
//    {\
//    var arr = document.cookie.match(new RegExp('(^| )'+name+'=([^;]*)(;|$)'));\
//    if(arr != null) return unescape(arr[2]); return null;\
//    }\
//    function delCookie(name)\
//    {\
//    var exp = new Date();\
//    exp.setTime(exp.getTime() - 1);\
//    var cval=getCookie(name);\
//    if(cval!=null) document.cookie= name + '='+cval+';expires='+exp.toGMTString();\
//    }";
//    [cookieScript appendString:JSCookieFuncString];
//    // 遍历 HTTPCookieStorage 中所有 Cookie，进行同步
//    // Tips：系统会根据URL的Domain，自动判断携带Cookie，所以我们设置Cookie时不需要判断域名。
//    for (NSHTTPCookie *cookie in [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies]) {
//
//        // Skip cookies that will break our script
//        if ([cookie.value rangeOfString:@"'"].location != NSNotFound) {
//            continue;
//        }
//        // 设置Cookie前，先进行移除操作，防止出现重复设置的情况
//        [cookieScript appendFormat:@"delCookie('%@');", cookie.name];
//        // Create a line that appends this cookie to the web view's document's cookies
//        [cookieScript appendFormat:@"document.cookie = '%@=%@;", cookie.name, cookie.value];
//        if (cookie.domain || cookie.domain.length > 0) {
//            [cookieScript appendFormat:@"domain=%@;", cookie.domain];
//        }
//        if (cookie.path || cookie.path.length > 0) {
//            [cookieScript appendFormat:@"path=%@;", cookie.path];
//        }
//        if (cookie.expiresDate) {
//            [cookieScript appendFormat:@"expires=%@;", cookie.properties[@"Expires"]];
//        }
//        if (cookie.secure) {
//            // 只有 https 请求才能携带该 cookie
//            [cookieScript appendString:@"Secure;"];
//        }
//        if (cookie.HTTPOnly) {
//            // 保持 native 的 cookie 完整性，当 HTTPOnly 时，不能通过 document.cookie 来读取该 cookie。
//            [cookieScript appendString:@"HTTPOnly;"];
//        }
//        [cookieScript appendFormat:@"';"];
//    }
//    return cookieScript;
//}

#pragma mark - WebView Delegate

/// 标题变更
- (void)webviewDidChangeTitle:(NSString * _Nullable)title
{
    self.navigationBar.titleLabel.text = title;
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
    SSWebLog(@"加载完成：%@",webView.URL);
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
