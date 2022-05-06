//
//  SSHelpWebObjcJsHandler.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/10.
//

#import "SSHelpWebObjcJsHandler.h"

@implementation SSHelpWebObjcJsHandler

/// 快速构建对象
+ (instancetype )handlerWithData:(id)data callBack:(SSBridgeJsCallback)block;
{
    SSHelpWebObjcJsHandler *jsHandler = [[SSHelpWebObjcJsHandler alloc] init];
    jsHandler.data = data;
    jsHandler.callback = [block copy];
    return jsHandler;
}
@end
