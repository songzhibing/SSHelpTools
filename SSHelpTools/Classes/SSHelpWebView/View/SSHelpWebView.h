//
//  SSHelpWebView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import <WebKit/WebKit.h>
#import "SSHelpWebBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpWebViewDelegate <WKNavigationDelegate,WKUIDelegate>

@end


typedef void(^_Nullable SSWebViewConfigBlock)(WKWebViewConfiguration *_Nonnull configuration);


@interface SSHelpWebView : WKWebView

+ (instancetype)defauleWebView;

+ (instancetype)defauleWebViewWithFrame:(CGRect)frame configuration:(SSWebViewConfigBlock)block;

/// 日志输出
@property(nonatomic, assign) BOOL logEnable;

/// 代理
@property(nonatomic, weak) id <SSHelpWebViewDelegate> ss_delegate;

/// js接口功能模块代理
@property(nonatomic, weak) id <SSWebModuleDelegate> moduleDelegate;

/// 长按手势识别
/// @support 识别网页中二维码
/// @support 看图模式
@property(nonatomic, assign) BOOL supportLongPressGestureRecognizer;

/// 注册js接口
/// @param handlerName js方法名称
/// @param handler 回调
- (void)registerHandler:(NSString *)handlerName handler:(SSBridgeHandler)handler;

/// 注册js接口模块类
- (BOOL)registerJsHandlerImpClass:(Class)moduleClass;

/// 回调js接口
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(SSBridgeCallback)responseCallback;

/// 弹出视图控制器
- (void)presentViewController:(UIViewController *)alert animated: (BOOL)flag completion:(SSBlockVoid)completion;

@end

NS_ASSUME_NONNULL_END
