//
//  SSHelpWebCallCenterModule.m
//  SSHelpWebView
//
//  Created by 宋直兵 on 2022/3/7.
//

#import "SSHelpWebCallCenterModule.h"

@implementation SSHelpWebCallCenterModule

- (void)moduleRegisterJsHandler
{
    [self baseRegisterHandler:kWebApiTelNumber handler:^(NSString * _Nonnull api, id  _Nonnull data, SSBridgeJsCallback  _Nonnull callback) {
        NSString *telNum = SSEncodeStringFromDict(data, @"telNum");
        [SSHelpWebCallCenterModule telPhoneNumber:telNum completionHandler:^(BOOL success) {
            if (success) {
                callback([SSHelpWebObjcResponse successWithData:nil]);
            }else{
                callback([SSHelpWebObjcResponse failedWithError:nil]);
            }
        }];
    }];
}

/// 拨打电话
/// @param phoneNumber 电话号码
/// @param completion 回调
+ (void)telPhoneNumber:(NSString *)phoneNumber completionHandler:(void (^ __nullable)(BOOL success))completion
{
    if (phoneNumber && [phoneNumber isKindOfClass:[NSString class]]) {
        NSURL *telUrl = [NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",phoneNumber]];
        [[UIApplication sharedApplication] openURL:telUrl options:@{} completionHandler:completion];
    }else{
        if (completion) {
            completion(NO);
        }
    }
}

@end
