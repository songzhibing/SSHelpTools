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

/// 从相册选择多张图片
/// @param completion 回调
+ (void)selectPhoto:(void(^)(NSArray <UIImage *> *_Nullable images))completion selectionLimit:(NSInteger)limit presentingViewController:(__kindof UIViewController *)controller API_AVAILABLE(ios(14));

/// 用相机录制视频 默认录制最大时长30秒
/// @param completion 回调
+ (void)recordVideo:(void(^)(NSURL *_Nullable url))completion videoMaximumDuration:(NSTimeInterval)duration presentingViewController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
