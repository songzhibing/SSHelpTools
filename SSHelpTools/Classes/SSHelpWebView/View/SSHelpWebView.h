//
//  SSHelpWebView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import <UIKit/UIKit.h>
#import <SSHelpTools/SSHelpView.h>
#import <WebKit/WebKit.h>

#import "SSHelpWebBaseModule.h"
#import "SSHelpWebViewDelegate.h"
#import "SSHelpWebViewSharedConfigurations.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpWebView : SSHelpView

/// 是否隐藏加载进度条，默认no显示
@property(nonatomic, assign) BOOL hiddenProgressView;

/// 是否允许右滑返回上个链接，左滑前进, 默认yes
@property(nonatomic, assign) BOOL allowsBackForwardNavigationGestures;

/// 是否注入'后退刷新js'，默认yes
@property(nonatomic, assign) BOOL injectPageshowJs;

/// 是否注入'禁用长按显示系统菜单js'，默认yes
@property(nonatomic, assign) BOOL injectWebkitTouchCalloutJs;

/// 是否注入'禁止用户进行复制、选择js'，默认yes
@property(nonatomic, assign) BOOL injectWebkitUserSelectJs;

/// 是否支持自定义长按手势识别:识别web中二维码、看图模式、.... ，默认no
@property(nonatomic, assign) BOOL supportLongPressGestureRecognizer;

/// 首次加载Cookie管理
@property(nonatomic, assign) SSHelpWebViewCookiePolicy cookiePolicy;

/// 自定义WKWeb UserAgent
@property(nonatomic, copy, nullable) NSString *customUserAgent;

/// 在页面初始前，预加载一些js（页面加载之后再设置无效）
@property(nonatomic, strong, nullable) NSMutableArray <WKUserScript *> *customUserScripts;

/// WKWebView代理
@property(nonatomic, weak) id <SSHelpWebViewDelegate> webViewDelegate;

/// js功能模块代理
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

/// 加载视图控制器
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^ __nullable)(void))completion;

/// 提示
- (void)showToast:(NSString *)message;


/// 下列均应用SSHelpWebViewSharedConfigurations配置，可自定义
- (WKWebsiteDataStore *)websiteDataStore;

- (WKProcessPool *)processPool;

- (WKWebpagePreferences *)webpagePreferences API_AVAILABLE(ios(13.0));

- (WKPreferences *)preferences;


@end

NS_ASSUME_NONNULL_END
