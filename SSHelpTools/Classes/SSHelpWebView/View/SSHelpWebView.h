//
//  SSHelpWebView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/30.
//

#import <WebKit/WebKit.h>
#import "SSHelpWebBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^_Nullable SSWebViewConfigBlock)(WKWebViewConfiguration *_Nonnull configuration);


@interface SSHelpWebView : WKWebView

+ (instancetype)defauleWebView;

+ (instancetype)defauleWebViewWithFrame:(CGRect)frame configuration:(SSWebViewConfigBlock)block;

@property(nonatomic, assign) BOOL logEnable;

/// js接口功能模块代理
@property(nonatomic, weak) id <SSWebModuleDelegate> moduleDelegate;

/// 是否支持自定义长按手势识别:识别web中二维码、看图模式、.... ，默认no
@property(nonatomic, assign) BOOL supportLongPressGestureRecognizer;

/// 非模块化接口注册
/// @param handlerName 方法名称
/// @param handler 回调
- (void)registerHandler:(NSString *)handlerName handler:(SSBridgeJsHandler)handler;

/// 模块化接口初始化
- (BOOL)registerJsHandlerImpClass:(Class)moduleClass;

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion;

@end

NS_ASSUME_NONNULL_END
