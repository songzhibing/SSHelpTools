//
//  SSHelpWebObjcJsHandler.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSBridgeJsCallback)(id responseData);
typedef void (^SSBridgeJsHandler)(NSString *api, id data, SSBridgeJsCallback callback);

@interface SSHelpWebObjcJsHandler : NSObject

/// 接口pai
@property(nonatomic, copy) NSString *api;

/// Js入参
@property(nonatomic, strong) id data;

/// Js回调
@property(nonatomic, strong) SSBridgeJsCallback callback;

/// 快速构建对象
+ (instancetype )handlerWithData:(id)data callBack:(SSBridgeJsCallback)block;

@end

NS_ASSUME_NONNULL_END
