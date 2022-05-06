//
//  SSHelpWebView+WKNavigationDelegate.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebView+WKNavigationDelegate.h"

@implementation SSHelpWebView (WKNavigationDelegate)

/// 决定是否允许或取消导航【通常用于处理跨域的链接能否导航，
/// WebKit对跨域进行了安全检查限制，不允许跨域，因此我们要对不能跨域的链接单独处理，
/// 但是，对于Safari是允许跨域的，不用这么处理。
/// @param webView 调用委托方法的web视图
/// @param navigationAction 有关触发导航请求操作的描述性信息
/// @param decisionHandler 回调
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    WKNavigationActionPolicy __policy = WKNavigationActionPolicyAllow;

    NSURL *url = navigationAction.request.URL;
    NSString *scheme = url.scheme.lowercaseString;

    if (![scheme hasPrefix:@"http"] && //http https
        ![scheme hasPrefix:@"about"] &&
        ![scheme hasPrefix:@"file"])
    {
        // 对于跨域，需要手动跳转， 用系统浏览器（Safari）打开
        __policy = WKNavigationActionPolicyCancel;
        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"])
        {
            //看需不需要弹框，再选择 @"是否打开appstore？"
        }
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }
    else
    {
        if ([navigationAction.request.URL.host.lowercaseString isEqualToString:@"itunes.apple.com"])
        {
            // 对于跳转App Store的，用系统浏览器（Safari）打开
            __policy = WKNavigationActionPolicyCancel;
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        }
    }
    
    /**
    解决办法：
    if (!navigationAction.targetFrame.isMainFrame) {
        [webView evaluateJavaScript:@"var a = document.getElementsByTagName('a');for(var i=0;i<a.length;i++){a[i].setAttribute('target','');}" completionHandler:nil];
    }
     */
    
    decisionHandler(__policy);
}

/// 得到响应后决定是否允许跳转
/// @param webView 调用委托方法的web视图
/// @param navigationResponse 有关导航的描述信息响应。
/// @param decisionHandler 回调
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
    if (response && [response isKindOfClass:[NSHTTPURLResponse class]])
    {
        NSDictionary *allHeaderFields = [response allHeaderFields];
        NSURL *URL = [response URL];
        if (allHeaderFields && URL)
        {
            NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:allHeaderFields forURL:URL];
            if (cookies && cookies.count>0) {
                if (@available(iOS 11.0, *)) {
                    //浏览器自动存储cookie
                }else{
                    /*
                    存储cookies
                    __weak typeof(self) __weak_self  = self;
                    dispatch_async(dispatch_get_global_queue(0, 0), ^{
                        @try{
                            //存储cookies
                            for (NSHTTPCookie *cookie in cookies) {
                                [__weak_self insertCookie:cookie];
                            }
                        }@catch (NSException *e) {
                        }@finally{
                        }
                    });
                     */
                }
            }
        }
    }
    
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)])
    {
        [self.webViewDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    }else{
        // 在收到响应后，决定是否跳转和发送请求之前那个允许配套使用
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

/// 当web视图需要响应身份验证时调用 【用于授权验证的API，与AFN、UIWebView的授权验证API是一样的】
/// @param webView 收到认证的web视图
/// @param challenge 身份验证的考验
/// @param completionHandler 回调
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
    {
        NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
        completionHandler(NSURLSessionAuthChallengeUseCredential,card);
    }else{
        completionHandler(NSURLSessionAuthChallengePerformDefaultHandling ,nil);
    }
    
    /**
     NSString *hostName = webView.URL.host;
     NSString *authenticationMethod = [[challenge protectionSpace] authenticationMethod];
     if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodDefault]
         || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]
         || [authenticationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
         
         NSString *title = @"Authentication Challenge";
         NSString *message = [NSString stringWithFormat:@"%@ requires user name and password", hostName];
         UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
         [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
             textField.placeholder = @"User";
             //textField.secureTextEntry = YES;
         }];
         [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
             textField.placeholder = @"Password";
             textField.secureTextEntry = YES;
         }];
         [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
             
             NSString *userName = ((UITextField *)alertController.textFields[0]).text;
             NSString *password = ((UITextField *)alertController.textFields[1]).text;
             
             NSURLCredential *credential = [[NSURLCredential alloc] initWithUser:userName password:password persistence:NSURLCredentialPersistenceNone];
             
             completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
             
         }]];
         [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
             completionHandler(NSURLSessionAuthChallengeUseCredential, nil);
         }]];
         dispatch_async(dispatch_get_main_queue(), ^{
             [self presentViewController:alertController animated:YES completion:^{}];
         });
         
     }
     else if ([authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
         // needs this handling on iOS 9
         NSURLCredential *card = [[NSURLCredential alloc]initWithTrust:challenge.protectionSpace.serverTrust];
         challenge.sender ? completionHandler(NSURLSessionAuthChallengeUseCredential,card) : NULL;
     }
     else {
         completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
     }
     */
}

/// 当主frame导航开始时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [self.webViewDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

/// 当接收到主frame的服务器重定向时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)]){
        [self.webViewDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

/// 当开始为主frame加载数据时发生错误时调用。
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
/// @param error 错误信息
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]){
        [self.webViewDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

/// 当内容开始到达主frame时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didCommitNavigation:)]) {
        [self.webViewDelegate webView:webView didCommitNavigation:navigation];
    }
}

/// 当主frame导航完成时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    /*
    //获取当前 URLString
    __weak typeof(self) __weak_self = self;
    [webView evaluateJavaScript:@"window.location.href" completionHandler:^(id _Nullable urlStr, NSError * _Nullable error) {
        if (error == nil) {
            __weak_self.currentWebJsWindowLocationHref = urlStr;
        }
    }];
    
    //webView 高度自适应
    [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        // 获取页面高度，并重置 webview 的 frame
        GCLogDebug(@"html 的高度：%@", result);
    }];
     */
    
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [self.webViewDelegate webView:webView didFinishNavigation:navigation];
    }
}

/// 在提交的主frame导航期间发生错误时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
/// @param error 错误信息
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [self.webViewDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

/// 当web视图的web内容进程终止时调用
///【当 WKWebView 总体内存占用过大，页面即将白屏的时候，
/// 系统会调用下面的回调函数，在函数里执行[webView reload]解决白屏问题。
/// 如果还有个别白屏现象，需要在viewwillapper中检测title是否为空做策略】
/// @param webView 其基础web内容进程被终止的web视图
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView API_AVAILABLE(macos(10.11), ios(9.0));
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)]) {
        [self.webViewDelegate webViewWebContentProcessDidTerminate:webView];
    }else{
        [webView reload];
    }
}

@end
