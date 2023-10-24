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
#import "SSHelpWebObjcHandler.h"
#import "SSHelpWebObjcResponse.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpWebModuleProtocol <NSObject>

@optional

/// 是否单例
+ (id)sharedInstance;

/// 支持的js方法名
+ (nullable NSArray <NSString *> *)suppertJsNames;

/// 调用模块js功能
- (void)evaluateJsHandler:(SSHelpWebObjcHandler *)handler;

@end


@interface SSHelpWebBaseModule : NSObject <SSHelpWebModuleProtocol>

/// 模块标识符，模块初始化时自动生成
@property(nonatomic, copy, readonly) NSString *identifier;

/// bridge
@property(nonatomic, weak) WKWebViewJavascriptBridge *bridge;

/// WKWebVeiw
@property(nonatomic, weak) __kindof WKWebView *webView;

- (void)basePushViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)basePresentViewController:(UIViewController *)viewController animated:(BOOL)flag completion:(SSBlockVoid)completion;

@end

NS_ASSUME_NONNULL_END
