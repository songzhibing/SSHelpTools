//
//  SSHelpImagePickerController.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpImagePickerController : UIImagePickerController

/// 拍照
/// @param completion 回调
+ (void)takePhoto:(void(^)(UIImage *_Nullable image))completion presentingViewController:(__kindof UIViewController *)controller;

/// 从相册选择
/// @param completion 回调
+ (void)selectPhoto:(void(^)(UIImage *_Nullable image))completion presentingViewController:(__kindof UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
