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

@optional

/// 是否要自定义api
/// @param className 模块类
/// @param api jsName
- (NSString *)webModule:(NSString *)className hookJsName:(NSString *)api;

/// 是否要自定义api实现逻辑
/// @param className 模块类
/// @param jsHandler 参数实例
/// @param callback  未实现自定义，则回调原模块实现；已实现自定义实现，勿回调；
- (void)webModule:(NSString *)className hookJsHandler:(SSHelpWebObjcHandler *)jsHandler callback:(void(^)(SSHelpWebObjcHandler *jsHandler))callback;

@end



@interface SSHelpWebView : WKWebView <WKNavigationDelegate,WKUIDelegate>

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame configuration:(WKWebViewConfiguration *)configuration NS_UNAVAILABLE;

/// 初始化
+ (instancetype)ss_new;

/// 初始化
/// - Parameter block: 自定义回调
+ (instancetype)ss_newBy:(void(^_Nullable)(WKWebViewConfiguration *))block;

/// 日志输出
@property(nonatomic, assign) BOOL logEnable;

/// 总代理
@property(nonatomic, weak) id <SSHelpWebViewDelegate> delegate;

/// 注册js接口模块类-推荐
- (void)registerJsHandlerImpClasses:(NSArray <Class> *)classes;

/// 注册js接口
/// @param handlerName js方法名称
/// @param handler 回调
- (void)registerHandler:(NSString *)handlerName handler:(SSBridgeHandler)handler;

/// 回调js接口
- (void)callHandler:(NSString *)handlerName data:(id)data responseCallback:(SSBridgeCallback)responseCallback;

/// 弹出视图控制器
- (void)presentViewController:(UIViewController *)alert animated:(BOOL)flag completion:(SSBlockVoid)completion;

@end

NS_ASSUME_NONNULL_END
