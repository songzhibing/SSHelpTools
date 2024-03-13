//
//  SSHelpWebObjcHandler.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/10.
//

#import "SSHelpWebObjcHandler.h"

@implementation SSHelpWebObjcHandler

/// 快速构建对象
+ (instancetype )handlerWithData:(id)data callBack:(SSBridgeCallback)block;
{
    SSHelpWebObjcHandler *jsHandler = [[SSHelpWebObjcHandler alloc] init];
    jsHandler.data = data;
    jsHandler.callback = [block copy];
    return jsHandler;
}

+ (instancetype )handlerWithApi:(NSString *)api data:(id)data callBack:(SSBridgeCallback)block
{
    SSHelpWebObjcHandler *handler = [[SSHelpWebObjcHandler alloc] init];
    handler.api = api;
    handler.data = data;
    handler.callback = [block copy];
    return handler;
}
@end
