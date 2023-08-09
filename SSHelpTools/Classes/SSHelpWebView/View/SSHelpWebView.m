//
//  SSHelpWebView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import "SSHelpWebView.h"
#import "SSHelpWebTestBridgeModule.h"
#import <SSHelpTools/UIImage+SSHelp.h>
#import <SSHelpTools/SSHelpPhotoManager.h>

@interface SSHelpWebView()<WKUIDelegate,WKNavigationDelegate,UIGestureRecognizerDelegate>

@property(nonatomic, strong) WKWebViewJavascriptBridge *bridge;

@property(nonatomic, strong) NSMutableDictionary <NSString *, SSBridgeHandler> *messageHandlers;

@property(nonatomic, strong) NSMutableArray <NSString *> *moduleImpClasses;

@property(nonatomic, strong) NSMutableArray <__kindof SSHelpWebBaseModule *> *moduleImpInstances;

/// 自定义多功能长按手势识别
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end


@implementation SSHelpWebView

+ (WKWebViewConfiguration *)defaultConfiguration
{
    WKWebViewConfiguration *configuration = [[WKWebViewConfiguration alloc] init];
    configuration.allowsInlineMediaPlayback = YES; // 允许在线播放
    configuration.allowsAirPlayForMediaPlayback = YES; //允许视频播放
    configuration.userContentController = [[WKUserContentController alloc] init];

    @try {
        //跨域问题
        [configuration setValue:@YES forKey:@"allowUniversalAccessFromFileURLs"];
    } @catch (NSException *exception) {
    } @finally {
    }
    
    BOOL injectPageshowJs = YES;
    BOOL injectWebkitUserSelectJs = YES;
    BOOL injectWebkitTouchCalloutJs = YES;
    
    if (injectWebkitTouchCalloutJs) {
        WKUserScript *touchCalloutScript = [[WKUserScript alloc] initWithSource:@"document.documentElement.style.webkitTouchCallout='none';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [configuration.userContentController addUserScript:touchCalloutScript];
    }
    
    if (injectWebkitUserSelectJs) {
        WKUserScript *selectScript = [[WKUserScript alloc] initWithSource:@"document.documentElement.style.webkitUserSelect='none';" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [configuration.userContentController addUserScript:selectScript];
    }
    if (injectPageshowJs) {
        WKUserScript *reloadScript = [[WKUserScript alloc] initWithSource:@"window.addEventListener('pageshow', function(event){if(event.persisted || window.performance && window.performance.navigation.type == 2){location.reload();}});" injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:NO];
        [configuration.userContentController addUserScript:reloadScript];
    }
    //共享进程池,同一进程池中的webview才可以互相通讯
    static WKProcessPool *processPool;
    static dispatch_once_t poolOnceToken;
    dispatch_once(&poolOnceToken, ^{
        processPool = [[WKProcessPool alloc] init];
    });
    configuration.processPool = processPool;
    
    //web的首选项设置
    static WKPreferences *preferences;
    static dispatch_once_t preferensOnceToken;
    dispatch_once(&preferensOnceToken, ^{
        preferences = [[WKPreferences alloc] init];
        preferences.minimumFontSize = 0.0f; //最小字体设置,默认为0,H5中css的“font-size” 的值如果小于该值，则会使用该值作为字体的最小尺寸
        preferences.javaScriptEnabled = YES; //是否启用js脚本，默认启用，关闭则不会运算js脚本，加快渲染速度
        preferences.javaScriptCanOpenWindowsAutomatically = YES; //允许使用js自动打开Window，默认不允许，js 在调用window.open方法的时候，必须将改值设置为YES，才能从 WKUIDelegate 的代理方法中获取到
    });
    configuration.preferences = preferences;
    
    //web的首选项设置
    if (@available(iOS 14.0, *)) {
        static WKWebpagePreferences *pagePreference;
        static dispatch_once_t pagePreferenceOnceToken;
        dispatch_once(&pagePreferenceOnceToken, ^{
            pagePreference = [[WKWebpagePreferences alloc] init];
            pagePreference.allowsContentJavaScript = YES;
            pagePreference.preferredContentMode = WKContentModeMobile;
        });
        configuration.defaultWebpagePreferences = pagePreference;
    }
   

    //数据存储
    static WKWebsiteDataStore *websiteDataStore;
    static dispatch_once_t storeOnceToken;
    dispatch_once(&storeOnceToken, ^{
        websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    });
    configuration.websiteDataStore = websiteDataStore;
    
    //返回
    return configuration;
}

+ (instancetype)defauleWebView
{
    return [[self class] defauleWebViewWithFrame:UIScreen.mainScreen.bounds configuration:nil];
}

+ (instancetype)defauleWebViewWithFrame:(CGRect)frame configuration:(SSWebViewConfigBlock)block
{
    __block WKWebViewConfiguration *configuration = [SSHelpWebView defaultConfiguration];
    _kSafeBlock(block,configuration);
    __kindof SSHelpWebView *webView = [[[self class] alloc] initWithFrame:frame configuration:configuration];
    return webView;
}

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration
{
    self = [super initWithFrame:frame configuration:configuration];
    if (self) {
        // 适配
        self.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        self.UIDelegate = self;
        self.navigationDelegate = self;
        // 日志
        self.logEnable = NO;
    }
    return self;
}

- (void)dealloc
{
    if (_messageHandlers) {
        [_messageHandlers removeAllObjects];
    }
    if (_moduleImpClasses) {
        [_moduleImpClasses removeAllObjects];
    }
    if (_moduleImpInstances) {
        [_moduleImpInstances removeAllObjects];
    }
}

/// 注册"js handler"功能方法
/// @param handlerName 方法名称
/// @param handler 回调
- (void)registerHandler:(NSString *)handlerName handler:(SSBridgeHandler)handler
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

/// 回调js接口
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(SSBridgeCallback)responseCallback;
{
    if (_bridge) {
        [_bridge callHandler:handlerName data:data responseCallback:^(id responseData) {
            if (responseCallback) {
                responseCallback(responseData);
            }
        }];
    }
}

- (void)setupJavescriptBridge
{
    if (_bridge) {
        return;
    }
    
    @Tweakify(self);
    
    self.bridge = [WKWebViewJavascriptBridge bridgeForWebView:self];
    [self.bridge setWebViewDelegate:self];

    //非模块化接口注册
    [_messageHandlers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, SSBridgeHandler  _Nonnull callBack, BOOL * _Nonnull stop) {
        [self_weak_.bridge registerHandler:key handler:^(id data, WVJBResponseCallback responseCallback) {
            callBack(key,data,responseCallback);
        }];
    }];
    
    //模块化接口初始化
    [self registerJsHandlerImpClass:[SSHelpWebTestBridgeModule class]];
    _moduleImpInstances = [NSMutableArray arrayWithCapacity:_moduleImpClasses.count];
    [_moduleImpClasses enumerateObjectsUsingBlock:^(NSString * _Nonnull className, NSUInteger idx, BOOL * _Nonnull stop) {
        Class jsModuleClass = NSClassFromString(className);
        __kindof SSHelpWebBaseModule *jsModuleObj = [[jsModuleClass alloc] init];
        jsModuleObj.webView = self_weak_;
        jsModuleObj.bridge = self_weak_.bridge;
        jsModuleObj.moduleDelegate = self_weak_.moduleDelegate;
        if ([jsModuleObj respondsToSelector:@selector(moduleRegisterJsHandler)]) {
            [jsModuleObj moduleRegisterJsHandler];
            //持有对象，防止提前释放，视图销毁时在释放
            [self_weak_.moduleImpInstances addObject:jsModuleObj];
        } else {
            if (self_weak_.logEnable) {
                SSWebLog(@"%@ dosn't responds to selector 'moduleRegisterJsHandler'?",className);
            }
        }
    }];
}

#pragma mark -
#pragma mark - PresentViewController Methtod


- (void)presentAlertViewControllerWithMessage:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:NULL];
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
#pragma mark - UIGestureRecognizer Method

