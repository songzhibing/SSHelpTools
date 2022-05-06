//
//  SSHelpWebView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import "SSHelpWebView.h"
#import "SSHelpWebTestJsBridgeModule.h"

WKWebsiteDataStore *sharedWebsiteDataStore(void){
    static WKWebsiteDataStore *websiteDataStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    });
    return websiteDataStore;
}

@interface SSHelpWebView()<WKUIDelegate,WKNavigationDelegate,SSWebModuleDelegate>

@property(nonatomic, strong) UIProgressView *loadingPogressView;

@property(nonatomic, strong) WKWebView *webView;

@property(nonatomic, strong) WKWebViewConfiguration *configuration;

@property(nonatomic, strong) WKUserContentController *userContent;
 
//Native & h5 交互
@property(nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@property(nonatomic, strong) NSMutableDictionary <NSString *, SSBridgeJsHandler> *messageHandlers;

@property(nonatomic, strong) NSMutableArray <NSString *> *moduleImpClasses;

@property(nonatomic, strong) NSMutableArray <__kindof SSHelpWebBaseModule *> *moduleImpInstances;

@property(nonatomic,   copy) NSString *cookieDefaultsKey;

@end

@implementation SSHelpWebView

#pragma mark - System Method

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
- (void)loadRequest:(NSURLRequest *)request;
{
    WKNavigation *navigation = [self.webView loadRequest:request];
    SSWebLog(@"SSHelpWebView loadRequest %@ ... ",navigation);
}

/// @abstract Navigates to the requested file URL on the filesystem.
/// @param URL The file URL to which to navigate.
/// @param readAccessURL The URL to allow read access to.  @discussion If readAccessURL references a single file, only that file may be loaded by WebKit.If readAccessURL references a directory, files inside that file may be loaded by WebKit.
- (void)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL;
{
    WKNavigation *navigation = [self.webView loadFileURL:URL
                                 allowingReadAccessToURL:readAccessURL];
    SSWebLog(@"SSHelpWebView loadFileURL:allowingReadAccessToURL %@ ... ",navigation);
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
    }else{
        [_moduleImpClasses addObject:className];
        return YES;
    }
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion
{
    if (self.ss_viewController) {
        [self.ss_viewController presentViewController:viewControllerToPresent animated:flag completion:completion];
    }
}

#pragma mark - Lazy loading

- (WKWebView *)webView
{
    if (!_webView){
        //禁止长按
        WKUserScript *touchClloutScript = [[WKUserScript alloc] initWithSource:@"document.documentElement.style.webkitTouchCallout='none';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        
        //禁止选择
        WKUserScript *selectScript = [[WKUserScript alloc] initWithSource:@"document.documentElement.style.webkitUserSelect='none';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        
        //后退刷新
        WKUserScript *reloadScript = [[WKUserScript alloc] initWithSource:@"window.addEventListener('pageshow', function(event){if(event.persisted || window.performance && window.performance.navigation.type == 2){location.reload();}});" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];

        /**
         WKUserContentController初始化
         :提供了一种向WebView发送JavaScript消息或者注入JavaScript脚本的方法
         */
        _userContent = [[WKUserContentController alloc] init];
        [_userContent addUserScript:touchClloutScript];
        [_userContent addUserScript:selectScript];
        [_userContent addUserScript:reloadScript];
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
        _configuration.processPool = self.sharedProcessPool;
        _configuration.preferences = self.sharedPreferences;
        _configuration.websiteDataStore = self.websiteDataStore;
        _configuration.allowsInlineMediaPlayback = YES; ///允许在线播放
        _configuration.userContentController = _userContent;
        if (@available(iOS 13.0, *)) {
            _configuration.defaultWebpagePreferences = self.sharedWebpagePreferences;
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
        if (_hiddenProgressView==NO) {
            _loadingPogressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
            _loadingPogressView.frame = CGRectMake(0, 0, self.ss_width, 6);
            _loadingPogressView.trackTintColor = [UIColor grayColor]; //设置进度条颜色
            _loadingPogressView.progressTintColor = [UIColor greenColor]; //设置进度条上进度的颜色
            [self addSubview:_loadingPogressView];
            [_loadingPogressView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.left.right.mas_equalTo(0);
                make.height.mas_equalTo(6);
            }];
        }
        
        [_webView addObserver:self forKeyPath:@"estimatedProgress"
                      options:NSKeyValueObservingOptionNew context:NULL];
        [_webView addObserver:self forKeyPath:@"title"
                      options:NSKeyValueObservingOptionNew context:NULL];
        
        
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
                jsModuleObj.moduleDelegate = self;
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

#pragma mark - Js交互代理

/// 是否要自定义api
/// @param identifier 模块标识符
/// @param api jsName
- (NSString *)webModule:(NSString *)identifier hookJsName:(NSString *)api
{
    if (_moduleDelegate && [_moduleDelegate respondsToSelector:@selector(webModule:hookJsName:)]) {
        return [_moduleDelegate webModule:identifier hookJsName:api];
    }
    return api;
}

/// 是否要自定义api实现逻辑
/// @param identifier 模块标识符
/// @param jsHandler 参数实例
/// @param moduleHandler 模块回调
- (void)webModule:(NSString *)identifier hookJsHandler:(SSHelpWebObjcJsHandler *)jsHandler moduleHandler:(SSBridgeJsHandler)moduleHandler
{
    if (_moduleDelegate && [_moduleDelegate respondsToSelector:@selector(webModule:hookJsHandler:moduleHandler:)]) {
        [_moduleDelegate webModule:identifier hookJsHandler:jsHandler moduleHandler:moduleHandler];
    }
}

/// 功能模块实现不了，需要调用者实现
/// @param identifier 模块标识符
/// @param jsHandler 参数实例
- (void)webModule:(NSString *)identifier invokeJsHandler:(SSHelpWebObjcJsHandler *)jsHandler
{
    if (_moduleDelegate && [_moduleDelegate respondsToSelector:@selector(webModule:invokeJsHandler:)]) {
        [_moduleDelegate webModule:identifier invokeJsHandler:jsHandler];
    }
}

#pragma mark - KVO的监听代理

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //加载进度值
    if ([keyPath isEqualToString:@"estimatedProgress"]){
        if (object == _webView){
            if (_loadingPogressView) {
                [_loadingPogressView setAlpha:1.0f];
                [_loadingPogressView setProgress:_webView.estimatedProgress animated:YES];
                if(_webView.estimatedProgress >= 1.0f)
                {
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
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else if ([keyPath isEqualToString:@"title"]){ //网页title
        if (object == _webView){
            NSString *newTitle = _webView.title;
            if (_webViewDelegate && [_webViewDelegate respondsToSelector:@selector(webviewDidChangeTitle:)]) {
                [_webViewDelegate webviewDidChangeTitle:newTitle];
            }
        }else{
            [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        }
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Cookie

- (NSString *)cookieDefaultsKey
{
    if (!_cookieDefaultsKey) {
        _cookieDefaultsKey = [[NSBundle mainBundle].bundleIdentifier stringByAppendingString:@".defaults.cookies.key"];
    }
    return _cookieDefaultsKey;
}

- (nullable NSMutableArray <NSHTTPCookie *> *)getAllCookies
{
    NSMutableArray <NSHTTPCookie *>*_cookies = [NSMutableArray array];
    
    // 获取NSHTTPCookieStorage中的Cookie
    NSHTTPCookieStorage *shareCookie = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in shareCookie.cookies){
        [_cookies addObject:cookie];
    }

    // 获取存储的Cookie
    NSData *defaultsCookieData = [[NSUserDefaults standardUserDefaults] objectForKey:self.cookieDefaultsKey];
    NSMutableArray <NSHTTPCookie*>* defaultsCookieArray = nil;
    if (defaultsCookieData) {
        if (@available(iOS 11.0, *)) {
            defaultsCookieArray = [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:defaultsCookieData error:NULL];
        }else{
            defaultsCookieArray = [NSKeyedUnarchiver unarchiveObjectWithData:defaultsCookieData];
        }
    }
    NSDate *nowDate = [NSDate date]; //时区 UTC
    SSWebLog(@"defaultsCookieData=%@",defaultsCookieData);
    [defaultsCookieArray enumerateObjectsUsingBlock:^(NSHTTPCookie * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.expiresDate) {
            [_cookies addObject:obj];
        }else{
            if ([obj.expiresDate compare:nowDate]) {
                [_cookies addObject:obj];
            }else{
                //[defaultsCookieArray removeObject:obj];
            }
        }
    }];
    
    //更新存储的数据
    NSData *newCookiesData = nil;
    if (_cookies && _cookies.count) {
        if (@available(iOS 11.0, *)) {
            newCookiesData = [NSKeyedArchiver archivedDataWithRootObject:_cookies requiringSecureCoding:YES error:NULL];
        }else{
            newCookiesData = [NSKeyedArchiver archivedDataWithRootObject:_cookies];
        }
        if (newCookiesData) {
            [[NSUserDefaults standardUserDefaults] setObject:newCookiesData forKey:self.cookieDefaultsKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }

    return _cookies;
}


#pragma mark - WebViewConfiguraion

/**
 与WebView关联的WKWebsiteDataStore对象
 网站的各种类型的数据，数据类型包括:cookies, disk and memory caches, and persistent data such as WebSQL, IndexedDB databases, and local storage。
 如果一个WebView关联了一个非持久化的WKWebsiteDataStore，将不会有数据被写入到文件系统
 该特性可以用来实现隐私浏览。
 */
- (WKWebsiteDataStore *)websiteDataStore
{
    return sharedWebsiteDataStore();
}

+ (void)clearWebsiteDataStore
{
    WKWebsiteDataStore *dataStore = sharedWebsiteDataStore();
    if (dataStore.isPersistent) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [dataStore removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
            
        }];
    }
}

/**
 一个WKProcessPool对象代表Web Content的进程池。

 与WebView的进程池关联的进程池通过其configuration来配置。每个WebView都有自己的Web Content进程，最终由一个有具体实现的进程来限制;在此之后，具有相同进程池的WebView最终共享Web Content进程。

 WKProcessPool对象只是一个简单的不透明token，本身没有属性或者方法。
 */
- (WKProcessPool *)sharedProcessPool
{
    static WKProcessPool *processPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        processPool = [[WKProcessPool alloc] init];
    });
    return processPool;
}

- (WKWebpagePreferences *)sharedWebpagePreferences API_AVAILABLE(ios(13.0))
{
    static WKWebpagePreferences *webpagePreferences;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webpagePreferences = [[WKWebpagePreferences alloc] init];
        if (@available(iOS 14.0, *)) {
            webpagePreferences.allowsContentJavaScript = YES;
        }
        webpagePreferences.preferredContentMode = WKContentModeMobile;
    });
    return webpagePreferences;
}

- (WKPreferences *)sharedPreferences
{
    static WKPreferences *preferences;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preferences = [[WKPreferences alloc] init];
        preferences.javaScriptCanOpenWindowsAutomatically = YES; //允许使用js自动打开Window，默认不允许，js在调用window.open方法的时候，必须将改值设置为YES，才能从WKUIDelegate的代理方法中获取到.类似打开一个新的标签
    });
    return preferences;
}

@end
