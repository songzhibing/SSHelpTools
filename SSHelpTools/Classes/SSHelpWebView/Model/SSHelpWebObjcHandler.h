//
//  SSHelpWebObjcHandler.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/10.
//  

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SSBridgeCallback)(id responseData);

typedef void (^SSBridgeHandler)(NSString *api, id data, SSBridgeCallback callback);


@interface SSHelpWebObjcHandler : NSObject

/// js接口名称
@property(nonatomic, copy  ) NSString *api;

/// js接口入参
@property(nonatomic, strong) id data;

/// js接口回调
@property(nonatomic, strong) SSBridgeCallback callback;

/// 快速构建对象
+ (instancetype )handlerWithData:(id)data callBack:(SSBridgeCallback)block;

+ (instancetype )handlerWithApi:(NSString *)api data:(id)data callBack:(SSBridgeCallback)block;

@end

NS_ASSUME_NONNULL_END
