//
//  SSHelpWebPhotoModule.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/4/7.
//  源生:拍照或者获取相册图片
//

#import "SSHelpWebBaseModule.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpWebPhotoModule : SSHelpWebBaseModule

+ (id)sharedInstance;

- (void)evaluateJsHandler:(SSHelpWebObjcHandler *)handler;

@end

NS_ASSUME_NONNULL_END
