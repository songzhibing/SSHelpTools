//
//  SSHelpImagePickerController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/16.
//

#import "SSHelpImagePickerController.h"
#import "SSHelpPhotoManager.h"
#import "SSHelpDefines.h"

#import <PhotosUI/PhotosUI.h>
#import <objc/runtime.h>
#import <MobileCoreServices/MobileCoreServices.h>

API_AVAILABLE_BEGIN(ios(14))

@interface PHPickerViewController (SSHelp) <PHPickerViewControllerDelegate>

@property(nonatomic, copy) void(^completion)(NSArray <UIImage *> *images);

@end

@implementation PHPickerViewController (SSHelp)

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ...",self);
}

- (void (^)(NSArray<UIImage *> *))completion
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCompletion:(void (^)(NSArray<UIImage *> *))completion
{
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

/// Called when the user completes a selection or dismisses \c PHPickerViewController using the cancel button.
/// @discussion The picker won't be automatically dismissed when this method is called.
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results
{
    __block NSMutableArray <UIImage *> *__selectedImages = [[NSMutableArray alloc] initWithCapacity:results.count];
    [results enumerateObjectsUsingBlock:^(PHPickerResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSItemProvider *itemPro = obj.itemProvider;
        if ([itemPro canLoadObjectOfClass:[UIImage class]]) {
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [itemPro loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) { //异步
                if (object) {
                    [__selectedImages addObject:object];
                }
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        }
    }];
    @Tweakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            @Tstrongify(self);
            if (self.completion) {
                self.completion(__selectedImages);
            }
        }];
    });
}

@end

API_AVAILABLE_END




@interface SSHelpImagePickerController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic, copy) void(^completion)(UIImage *image);

@property(nonatomic, copy) void(^recordCompletion)(NSURL *url);

@end

@implementation SSHelpImagePickerController

#pragma mark - Public Method

/// 拍照
/// @param completion 回调
/// @param controller 视图控制器
+ (void)takePhoto:(void(^)(UIImage *_Nullable image))completion
  presentingViewController:(__kindof UIViewController *)controller
{
    [SSHelpPhotoManager enableAccessCamera:^(BOOL enable) {
        if (enable) {
            SSHelpImagePickerController *pickerController = [[SSHelpImagePickerController alloc]init];
            pickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.allowsEditing = YES;
            pickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
            pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            pickerController.completion = [completion copy];
            [controller presentViewController:pickerController animated:YES completion:nil];
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

/// 从相册选择
/// @param completion 回调
+ (void)selectPhoto:(void(^)(UIImage *_Nullable image))completion presentingViewController:(__kindof UIViewController *)controller
{
    if (@available(iOS 14, *)) {
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
        configuration.selectionLimit = 1;
        configuration.filter = [PHPickerFilter imagesFilter];
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        picker.delegate = picker;
        picker.completion = ^(NSArray<UIImage *> *images) {
            if (completion) {
                completion(images.firstObject);
            }
        };
        [controller presentViewController:picker animated:YES completion:nil];
        return;
    }
    
    [SSHelpPhotoManager enableAccessPhotoAlbum:^(BOOL enable) {
        if (enable) {
            SSHelpImagePickerController *pickerController = [[SSHelpImagePickerController alloc]init];
            pickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            pickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            pickerController.allowsEditing = YES;
            pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            pickerController.completion = [completion copy];
            [controller presentViewController:pickerController animated:YES completion:nil];
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

/// 从相册选择多张图片 （iOS14开始支持）
/// @param completion 回调
+ (void)selectPhoto:(void(^)(NSArray <UIImage *> *_Nullable images))completion selectionLimit:(NSInteger)limit presentingViewController:(__kindof UIViewController *)controller
{
    if (@available(iOS 14, *)) {
        PHPickerConfiguration *configuration = [[PHPickerConfiguration alloc] initWithPhotoLibrary:[PHPhotoLibrary sharedPhotoLibrary]];
        configuration.selectionLimit = limit;
        configuration.filter = [PHPickerFilter imagesFilter];
        PHPickerViewController *picker = [[PHPickerViewController alloc] initWithConfiguration:configuration];
        picker.delegate = picker;
        picker.completion = [completion copy];
        [controller presentViewController:picker animated:YES completion:nil];
    } else {
        if (completion) {
            completion(nil);
        }
    }
}

/// 用相机录制视频 默认录制最大时长30秒
/// @param completion 回调
+ (void)recordVideo:(void(^)(NSURL *_Nullable url))completion videoMaximumDuration:(NSTimeInterval)duration presentingViewController:(UIViewController *)controller
{
    [SSHelpPhotoManager enableAccessCamera:^(BOOL enable) {
        if (enable) {
            SSHelpImagePickerController *pickerController = [[SSHelpImagePickerController alloc]init];
            pickerController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            pickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            pickerController.allowsEditing = YES;
            pickerController.mediaTypes =  [[NSArray alloc] initWithObjects:(NSString*)kUTTypeMovie,nil];
            pickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            pickerController.videoMaximumDuration = (duration<=0)?30:duration;
            pickerController.recordCompletion  = [completion copy];
            [controller presentViewController:pickerController animated:YES completion:nil];
        } else {
            if (completion) {
                completion(nil);
            }
        }
    }];
}

#pragma mark - Private Method

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

#pragma mark - UIImagePickerControllerDelegate Method

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info
{
    __block UIImage *_photo = nil;
    __block NSURL *_videoUrl = nil;
    
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        _photo = info[UIImagePickerControllerEditedImage];
        if (!_photo) {
            _photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    } else if ([type isEqualToString:@"public.movie"]) {
        _videoUrl = [info objectForKey:UIImagePickerControllerMediaURL];

    }
    
    
    @Tweakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @Tstrongify(self);
        if (self.completion) {
            self.completion(_photo);
        }
        if (self.recordCompletion) {
            self.recordCompletion(_videoUrl);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    @Tweakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @Tstrongify(self);
        if (self.completion) {
            self.completion(nil);
        }
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
