//
//  SSHelpWebCallCenterModule.h
//  SSHelpWebView
//
//  Created by 宋直兵 on 2022/3/7.
//  源生:拨打电话
//

#import "SSHelpWebBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpWebCallCenterModule : SSHelpWebBaseModule

/// 拨打电话
/// @param phoneNumber 电话号码
/// @param completion 回调
+ (void)telPhoneNumber:(NSString *)phoneNumber completionHandler:(void (^ __nullable)(BOOL success))completion;

@end

NS_ASSUME_NONNULL_END