/// 长按识别手势设置
- (void)setSupportLongPressGestureRecognizer:(BOOL)supportLongPressGestureRecognizer
{
    if (supportLongPressGestureRecognizer) {
        if (_longPressGesture) return;
        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
        _longPressGesture.delegate = self;
        _longPressGesture.name = @"SSHelpWebView.LongPressGesture.identifier";
        [self addGestureRecognizer:_longPressGesture];
    } else {
        if (_longPressGesture) {
            [self removeGestureRecognizer:_longPressGesture];
            _longPressGesture = nil;
        }
    }
}

/// 长按识别手势
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

/// 长按识别手势
- (void)gestureRecognizerHandler:(UIGestureRecognizer *)gestureRecognizer
{
    @weakify(self);
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint point = [gestureRecognizer locationInView:self];
        if (point.x == NSNotFound || point.y == NSNotFound) return;
        if (_logEnable) {
            SSLog(@"手势开始...(%lf,%lf)",point.x,point.y);
        }

#ifdef DEBUG
//        NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).style.color='red';", point.x, point.y];
//        [self evaluateJavaScript:js completionHandler:^(NSString *_Nullable url, NSError * _Nullable error) {
//
//        }];
#endif
        
        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_group_t group = dispatch_group_create();
        
        NSString *toSaveImage    = @"保存图片";  //NSString *fcQRCode = @"识别二维码";
        NSString *toBrowseImages = @"看图模式";
        NSString *toCopyLinkText = @"复制链接文字";
        NSString *toCopyHref     = @"复制链接地址";
        NSArray  *toActionArray  = @[toSaveImage,toBrowseImages,toCopyLinkText,toCopyHref];
        __block NSMutableArray <UIAlertAction *> *actionArray = [[NSMutableArray alloc] init];
        
        for (NSInteger index=0; index<toActionArray.count; index++)
        {
            NSString *actionItem = toActionArray[index];
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                @strongify(self);
                if ([actionItem isEqualToString:toSaveImage])
                {
                    //获取长按位置对应的图片url
                    NSString *javaScript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", point.x, point.y];
                    [self evaluateJavaScript:javaScript completionHandler:^(NSString *_Nullable url, NSError * _Nullable error) {
                        if (self_weak_.logEnable) {
                            SSLog(@"长按图片信息：%@ 错误信息:%@",url,error.localizedDescription);
                        }
                        if (url) {
                            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
                            if (image) {
                                //只要是图片，则可保存图片
                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                    [SSHelpPhotoManager saveImage:image completionHandler:^(BOOL success, NSError * _Nullable error) {
                                        @strongify(self);
                                        [self presentAlertViewControllerWithMessage:success?@"保存成功":@"保存失败"];
                                    }];
                                }];
                                [actionArray addObject:action];
                                
                                //图片是二维码，则可进行识别
                                [UIImage ss_featuresInImage:image callback:^(NSString * _Nullable result) {
                                    if (result) {
                                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"识别二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                            //
                                        }];
                                        [actionArray addObject:action];
                                    }
                                    dispatch_group_leave(group);
                                }];
                                // 保证 dispatch_group_leave 对应
                                return;
                            }
                        }
                        dispatch_group_leave(group);
                    }];
                }
                else if ([actionItem isEqualToString:toBrowseImages])
                {
                    //获取所有图片
                    NSString *javaScript = @"function tmpDynamicSearchAllImage(){"
                                        "var img = [];"
                                        "for(var i=0;i<$(\"img\").length;i++){"
                                            "if(parseInt($(\"img\").eq(i).css(\"width\"))> 60){ "//获取所有符合放大要求的图片，将图片路径(src)获取
                                               //" img[i] = $(\"img\").eq(i).attr(\"src\");"
                                                "img[i] = $(\"img\").eq(i).prop(\"src\");"
                                           " }"
                                        "}"
                                        "var img_info = {};"
                                        "img_info.list = img;" //保存所有图片的url
                                        "return img;"
                                    "}";
                    [self evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        if (!error) {
                            @strongify(self);
                            [self evaluateJavaScript:@"tmpDynamicSearchAllImage()" completionHandler:^(id _Nullable array, NSError * _Nullable error){
                                if (self_weak_.logEnable) {
                                    SSWebLog(@"所有图片：%@",array);
                                }
                                dispatch_group_leave(group);
                            }];
                        } else {
                            dispatch_group_leave(group);
                        }
                    }];
                }
                else if ([actionItem isEqualToString:toCopyLinkText])
                {
                    //复制链接文字
                    NSString *javaScript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).innerText",point.x, point.y];
                    [self evaluateJavaScript:javaScript completionHandler:^(NSString *_Nullable text, NSError * _Nullable error) {
                        if (self_weak_.logEnable) {
                            SSWebLog(@"获取文字信息：%@ 错误信息:%@",text,error.localizedDescription);
                        }
                        if (text && text.length) {
                            UIAlertAction *action = [UIAlertAction actionWithTitle:toCopyLinkText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                [UIPasteboard generalPasteboard].string = text;
                            }];
                            [actionArray addObject:action];
                        }
                        dispatch_group_leave(group);
                    }];
                } else if ([actionItem isEqualToString:toCopyHref]) {
                    //复制链接
                    NSString *javaScript = @"function tmpDynamicJavaScriptSearchHref(x,y) {\
                                                var e = document.elementFromPoint(x, y);\
                                                while(e){\
                                                    if(e.href){\
                                                        return e.href;\
                                                    }\
                                                    e = e.parentElement;\
                                                }\
                                                return e.href;\
                                            }";
                    [self evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
                        if (error) {
                            if (self_weak_.logEnable) {
                                SSWebLog(@"注入获取链接JavaScript失败:%@",error.localizedDescription);
                            }
                            dispatch_group_leave(group);
                        } else {
                            @strongify(self);
                            NSString *javaScript = [NSString stringWithFormat:@"tmpDynamicJavaScriptSearchHref(%f,%f);",point.x,point.y];
                            [self evaluateJavaScript:javaScript completionHandler:^(NSString *_Nullable href, NSError * _Nullable error){
                                if (self_weak_.logEnable) {
                                    SSWebLog(@"获取链接信息：%@ 错误信息:%@",result,error.localizedDescription);
                                }
                                if (href && href.length) {
                                    UIAlertAction *action = [UIAlertAction actionWithTitle:toCopyHref style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                                        [UIPasteboard generalPasteboard].string = href;
                                    }];
                                    [actionArray addObject:action];
                                }
                                dispatch_group_leave(group);
                            }];
                        }
                    }];

                } else {
                    dispatch_group_leave(group);
                }
            });
        }
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (actionArray.count) {
                @strongify(self);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                for (NSInteger index=0; index<actionArray.count; index++) {
                    [alert addAction:actionArray[index]];
                }
                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                }];
                [alert addAction:cancel];
                [self presentViewController:alert animated:YES completion:nil];
            }
        });
    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_logEnable) {
            //SSLog(@"长按手势变化...");
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_logEnable) {
            SSLog(@"结束长按手势...");
        }
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
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入";
    }];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction * _Nonnull action) {
        UITextField *tf = [alert.textFields firstObject];
        completionHandler(tf.text);
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(defaultText);
    }];
    [alert addAction:ok];
    [alert addAction:cancel];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark -
