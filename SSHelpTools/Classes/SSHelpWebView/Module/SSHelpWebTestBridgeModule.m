//
//  SSHelpWebTestJsBridgeModule.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebTestBridgeModule.h"

@implementation SSHelpWebTestBridgeModule

+ (NSArray<NSString *> *)suppertJsNames
{
    return @[kWebApiTestJSBridge];
}

- (void)evaluateJsHandler:(SSHelpWebObjcHandler *)handler
{
    if ([handler.api isEqualToString:kWebApiTestJSBridge]) {
        handler.callback([SSHelpWebObjcResponse successWithData:nil]);
    }
}

@end
