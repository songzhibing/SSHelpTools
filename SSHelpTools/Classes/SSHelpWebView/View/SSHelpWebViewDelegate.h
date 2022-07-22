//
//  SSWebViewDelegate.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/31.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpWebViewDelegate <NSObject>

@optional

/// 决定是否允许或取消导航
/// @param webView 调用委托方法的web视图
/// @param navigationAction 有关触发导航请求操作的描述性信息
/// @param decisionHandler 回调
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler;

/// 得到响应后决定是否允许跳转
/// @param webView 调用委托方法的web视图
/// @param navigationResponse 有关导航响应的描述信息
/// @param decisionHandler 回调
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler;

/// 当web视图需要响应身份验证时调用
/// @param webView 收到认证的web视图
/// @param challenge 身份验证的考验
/// @param completionHandler 回调
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler;

/// 当主frame导航开始时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation;

/// 当接收到主frame的服务器重定向时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation;

/// 当开始为主frame加载数据时发生错误时调用。
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
/// @param error 错误信息
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error;

/// 当内容开始到达主frame时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation;

/// 当主frame导航完成时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation;

/// 在提交的主frame导航期间发生错误时调用
/// @param webView 调用委托方法的web视图
/// @param navigation 导航
/// @param error 错误信息
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error;

/// 当web视图的web内容进程终止时调用
/// @param webView 其基础web内容进程被终止的web视图
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView;

/// 标题变更
- (void)webviewDidChangeTitle:(NSString * _Nullable)title;

/// 收到js调用
- (void)webViewDidReceiveScriptMessage:(WKScriptMessage *)message;

@end

NS_ASSUME_NONNULL_END
