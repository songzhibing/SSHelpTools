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

API_AVAILABLE_BEGIN(ios(14))

@interface PHPickerViewController (SSHelp) <PHPickerViewControllerDelegate>

@property(nonatomic, copy) void(^completion)(UIImage *image);

@end

@implementation PHPickerViewController (SSHelp)

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ...",self);
}

- (void (^)(UIImage *))completion
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setCompletion:(void (^)(UIImage *))completion
{
    objc_setAssociatedObject(self, @selector(completion), completion, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

///// Called when the user completes a selection or dismisses \c PHPickerViewController using the cancel button.
///// @discussion The picker won't be automatically dismissed when this method is called.
- (void)picker:(PHPickerViewController *)picker didFinishPicking:(NSArray<PHPickerResult *> *)results
{
    @Tweakify(self);
    __block UIImage *__selectedImage = nil;
    
    void (^__callback)(void) = ^(void){
        dispatch_main_async_safe(^{
            [self dismissViewControllerAnimated:YES completion:^{
                @Tstrongify(self);
                if (self.completion) {
                    self.completion(__selectedImage);
                }
            }];
        });
    };
    
    //取出PHPickerResult对象,PHPickerResult类公开itemProvider和assetIdentifier属性，其中itemProvider⽤
    //来获取资源⽂件的数据或对象，assetIdentifier⽂档⾥只做了属性说明就是⽂件的⼀个本地唯⼀ID，苹果官⽅操作指南也
    //没有提到这个属性⽤法，只是对assetIdentifier做了⼀下简单的本地缓存和过滤操作（是否选择同⼀个⽂件）
    if (results) {
        NSItemProvider *itemPro = results.firstObject.itemProvider;
        if ([itemPro canLoadObjectOfClass:[UIImage class]]) {
            [itemPro loadObjectOfClass:[UIImage class] completionHandler:^(__kindof id<NSItemProviderReading>  _Nullable object, NSError * _Nullable error) { //异步
                //返回的object属于PHLivePhoto对象，如果load的类是UIImage这⾥的object返回UIImage类
                //处理PHLivePhoto对象
                __selectedImage = object;
                __callback();
            }];
            return;
        }
    }
    __callback();
}

@end

API_AVAILABLE_END




@interface SSHelpImagePickerController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate>

@property(nonatomic, copy) void(^completion)(UIImage *image);

@property(nonatomic, assign) BOOL navBarHidden;

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
        }else{
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
        picker.completion = [completion copy];
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
        }else{
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
    UIImage *_photo = nil;
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    if ([type isEqualToString:@"public.image"]) {
        _photo = info[UIImagePickerControllerEditedImage];
        if (!_photo) {
            _photo = [info objectForKey:UIImagePickerControllerOriginalImage];
        }
    } else if ([type isEqualToString:@"public.movie"]) {
    }
    @Tweakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        @Tstrongify(self);
        if (self.completion) {
            self.completion(_photo);
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
