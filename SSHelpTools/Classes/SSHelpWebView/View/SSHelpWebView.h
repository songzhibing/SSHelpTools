//
//  SSHelpWebView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import <UIKit/UIKit.h>
#import <SSHelpTools/SSHelpTools.h>
#import <WebKit/WebKit.h>
#import "SSHelpWebBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSWebViewDelegate <NSObject>

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

@interface SSHelpWebView : SSHelpView

/// 是否隐藏加载进度条，默认NO=显示
@property(nonatomic, assign) BOOL hiddenProgressView;

/// 是否允许右滑返回上个链接，左滑前进, 默认不允许
@property(nonatomic, assign) BOOL allowsBackForwardNavigationGestures;

/// 自定义WKWeb UserAgent
@property(nonatomic, copy, nullable) NSString *customUserAgent;

/// 在页面初始前，预加载一些js（页面加载之后再设置无效）
@property(nonatomic, strong, nullable) NSArray <WKUserScript *> *customUserScripts;

/// WKWebView代理
@property(nonatomic, weak) id <SSWebViewDelegate> webViewDelegate;

/// js功能代理
@property(nonatomic, weak) id <SSWebModuleDelegate> moduleDelegate;

/// 注册"js handler"功能方法
/// @param handlerName 方法名称
/// @param handler 回调
- (void)registerHandler:(NSString *)handlerName handler:(SSBridgeJsHandler)handler;

/// 注册"js handler"模块功能
- (BOOL)registerJsHandlerImpClass:(Class)moduleClass;

/// @abstract Navigates to a requested URL.
/// @param request The request specifying the URL to which to navigate.
- (void)loadRequest:(NSURLRequest *)request;

/// @abstract Navigates to the requested file URL on the filesystem.
/// @param URL The file URL to which to navigate.
/// @param readAccessURL The URL to allow read access to.  @discussion If readAccessURL references a single file, only that file may be loaded by WebKit.If readAccessURL references a directory, files inside that file may be loaded by WebKit.
- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL;

/// 执行js语句
/// @param javaScriptString js
/// @param completionHandler 回调
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler;

/// 弹出视图
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion;

/// 清除缓存数据
+ (void)clearWebsiteDataStore;

/// 相关配置，可自定义，默认都提供一个单列实例
- (WKWebsiteDataStore *)websiteDataStore;

- (WKProcessPool *)sharedProcessPool;

- (WKWebpagePreferences *)sharedWebpagePreferences API_AVAILABLE(ios(13.0));

- (WKPreferences *)sharedPreferences;


@end

NS_ASSUME_NONNULL_END
