//
//  SSHelpPhotoManager.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^SSAccessPhotoCompletion)(UIImage * _Nullable image);

@interface SSHelpPhotoManager : NSObject

/// 是否有相机权限
/// @param completion 回调
+ (void)enableAccessCamera:(void(^)(BOOL enable))completion;

/// 是否有相册权限
/// @param completion 回调
+ (void)enableAccessPhotoAlbum:(void(^)(BOOL enable))completion;

/// 保存图片到相册
/// @param image 图片
/// @param completionHandler 回调
+ (void)saveImage:(UIImage *)image completionHandler:(void(^)(BOOL success, NSError *_Nullable error))completionHandler;

/// 拍照/从相册选择一张照片
/// @param completion 回调
/// @param controller 视图控制器
+ (void)toAccessCameraOrPhoto:(void(^)(UIImage * _Nullable image))completion presentingViewController:(UIViewController *)controller;

/// 用相机拍照
/// @param completion 回调
+ (void)toAccessCamera:(void(^)(UIImage *_Nullable image))completion presentingViewController:(UIViewController *)controller;

/// 从相册选择一张照片
/// @param completion 回调
+ (void)toAccessPhotoLibrary:(void(^)(UIImage *_Nullable image))completion presentingViewController:(UIViewController *)controller;

/// 从相册选择多张图片
/// @param completion 回调
/// @param max 多选最大值
+ (void)toAccessPhotoLibrary:(void(^)(NSArray<UIImage *> *photos))completion maxCount:(NSInteger)max presentingViewController:(UIViewController *)controller;

@end

NS_ASSUME_NONNULL_END