#pragma mark - WKNavigationDelegate Method

/// 决定是否允许或取消加载
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if (_delegate &&  [_delegate respondsToSelector:@selector(ss_webView:decidePolicyForNavigationAction:decisionHandler:)]) {
        [_delegate ss_webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
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
    /*
        NSHTTPURLResponse *response = (NSHTTPURLResponse *)navigationResponse.response;
        if (response && [response isKindOfClass:[NSHTTPURLResponse class]]) {
            NSDictionary *allHeaderFields = [response allHeaderFields];
            NSURL *URL = [response URL];
            if (allHeaderFields && URL) {
                NSArray *cookies = [NSHTTPCookie cookiesWithResponseHeaderFields:allHeaderFields forURL:URL];
                if (cookies && cookies.count>0) {
                    if (@available(iOS 11.0, *)) {
                        //浏览器自动存储cookie, 这里就不用再处理了
                    }
                }
            }
        }
     */
    if (_delegate && [_delegate respondsToSelector:@selector(ss_webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [_delegate ss_webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    } else {
        //允许跳转
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

/// 当web视图需要响应身份验证时调用
- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))completionHandler
{
    if (_delegate && [_delegate respondsToSelector:@selector(ss_webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        [_delegate ss_webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            NSURLCredential *card = [[NSURLCredential alloc] initWithTrust:challenge.protectionSpace.serverTrust];
            completionHandler(NSURLSessionAuthChallengeUseCredential,card);
        } else {
            completionHandler(NSURLSessionAuthChallengePerformDefaultHandling ,nil);
        }
    }
}

/*! @abstract Invoked when a main frame navigation starts.
 @param webView The web view invoking the delegate method.
 @param navigation The navigation.
 开始加载
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{

}

/// 重定向
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(null_unspecified WKNavigation *)navigation
{

}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if (self.logEnable) {
        SSLog(@"加载失败:%@",error);
    }
}

///开始接收Web内容
- (void)webView:(WKWebView *)webView didCommitNavigation:(null_unspecified WKNavigation *)navigation
{

}

/// 加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation
{
    if (self.logEnable) {
        [webView evaluateJavaScript:@"window.location.href" completionHandler:^(id _Nullable urlStr, NSError * _Nullable error) {
            SSLog(@"加载完成:%@",urlStr);
        }];
        
        //webView 高度自适应
        [webView evaluateJavaScript:@"document.body.scrollHeight" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            // 获取页面高度，并重置 webview 的 frame
            SSLog(@"html.body的高度：%@", result);
        }];
    }
}

/// 失败
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error
{
    if (self.logEnable) {
        SSLog(@"加载失败:%@",error);
    }
}

/// web内容进程终止时调用
- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView
{
    if (self.logEnable) {
        SSLog(@"进程终止...");
    }
    [webView reload];
}

@end
