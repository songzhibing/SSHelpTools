//
//  SSHelpWebBaseModule.h
//  SSHelpWebView
//
//  Created by 宋直兵 on 2022/1/10.
//

#import <Foundation/Foundation.h>
#import <SSHelpTools/SSHelpTools.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>

#import "SSHelpWebObjcApi.h"
#import "SSHelpWebObjcJsHandler.h"
#import "SSHelpWebObjcResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpWebModuleProtocol <NSObject>

@required

/// 各功能模块注册js方法和实现入口
- (void)moduleRegisterJsHandler;

@end

@protocol SSWebModuleDelegate <NSObject>

@optional

/// 是否要自定义api
/// @param identifier 模块标识符
/// @param api jsName
- (NSString *)webModule:(NSString *)identifier hookJsName:(NSString *)api;

/// 是否要自定义api实现逻辑
/// @param identifier 模块标识符
/// @param jsHandler 参数实例
/// @param moduleHandler 模块回调
- (void)webModule:(NSString *)identifier hookJsHandler:(SSHelpWebObjcJsHandler *)jsHandler moduleHandler:(SSBridgeJsHandler)moduleHandler;

/// 功能模块实现不了，需要调用者实现
/// @param identifier 模块标识符
/// @param jsHandler 参数实例
- (void)webModule:(NSString *)identifier invokeJsHandler:(SSHelpWebObjcJsHandler *)jsHandler;

@end


@interface SSHelpWebBaseModule : NSObject <SSHelpWebModuleProtocol>

/// 模块标识符，模块初始化时自动生成
@property(nonatomic, copy, readonly) NSString *identifier;

/// 协议代理
@property(nonatomic, weak) id <SSWebModuleDelegate> moduleDelegate;

/// bridge
@property(nonatomic, weak) WKWebViewJavascriptBridge *bridge;

/// WKWebVeiw
@property(nonatomic, weak) WKWebView *webView;

/// 注册jshandle，支持自定义
/// @param handlerName api
/// @param handler 回调
- (void)baseRegisterHandler:(NSString *)handlerName handler:(SSBridgeJsHandler)handler;

/// 本身完成不了jshandle，需要使用者完成
- (void)baseInvokeJsHandler:(NSString *)api data:(id)data callBack:(SSBridgeJsCallback)callBack;

- (void)basePushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)basePresentViewController:(UIViewController *)viewControllerToPresent
                         animated:(BOOL)flag
                       completion:(BlockVoid)completion;

@end

NS_ASSUME_NONNULL_END
