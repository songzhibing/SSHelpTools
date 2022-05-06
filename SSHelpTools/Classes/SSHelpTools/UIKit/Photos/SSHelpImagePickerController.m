//
//  SSHelpImagePickerController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/16.
//

#import "SSHelpImagePickerController.h"
#import "SSHelpPhotoManager.h"
#import "SSHelpDefines.h"

@interface SSHelpImagePickerController ()<UINavigationControllerDelegate,
UIImagePickerControllerDelegate>

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
    SSToolsLog(@"%@ dealloc ... ",self);
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
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self_weak_.completion) {
            self_weak_.completion(_photo);
        }
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    @weakify(self);
    [picker dismissViewControllerAnimated:YES completion:^{
        if (self_weak_.completion) {
            self_weak_.completion(nil);
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
