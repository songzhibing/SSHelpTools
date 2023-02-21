//
//  SSHelpWebTestJsBridgeModule.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebTestBridgeModule.h"

@implementation SSHelpWebTestBridgeModule

- (void)moduleRegisterJsHandler
{
    [self baseRegisterHandler:kWebApiTestJSBridge handler:^(NSString * _Nonnull api, id  _Nonnull data, SSBridgeCallback  _Nonnull callback) {
        callback([SSHelpWebObjcResponse successWithData:nil]);
    }];
}

@end
