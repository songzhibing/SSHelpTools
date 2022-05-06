//
//  SSHelpWebTestJsBridgeModule.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebTestJsBridgeModule.h"

@implementation SSHelpWebTestJsBridgeModule

- (void)moduleRegisterJsHandler
{
    [self baseRegisterHandler:kWebApiTestObjcCallback handler:^(NSString * _Nonnull api, id  _Nonnull data, SSBridgeJsCallback  _Nonnull callback) {
        SSWebLog(@"testObjcCallback called: %@", data);
        callback(@"Response from testObjcCallback Objective-C ... ");
    }];
}

@end
