//
//  SSHelpWebView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import "SSHelpWebView.h"
#import "SSHelpWebTestJsBridgeModule.h"
#import "SSHelpWebView+GestureRecognizer.h"

@interface SSHelpWebView()<WKUIDelegate,WKNavigationDelegate>

@property(nonatomic, strong) UIProgressView *loadingPogressView;

@property(nonatomic, strong) WKWebView *webView;

@property(nonatomic, strong) WKWebViewConfiguration *configuration;

@property(nonatomic, strong) WKUserContentController *userContent;
 
/// Native & h5 交互
@property(nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@property(nonatomic, strong) NSMutableDictionary <NSString *, SSBridgeJsHandler> *messageHandlers;

@property(nonatomic, strong) NSMutableArray <NSString *> *moduleImpClasses;

@property(nonatomic, strong) NSMutableArray <__kindof SSHelpWebBaseModule *> *moduleImpInstances;

@end

@implementation SSHelpWebView

#pragma mark - System Method

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _hiddenProgressView = NO;
        _injectPageshowJs = YES;
        _injectWebkitTouchCalloutJs = YES;
        _injectWebkitUserSelectJs = YES;
        _allowsBackForwardNavigationGestures = YES;
        _supportLongPressGestureRecognizer = NO;
        _cookiePolicy = SSHelpWebViewCookieEnableSystem;
    }
    return self;
}

- (void)dealloc
{
    if (_messageHandlers) {
        for (NSString *key in _messageHandlers.allKeys) {
            if (_userContent) {
                [_userContent removeScriptMessageHandlerForName:key];
            }
        }
    }
    if (_moduleImpClasses) {
        [_moduleImpClasses removeAllObjects];
    }
    if (_moduleImpInstances) {
        [_moduleImpInstances removeAllObjects];
    }
    
    if (_webView) {
        [_webView removeObserver:self forKeyPath:@"estimatedProgress"];
        [_webView removeObserver:self forKeyPath:@"title"];
    }
}

#pragma mark - Public Method
 
/// @abstract Navigates to a requested URL.
/// @param request The request specifying the URL to which to navigate.
- (void)loadRequest:(NSMutableURLRequest *)request;
{    
    NSMutableURLRequest *mutableRequest = request.mutableCopy;
    NSArray <NSHTTPCookie *> *_cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookiesForURL:mutableRequest.URL];

    if (self.cookiePolicy & SSHelpWebViewCookieEnablePHP) {
        // Tip1: 在request header中设置Cookie,解决首个请求Cookie丢失问题,页面PHP等动态语言能够获取到（js获取不到）
        if (_cookies) {
            NSDictionary *cookieDict =  [NSHTTPCookie requestHeaderFieldsWithCookies:_cookies]; // @{Cookie = "dotcom_user=xxx; logged_in=yes; __Host-user_session_same_site=xxx; user_session=xxx; _octo=GH1.1.xx.xx; _device_id=xx"; }
            NSString *cookieString = [cookieDict objectForKey:@"Cookie"];
            [mutableRequest addValue:cookieString forHTTPHeaderField:@"Cookie"];
        }
    }
    
    if (self.cookiePolicy & SSHelpWebViewCookieEnableJs) {
        // Tip2: 页面js可获取Cookie（PHP等动态语言获取不到）
        if (_cookies) {
            __block NSMutableString *jsCookiesString = @"".mutableCopy;
            [_cookies enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull cookie, NSUInteger idx, BOOL * _Nonnull stop) {
                [jsCookiesString appendString:[NSString stringWithFormat:@"document.cookie = '%@=%@';", cookie.name, cookie.value]];
            }];
            if (jsCookiesString.length) {
                WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:jsCookiesString injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
                [self.customUserScripts addObject:cookieScript];
            }
        }
    }
    
    @weakify(self);
    void (^__startLoadingRequest)(void) = ^(void){
        dispatch_main_async_safe(^{
#ifdef DEBUG
            if (@available(iOS 11.0, *)) {
                [self_weak_.webView.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull data) {
                    //SSWebLog(@"Sync Cookie After:%@",data);
                }];
            }
#endif
            [self_weak_.webView loadRequest:mutableRequest];
            SSWebLog(@"SSHelpWebView loadRequest %@ %@ ... ",[NSThread currentThread],mutableRequest);
        });
    };
    
    if (self.cookiePolicy & SSHelpWebViewCookieSyncCookieStore) {
        // Tip3: NSHTTPCookieStorage-->同步到-->WKHTTPCookieStore
        if (@available(iOS 11.0, *)) {
            NSArray *cookies = [[NSHTTPCookieStorage sharedHTTPCookieStorage] cookies];
            if (cookies.count) {
#ifdef DEBUG
                [self.webView.configuration.websiteDataStore.httpCookieStore getAllCookies:^(NSArray<NSHTTPCookie *> * _Nonnull data) {
                    //SSWebLog(@"Sync Cookie Before:%@",data);
                }];
#endif
                dispatch_group_t group = dispatch_group_create();
                for (NSInteger index=0; index<cookies.count; index++) {
                    dispatch_group_enter(group);
                    NSHTTPCookie * _Nonnull cookie = cookies[index];
                    [self.webView.configuration.websiteDataStore.httpCookieStore setCookie:cookie completionHandler:^{
                        dispatch_group_leave(group);
                    }];
                }
                dispatch_group_notify(group, dispatch_get_main_queue(), __startLoadingRequest);
                return;
            }
        }
    }
    __startLoadingRequest();
}

