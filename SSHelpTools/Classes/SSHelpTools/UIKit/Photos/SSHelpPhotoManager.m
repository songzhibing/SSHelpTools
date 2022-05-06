//
//  SSHelpPhotoManager.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/19.
//

#import <AVFoundation/AVCaptureDevice.h>
#import <AVFoundation/AVMediaFormat.h>
#import <Photos/PHPhotoLibrary.h>
#import <Photos/Photos.h>

#import "SSHelpPhotoManager.h"
#import "SSHelpDefines.h"
#import "SSHelpImagePickerController.h"

@implementation SSHelpPhotoManager

/// 是否有相机权限
/// @param completion 回调
+ (void)enableAccessCamera:(void(^)(BOOL enable))completion
{
    NSString *authorization = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSCameraUsageDescription"];
    NSAssert(authorization!=nil, @"To use camera services in app , your Info.plist must provide a value for NSCameraUsageDescription.");
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo
                             completionHandler:^(BOOL granted) {//相机权限
        if (completion){
            dispatch_main_async_safe(^{
                completion(granted);
            });
        }
    }];
}

/// 是否有相册权限
/// @param completion 回调
+ (void)enableAccessPhotoAlbum:(void(^)(BOOL enable))completion
{
    NSString *authorization = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSPhotoLibraryUsageDescription"];
    NSAssert(authorization!=nil, @"To use photo services in app , your Info.plist must provide a value for NSPhotoLibraryUsageDescription.");
    if (@available(iOS 14.0, *)) {
        // 请求权限
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly handler:^(PHAuthorizationStatus status) {
            dispatch_main_async_safe(^{
                BOOL _enable = NO;
                switch (status) {
                    case PHAuthorizationStatusLimited: //用户选择Limited模式，限制App访问有限的相册资源
                        _enable = YES;
                        break;
                    case PHAuthorizationStatusDenied:
                        _enable = NO;
                        break;
                    case PHAuthorizationStatusAuthorized:
                        _enable = YES;
                        break;
                    default:
                        break;
                }
                if (completion) {
                    completion(_enable);
                }
            });
        }];
    }else{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_main_async_safe(^{
                if (PHAuthorizationStatusAuthorized == status) {
                    //已获取权限
                    if (completion) {
                        completion(YES);
                    }
                }else if (PHAuthorizationStatusAuthorized == status) {
                    //明确否认了这一照片数据的应用程序访问
                    if (completion) {
                        completion(NO);
                    }
                }else{
                    if (completion) {
                        completion(NO);
                    }
                }
            });
        }];
    }
}

/// 拍照/从相册选择一张照片
/// @param completion 回调
/// @param controller 视图控制器
+ (void)toAccessCameraOrPhoto:(void(^)(UIImage * _Nullable image))completion presentingViewController:(UIViewController *)controller
{
    if (!controller) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    UIAlertController *_alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *camera = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SSHelpPhotoManager toAccessCamera:^(UIImage * _Nullable image) {
            if (completion) {
                completion(image);
            }
        } presentingViewController:controller];
    }];
    
    UIAlertAction *photoLibrary = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SSHelpPhotoManager toAccessPhotoLibrary:^(UIImage * _Nullable image) {
            if (completion) {
                completion(image);
            }
        } presentingViewController:controller];
    }];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        if (completion) {
            completion(nil);
        }
    }];
    [_alert addAction:camera];
    [_alert addAction:photoLibrary];
    [_alert addAction:cancel];
    [controller presentViewController:_alert animated:YES completion:nil];
}


/// 用相机拍照
/// @param completion 回调
+ (void)toAccessCamera:(void(^)(UIImage *_Nullable image))completion presentingViewController:(UIViewController *)controller
{
    if (!controller) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [SSHelpPhotoManager enableAccessCamera:^(BOOL enable) {
        if (enable) {
            [SSHelpImagePickerController takePhoto:^(UIImage * _Nonnull image) {
                if (completion) {
                   completion(image);
                }
            } presentingViewController:controller];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"无法访问您的相机,请至设置中开启." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (completion) {
                    completion(nil);
                }
            }];
            UIAlertAction *toset = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if (completion) {
                    completion(nil);
                }
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
            }];
            [alert addAction:toset];
            [alert addAction:cancel];
            [controller presentViewController:alert animated:YES completion:nil];
        }
    }];
}

/// 从相册选中图片
/// @param completion 回调
+ (void)toAccessPhotoLibrary:(void(^)(UIImage *_Nullable image))completion presentingViewController:(UIViewController *)controller
{
    [SSHelpPhotoManager toAccessPhotoLibrary:^(NSArray<UIImage *> * _Nonnull photos) {
        if (completion) {
            completion(photos.firstObject);
        }
    } maxCount:1 presentingViewController:controller];
}


/// 从相册选中多张图片
/// @param completion 回调
/// @param max 多选最大值
+ (void)toAccessPhotoLibrary:(void(^)(NSArray<UIImage *> *photos))completion maxCount:(NSInteger)max presentingViewController:(UIViewController *)controller
{
    if (max<=0) {
        max = 1;
    }
    
    if (!controller) {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [SSHelpPhotoManager enableAccessPhotoAlbum:^(BOOL enable) {
        if (enable) {
            
            [SSHelpImagePickerController selectPhoto:^(UIImage * _Nullable image) {
                if (completion) {
                    completion(image?@[image]:nil);
                }
            } presentingViewController:controller];
        }else{
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:@"无法访问您的相册,请至设置中开启." preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                if (completion) {
                    completion(nil);
                }
            }];
            UIAlertAction *toset = [UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                
                if (completion) {
                    completion(nil);
                }
                
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];

            }];
            [alert addAction:toset];
            [alert addAction:cancel];
            [controller presentViewController:alert animated:YES completion:nil];
        }
    }];
}

/// 保存图片到相册
/// @param image 图片
/// @param completionHandler 回调
+ (void)saveImage:(UIImage *)image completionHandler:(void(^)(BOOL success, NSError *_Nullable error))completionHandler
{
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
         //写入图片到相册
         [PHAssetChangeRequest creationRequestForAssetFromImage:image];
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
         completionHandler ? completionHandler(success, error) : NULL;
    }];
}

@end
