//
//  SSHelpWebView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import "SSHelpWebView.h"
#import "SSHelpWebTestBridgeModule.h"
#import "SSHelpWebPhotoModule.h"

@interface SSHelpWebView()

@property(nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@property(nonatomic, strong) NSMutableDictionary <NSString *, id> *moduleInstancesByClassKey;

@property(nonatomic, strong) NSMutableDictionary <NSString *, SSBridgeHandler> *messageHandlers;

@end


@implementation SSHelpWebView

+ (instancetype)ss_new
{
    return [self ss_newBy:nil];
}

+ (instancetype)ss_newBy:(void(^_Nullable)(WKWebViewConfiguration *))block
{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    config.allowsInlineMediaPlayback = YES; // 允许在线播放
    config.allowsAirPlayForMediaPlayback = YES; //允许视频播放
    config.userContentController = [[WKUserContentController alloc] init];

    // 跨域问题
    @try {
        [config setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    // web脚本插入：
    NSArray *scripts = @[
        @"document.documentElement.style.webkitTouchCallout='none';",
        @"document.documentElement.style.webkitUserSelect='none';",
        // 页面返回刷新js
        // @"window.addEventListener('pageshow', function(event){if(event.persisted || window.performance && window.performance.navigation.type == 2){location.reload();}});"
    ];
    [scripts enumerateObjectsUsingBlock:^(NSString   * _Nonnull string, NSUInteger idx, BOOL * _Nonnull stop) {
        WKUserScript *script = [[WKUserScript alloc] initWithSource:string injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [config.userContentController addUserScript:script];
    }];
    
    // web进程池： 共享进程池,同一进程池中的webview才可以互相通讯
    static WKProcessPool *pool;
    static dispatch_once_t onceTokenPool;
    dispatch_once(&onceTokenPool, ^{
        pool = [[WKProcessPool alloc] init];
    });
    config.processPool = pool;

    // web选项设置：
    static WKPreferences *preferences;
    static dispatch_once_t onceTokenPre;
    dispatch_once(&onceTokenPre, ^{
        preferences = [[WKPreferences alloc] init];
        preferences.javaScriptEnabled = YES;
        // 是否允许 window.open 方法
        preferences.javaScriptCanOpenWindowsAutomatically = YES;
    });
    config.preferences = preferences;
        

    // web数据存储：
    static WKWebsiteDataStore *dataStore;
    static dispatch_once_t onceTokenDataStore;
    dispatch_once(&onceTokenDataStore, ^{
        dataStore = [WKWebsiteDataStore defaultDataStore];
    });
    config.websiteDataStore = dataStore;
   
    //  最终可自定义修改
    if (block) {
        block(config);
    }
    
    // 构建WKWebview
    SSHelpWebView *webView = [[self.class alloc] initWithFrame:UIScreen.mainScreen.bounds configuration:config];
    return webView;
}


- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.UIDelegate = self;
        self.navigationDelegate = self;        
        #ifdef DEBUG
        self.logEnable = YES;
        #endif
    }
    return self;
}

- (void)dealloc
{
    if (_moduleInstancesByClassKey) {
        [_moduleInstancesByClassKey removeAllObjects];
        _moduleInstancesByClassKey = nil;
    }
    if (_messageHandlers) {
        [_messageHandlers removeAllObjects];
        _messageHandlers = nil;
    }
}

- (NSMutableDictionary<NSString *,id> *)moduleInstancesByClassKey
{
    if (!_moduleInstancesByClassKey) {
        _moduleInstancesByClassKey = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _moduleInstancesByClassKey;
}

- (NSMutableDictionary <NSString *,SSBridgeHandler> *)messageHandlers
{
    if (!_messageHandlers) {
        _messageHandlers = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _messageHandlers;
}

#pragma mark -
#pragma mark - Public Method

/// 注册js接口模块类
- (void)registerWebModuleClasses:(NSArray <Class> *)classes
{
    @Tweakify(self);
    [classes enumerateObjectsUsingBlock:^(Class  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *className = NSStringFromClass(obj);
        if (NO==[self_weak_.moduleInstancesByClassKey.allKeys containsObject:className]) {
            [self_weak_.moduleInstancesByClassKey setObject:[NSNull null] forKey:className];
        }
    }];
}

/// 注册js接口
/// @param handlerName js方法名称
/// @param handler 回调
- (void)registerHandler:(NSString *)handlerName handler:(SSBridgeHandler)handler
{
    if (handlerName && handler) {
        self.messageHandlers[handlerName] = [handler copy];
    }
}

/// 回调js接口
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(SSBridgeCallback)responseCallback;
{
    [self.bridge callHandler:handlerName data:data responseCallback:^(id responseData) {
        if (responseCallback) {
            responseCallback(responseData);
        }
    }];
}

#pragma mark -
#pragma mark - Private Method

- (void)setupJavescriptBridge
{
    if (self.bridge) {
        return;
    }
    
    @Tweakify(self);
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self];
    [self.bridge setWebViewDelegate:self];

    // 非模块化接口注册
    [self.messageHandlers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SSBridgeHandler  _Nonnull callBack, BOOL * _Nonnull stop) {
        [self_weak_.bridge registerHandler:key handler:^(id data, WVJBResponseCallback responseCallback) {
            callBack(key,data,responseCallback);
        }];
    }];
    
    // 注册基础模块类
    [self registerWebModuleClasses:@[SSHelpWebTestBridgeModule.class,SSHelpWebPhotoModule.class]];

    // 是否有自定义
    BOOL hookApi = (self.delegate && [self.delegate respondsToSelector:@selector(webModule:hookJsName:)]);
    BOOL hookHandler = (self.delegate && [self.delegate respondsToSelector:@selector(webModule:hookJsHandler:callback:)]);
    
    // 接口实现
    void(^registerHandler)(NSString *, NSString *)  = ^(NSString *class, NSString *api) {
        [self_weak_.bridge registerHandler:api handler:^(id data, WVJBResponseCallback jsCallback) {
            // 封装
            SSHelpWebObjcHandler *handler = [SSHelpWebObjcHandler handlerWithApi:api data:data callBack:^(id  _Nonnull response) {
                if (jsCallback && response) {
                    NSString *jsonString = @"";
                    if ([response isKindOfClass:[SSHelpWebObjcResponse class]]) {
                        jsonString = [(SSHelpWebObjcResponse *)response toJsonString];
                    } else if([response isKindOfClass:[NSDictionary class]]) {
                        jsonString = ((NSDictionary *)response).ss_jsonStringEncoded;
                    } else if([response isKindOfClass:[NSArray class]]) {
                        jsonString = ((NSArray *)response).ss_jsonStringEncoded;
                    } else if([response isKindOfClass:[NSString class]]) {
                        jsonString = response;
                    } else {
                        jsonString = [[SSHelpWebObjcResponse failedWithError:@"未知数据类型"] toJsonString];
                    }
                    jsCallback(jsonString);
                }
            }];
            
            // 模块调用
            SSBlockId moduleCallback = ^(SSHelpWebObjcHandler *handler){
                Class objc = NSClassFromString(class);
                SSHelpWebBaseModule *instance = [self_weak_.moduleInstancesByClassKey objectForKey:class];
                if (instance && [instance isKindOfClass:SSHelpWebBaseModule.class]) {
                    // 已经构造过模块对象
                } else {
                    // 构造模块对象并持有
                    if ([class respondsToSelector:@selector(sharedInstance)]) {
                        instance = [objc sharedInstance];
                    } else {
                        instance = [[objc alloc] init];
                    }
                    [self_weak_.moduleInstancesByClassKey setObject:instance forKey:class];
                }
                // 执行js方法
                if ([instance respondsToSelector:@selector(evaluateJsHandler:)]) {
                    // 相关属性重新赋值
                    instance.webView = self_weak_;
                    instance.bridge = self_weak_.bridge;
                    // 调用模块实现的方法
                    [instance evaluateJsHandler:handler];
                }
            };
            
            // 执行js方法
            if (hookHandler) {
                // 自定义实现
                [self_weak_.delegate webModule:class hookJsHandler:handler callback:moduleCallback];
            } else {
                // 模块实现
                moduleCallback(handler);
            }
        }];
    };
    
    // 模块类遍历注册
    [self.moduleInstancesByClassKey enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull class, id  _Nonnull obj, BOOL * _Nonnull stop) {
        Class objc = NSClassFromString(class);
        if ([objc conformsToProtocol:@protocol(SSHelpWebModuleProtocol)]) {
            if ([objc respondsToSelector:@selector(suppertJsNames)]) {
                [[objc suppertJsNames] enumerateObjectsUsingBlock:^(NSString * _Nonnull api, NSUInteger idx, BOOL * _Nonnull stop) {
                    if (hookApi) {
                        api = [self_weak_.delegate webModule:class hookJsName:api];
                    }
                    // 注册接口
                    registerHandler(class,api);
                }];
            }
        }
    }];
}

/// 弹出视图控制器
- (void)presentViewController:(UIViewController *)alert animated: (BOOL)flag completion:(SSBlockVoid)completion;
{
    if (self.ss_viewController) {
        dispatch_main_async_safe(^{
            [self.ss_viewController presentViewController:alert animated:flag completion:completion];
        });
    }
}

#pragma mark -
#pragma mark - 加载页面

/*! @abstract Navigates to a requested URL.
 @param request The request specifying the URL to which to navigate.
 @result A new navigation for the given request.
 */
- (nullable WKNavigation *)loadRequest:(NSURLRequest *)request
{
    [self setupJavescriptBridge];
    return [super loadRequest:request];
}

/*! @abstract Navigates to the requested file URL on the filesystem.
 @param URL The file URL to which to navigate.
 @param readAccessURL The URL to allow read access to.
 @discussion If readAccessURL references a single file, only that file may be loaded by WebKit.
 If readAccessURL references a directory, files inside that file may be loaded by WebKit.
 @result A new navigation for the given file URL.
 */
- (nullable WKNavigation *)loadFileURL:(NSURL *)URL allowingReadAccessToURL:(NSURL *)readAccessURL API_AVAILABLE(macos(10.11), ios(9.0))
{
    [self setupJavescriptBridge];
    return [super loadFileURL:URL allowingReadAccessToURL:readAccessURL];
}

/*! @abstract Sets the webpage contents and base URL.
 @param string The string to use as the contents of the webpage.
 @param baseURL A URL that is used to resolve relative URLs within the document.
 @result A new navigation.
 */
- (nullable WKNavigation *)loadHTMLString:(NSString *)string baseURL:(nullable NSURL *)baseURL
{
    [self setupJavescriptBridge];
    return [super loadHTMLString:string baseURL:baseURL];
}

/*! @abstract Sets the webpage contents and base URL.
 @param data The data to use as the contents of the webpage.
 @param MIMEType The MIME type of the data.
 @param characterEncodingName The data's character encoding name.
 @param baseURL A URL that is used to resolve relative URLs within the document.
 @result A new navigation.
 */
- (nullable WKNavigation *)loadData:(NSData *)data MIMEType:(NSString *)MIMEType characterEncodingName:(NSString *)characterEncodingName baseURL:(NSURL *)baseURL API_AVAILABLE(macos(10.11), ios(9.0))
{
    [self setupJavescriptBridge];
    return [super loadData:data MIMEType:MIMEType characterEncodingName:characterEncodingName baseURL:baseURL];;
}

#pragma mark -
#pragma mark - WKWebView代理

/// window.open
- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
    if(navigationAction.targetFrame == nil || !navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
    }
    return nil;
}

- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler();
    }])];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message?:@"" preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:([UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }])];
    [alert addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }])];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * _Nullable))completionHandler
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:prompt preferredStyle:UIAlertControllerStyleAlert];
    @Tweakify(alert);
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = defaultText;
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = [alert_weak_.textFields firstObject];
        completionHandler(tf.text);
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(defaultText);
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark - WKNavigationDelegate Method

/// 决定是否允许或取消加载
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (self.logEnable) {
        SSLog(@"决定是否允许或取消加载: %@ ... ",navigationAction.request.URL);
    }

    SEL sel = @selector(webView:decidePolicyForNavigationAction:decisionHandler:);
    if (_delegate &&  [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id_id(_delegate, sel, webView, navigationAction, decisionHandler);
    } else {
        NSURL *url = navigationAction.request.URL;
        if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
            //跳转别的应用如系统浏览器
            if ([[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
            decisionHandler(WKNavigationActionPolicyCancel);
        } else {
            //应用的web内跳转
            decisionHandler (WKNavigationActionPolicyAllow);
        }
    }
}

/// 得到响应后决定是否允许跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (self.logEnable) {
        SSLog(@"得到响应后决定是否允许跳转: %@",navigationResponse.response.URL);
    }
    
    SEL sel = @selector(webView:decidePolicyForNavigationResponse:decisionHandler:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id_id(_delegate, sel, webView, navigationResponse, decisionHandler);
    } else {
        //允许跳转
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

/// 当web视图需要响应身份验证时调用
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (self.logEnable) {
        SSLog(@"需要响应身份验证: %@ ... ",challenge.protectionSpace);
    }
    SEL sel = @selector(webView:didReceiveAuthenticationChallenge:completionHandler:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id_id(_delegate, sel, webView, challenge, completionHandler);
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        } else {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling ,nil);
        }
    }
}