- (void)showToast:(NSString *)message
{
    SSWebLog(@"日志：%@",message);
}

/// @abstract Navigates to the requested file URL on the filesystem.
/// @param URL The file URL to which to navigate.
/// @param readAccessURL The URL to allow read access to.  @discussion If readAccessURL references a single file, only that file may be loaded by WebKit.If readAccessURL references a directory, files inside that file may be loaded by WebKit.
- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL;
{
    [self.webView loadFileURL:URL allowingReadAccessToURL:readAccessURL];
    SSWebLog(@"loadFileURL:allowingReadAccessToURL %@ %@... ",URL.absoluteString,readAccessURL.absoluteString);
}

/// 执行js语句
/// @param javaScriptString js
/// @param completionHandler 回调
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler
{
    [self.webView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

/// 注册"js handler"功能方法
/// @param handlerName 方法名称
/// @param handler 回调
- (void)registerHandler:(NSString *)handlerName handler:(SSBridgeJsHandler)handler
{
    if (handlerName && handler) {
        if (!_messageHandlers) {
            _messageHandlers = [[NSMutableDictionary alloc] initWithCapacity:1];
        }
        _messageHandlers[handlerName] = [handler copy];
    }
}

/// 注册"js handler"模块功能类
- (BOOL)registerJsHandlerImpClass:(Class)moduleClass
{
    NSString *className = NSStringFromClass(moduleClass);
    if (!_moduleImpClasses) {
        _moduleImpClasses = [[NSMutableArray alloc] initWithCapacity:1];
    }
    if ([_moduleImpClasses containsObject:className]) {
        return NO;
    } else {
        [_moduleImpClasses addObject:className];
        return YES;
    }
}

/// 加载视图控制器
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion
{
    if (self.ss_viewController) {
        [self.ss_viewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

#pragma mark - Lazy loading

- (WKWebView *)webView
{
    if (!_webView) {
        /**
         配置管理 JavaScript
         */
        _userContent = [[WKUserContentController alloc] init];
        
        if (_injectWebkitTouchCalloutJs) {  //禁止长按显示系统菜单
            WKUserScript *touchClloutScript = [[WKUserScript alloc] initWithSource:@"document.documentElement.style.webkitTouchCallout='none';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [_userContent addUserScript:touchClloutScript];
        }
        
        if (_injectWebkitUserSelectJs) { //禁止用户进行复制、选择
            WKUserScript *selectScript = [[WKUserScript alloc] initWithSource:@"document.documentElement.style.webkitUserSelect='none';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [_userContent addUserScript:selectScript];
        }
        
        if (_injectPageshowJs) { //页面后退刷新
            WKUserScript *reloadScript = [[WKUserScript alloc] initWithSource:@"window.addEventListener('pageshow', function(event){if(event.persisted || window.performance && window.performance.navigation.type == 2){location.reload();}});" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
            [_userContent addUserScript:reloadScript];
        }
        
        for (WKUserScript *scriptItem in _customUserScripts) {
            [_userContent addUserScript:scriptItem]; ///自定义的js
        }
        
        id handler = [[SSHelpWeakProxy alloc] initWithTarget:self];
        for (NSString *key in _messageHandlers.allKeys) { ///添加js方法
            [_userContent addScriptMessageHandler:handler name:key]; //注意，需要手动释放
        }
        
        /**
         WKWebViewConfiguration初始化
         使用WKWebViewConfiguration类，可以决定网页的渲染时机，媒体的播放方式，用户选择项目的粒度，
         以及很多其他的选项。 WKWebViewConfiguration只会在webview第一次初始化的时候使用，
         不能用此类来改变一个已经初始化完成的webview的配置。
         */
        _configuration = [[WKWebViewConfiguration alloc] init];
        _configuration.processPool = self.processPool;
        _configuration.preferences = self.preferences;
        _configuration.websiteDataStore = self.websiteDataStore;
        _configuration.allowsInlineMediaPlayback = YES; ///允许在线播放
        _configuration.userContentController = _userContent;
        if (@available(iOS 13.0, *)) {
            _configuration.defaultWebpagePreferences = self.webpagePreferences;
        }
        
        /**
         初始化 WKWebView
         */
        _webView = [[WKWebView alloc] initWithFrame:self.bounds configuration:_configuration];
        _webView.allowsBackForwardNavigationGestures = _allowsBackForwardNavigationGestures; //是否允许水平滑动手势来触发网页的前进和后退
        _webView.customUserAgent = _customUserAgent; //自定义UA eg. @"WebViewDemo/1.0.0";
        _webView.multipleTouchEnabled = YES;
        _webView.UIDelegate = self;
        _webView.navigationDelegate = self;
        [self addSubview:_webView];
        if (@available(iOS 11.0, *)) {
            _webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsZero);
        }];
      
        /**
         初始化进度条
         */
        if (!_hiddenProgressView) {
            _loadingPogressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            _loadingPogressView.frame = CGRectMake(0, 0, self.ss_width, 3);
            _loadingPogressView.progressTintColor = SSHELPTOOLSCONFIG.blueColor;
            _loadingPogressView.trackTintColor = [UIColor clearColor];
            [self addSubview:_loadingPogressView];
            [_loadingPogressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.mas_equalTo(0);
                make.height.mas_equalTo(3);
            }];
        }
        
        
        // KVO
        [_webView addObserver:self
                   forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        [_webView addObserver:self
                   forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew
                      context:NULL];
        
        // 手势识别
        if (_supportLongPressGestureRecognizer) {
            [self addLongPressGestureRecognizer:_webView];
        }
        
        /**
         初始化 WKWebViewJavascriptBridge
         */
        _bridge = [WKWebViewJavascriptBridge bridgeForWebView:_webView];
        [_bridge setWebViewDelegate:self];
        
        /**
         初始化所有的js功能模块
         */
        if (_moduleImpClasses && _moduleImpClasses.count) {
            _moduleImpInstances = [NSMutableArray arrayWithCapacity:_moduleImpClasses.count];
            for (NSInteger index=0; index<_moduleImpClasses.count; index++) {
                NSString *impClassName = _moduleImpClasses[index];
                Class jsModuleClass = NSClassFromString(impClassName);
                __kindof SSHelpWebBaseModule *jsModuleObj = [[jsModuleClass alloc] init];
                jsModuleObj.webView = _webView;
                jsModuleObj.bridge = _bridge;
                jsModuleObj.moduleDelegate = _moduleDelegate;
                if ([jsModuleObj respondsToSelector:@selector(moduleRegisterJsHandler)]) {
                    [jsModuleObj moduleRegisterJsHandler];
                }else{
                    SSWebLog(@"%@ dosn't responds to selector 'moduleRegisterJsHandler'?",impClassName);
                }
                //持有对象，防止提前释放，视图销毁时在释放
                [_moduleImpInstances addObject:jsModuleObj];
            }
        }
    }
    return _webView;
}

#pragma mark - KVO的监听代理

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        if (object == _webView) {
            if (_loadingPogressView) {
                [_loadingPogressView setAlpha:1.0f];
                [_loadingPogressView setProgress:_webView.estimatedProgress animated:YES];
                if (_webView.estimatedProgress >= 1.0f) {
                    [UIView animateWithDuration:0.5f
                                          delay:0.3f
                                        options:UIViewAnimationOptionCurveEaseOut
                                     animations:^{
                                         [self.loadingPogressView setAlpha:0.0f];
                                     }
                                     completion:^(BOOL finished) {
                                         [self.loadingPogressView setProgress:0.0f animated:NO];
                                     }];
                }
            }
            return;
        }
    } else if ([keyPath isEqualToString:@"title"]) { //网页title
        if (object == _webView){
            NSString *newTitle = _webView.title;
            if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webviewDidChangeTitle:)]) {
                [_webViewDelegate webviewDidChangeTitle:newTitle];
            }
            return;
        }
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

#pragma mark - WKWebViewConfiguraion

- (WKWebsiteDataStore *)websiteDataStore
{
    return [SSHelpWebViewSharedConfigurations sharedWebsiteDataStore];
}

- (WKProcessPool *)processPool
{
    return [SSHelpWebViewSharedConfigurations sharedProcessPool];
}

- (WKPreferences *)preferences
{
    return [SSHelpWebViewSharedConfigurations sharedPreferences];
}

- (WKWebpagePreferences *)webpagePreferences API_AVAILABLE(ios(13.0))
{
    return [SSHelpWebViewSharedConfigurations sharedWebpagePreferences];
}

#pragma mark - Lazy loading

- (NSMutableArray <WKUserScript *> *)customUserScripts
{
    if (!_customUserScripts) {
        _customUserScripts = [[NSMutableArray alloc] initWithCapacity:1];
    }
    return _customUserScripts;
}


@end
