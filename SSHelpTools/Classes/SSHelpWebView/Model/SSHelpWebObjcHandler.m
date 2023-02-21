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
@end