/// 页面开始加载时调用
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.logEnable) {
        SSLog(@"开始加载: ...");
    }
    SEL sel = @selector(webView:didStartProvisionalNavigation:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id(_delegate, sel, webView, navigation);
    }
}

/// 主机地址被重定向时调用
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.logEnable) {
        SSLog(@"重定向: ...");
    }
    SEL sel = @selector(webView:didReceiveServerRedirectForProvisionalNavigation:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id(_delegate, sel, webView, navigation);
    }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.logEnable) {
        SSLog(@"加载失败: %@ ... ",error.localizedDescription);
    }
    SEL sel = @selector(webView:didFailProvisionalNavigation:withError:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id_id(_delegate, sel, webView, navigation, error);
    }
}

/// 开始接收Web内容
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.logEnable) {
        SSLog(@"加载导航内容: ... ");
    }
    SEL sel = @selector(webView:didCommitNavigation:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id(_delegate, sel, webView, navigation);
    }
}

/// 加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.logEnable) {
        SSLog(@"加载导航完成: ... ");
        [webView evaluateJavaScript:@"window.location.href" completionHandler:^(id _Nullable urlStr, NSError * _Nullable error) {
            SSLog(@"页面最终地址:%@",urlStr);
        }];
    }
    
    SEL sel = @selector(webView:didFinishNavigation:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id(_delegate, sel, webView, navigation);
    }
}

/// 失败
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.logEnable) {
        SSLog(@"加载导航失败: %@ ... ",error.localizedDescription);
    }
    
    SEL sel = @selector(webView:didFailNavigation:withError:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id_id_id(_delegate, sel, webView, navigation, error);
    }
}

/// Web进程终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    if (self.logEnable) {
        SSLog(@"进程终止: ...");
    }
    
    SEL sel = @selector(webViewWebContentProcessDidTerminate:);
    if (_delegate && [_delegate respondsToSelector:sel]) {
        void_objc_msgSend_id(_delegate, sel, webView);
    } else {
        [webView reload];
    }
}

@end
