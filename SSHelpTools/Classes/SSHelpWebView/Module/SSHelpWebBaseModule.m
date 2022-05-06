//
//  SSHelpWebBaseModule.m
//  SSHelpWebView
//
//  Created by 宋直兵 on 2022/1/10.
//

#import "SSHelpWebBaseModule.h"

@implementation SSHelpWebBaseModule

- (void)dealloc
{
    _webView = nil;
    _moduleDelegate = nil;
    SSWebLog(@"%@ dealloc ......",self);
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *className = NSStringFromClass([self class]);
        _identifier = className;
        SSWebLog(@"%@ alloc init ......",self);
    }
    return self;
}

- (NSString *)p_hookJsName:(NSString *)api
{
    NSString *newApi  = nil;
    if (_moduleDelegate && [_moduleDelegate respondsToSelector:@selector(webModule:hookJsName:)]) {
        newApi = [_moduleDelegate webModule:self.identifier hookJsName:api];
    }
    return newApi?:api;
}

- (void)p_hookJsHandler:(SSHelpWebObjcJsHandler *)jsHandler moduleHandler:(SSBridgeJsHandler)moduleHandler
{
    if (_moduleDelegate && [_moduleDelegate respondsToSelector:@selector(webModule:hookJsHandler:moduleHandler:)]) {
        [_moduleDelegate webModule:self.identifier hookJsHandler:jsHandler moduleHandler:moduleHandler];
    }else{
        if (moduleHandler){
            moduleHandler(jsHandler.api,jsHandler.data,jsHandler.callback);
        }
    }
}

#pragma mark - ZWWebModuleProtocol Method

- (void)moduleRegisterJsHandler
{
    //子类继承
}

#pragma mark - Public Method

/// 注册jshandle，支持自定义
/// @param handlerName api
/// @param handler 回调
- (void)baseRegisterHandler:(NSString *)handlerName handler:(SSBridgeJsHandler)handler
{
    @weakify(self);
    //是否被自定义
    NSString *newApi = [self p_hookJsName:handlerName];
    [self.bridge registerHandler:newApi handler:^(id data, WVJBResponseCallback responseCallback) {
        /// 根据返回数据类型进行转换【建议统一返回对象】
        void (^_nonullCallBack)(id response) = ^(id response){
            if (responseCallback && response) {
                if ([response isKindOfClass:[SSHelpWebObjcResponse class]]) {
                    SSHelpWebObjcResponse *objcResponse = (SSHelpWebObjcResponse *)response;
                    responseCallback(objcResponse.finalJsonString);
                }else if([response isKindOfClass:[NSDictionary class]]){
                    NSString *jsonString = ((NSDictionary *)response).ss_jsonStringEncoded;
                    responseCallback(jsonString);
                }else if([response isKindOfClass:[NSArray class]]){
                    NSString *jsonString = ((NSArray *)response).ss_jsonStringEncoded;
                    responseCallback(jsonString);
                }else if([response isKindOfClass:[NSString class]]){
                    NSString *jsonString = response;
                    responseCallback(jsonString);
                }
            }
        };
        /// 框架参数字段为params
        /*
        NSMutableDictionary *params = data;
        if (data && [data isKindOfClass:[NSDictionary class]]) {
            NSString *jsonString = SSEncodeStringFromDict(data, @"params");
            params = jsonString.ss_toDictionary.mutableCopy;
        }
        */
        /// 转成OC对象
        SSHelpWebObjcJsHandler *jshandler = nil;
        jshandler = [SSHelpWebObjcJsHandler handlerWithData:data callBack:_nonullCallBack];
        jshandler.api = newApi;
        /// 是否被自定义
        [self_weak_ p_hookJsHandler:jshandler moduleHandler:handler];
    }];
}


/// 本身完成不了jshandle，需要使用者完成
- (void)baseInvokeJsHandler:(NSString *)api
                       data:(id)data
                   callBack:(SSBridgeJsCallback)callBack
{
    /// 转成OC对象
    SSHelpWebObjcJsHandler *jshandler = nil;
    jshandler = [SSHelpWebObjcJsHandler handlerWithData:data callBack:callBack];
    jshandler.api = api;
    
    /// 代理
    if (_moduleDelegate && [_moduleDelegate respondsToSelector:@selector(webModule:invokeJsHandler:)]) {
        [_moduleDelegate webModule:self.identifier invokeJsHandler:jshandler];
    }else{
        callBack([SSHelpWebObjcResponse failedWithError:@"未实现该功能"]);
    }
}

- (void)basePushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    dispatch_main_async_safe(^{
        if (self.webView.ss_viewController && self.webView.ss_viewController.navigationController) {
            [self.webView.ss_viewController.navigationController pushViewController:viewController animated:animated];
        }
    });
}

- (void)basePresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion
{
    dispatch_main_async_safe(^{
        if (self.webView.ss_viewController) {
            [self.webView.ss_viewController presentViewController:viewControllerToPresent animated:flag completion:completion];
        }
    });
}

@end
