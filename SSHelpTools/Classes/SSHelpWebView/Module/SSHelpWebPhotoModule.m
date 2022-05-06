//
//  SSHelpWebPhotoModule.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/4/7.
//

#import "SSHelpWebPhotoModule.h"
#import "SSHelpPhotoManager.h"

@implementation SSHelpWebPhotoModule

- (void)moduleRegisterJsHandler
{
    @weakify(self);
    [self baseRegisterHandler:kWebApiTakePhoto handler:^(NSString * _Nonnull api, id  _Nonnull data, SSBridgeJsCallback  _Nonnull callback) {
        [SSHelpPhotoManager toAccessCameraOrPhoto:^(UIImage * _Nullable image) {
            SSHelpWebObjcResponse *response = [[SSHelpWebObjcResponse alloc] init];
            if (image) {
                NSData *imageData = nil;
                NSString *mimeType = nil;
                  if ([self imageHasAlpha: image]) {
                      imageData = UIImagePNGRepresentation(image);
                      mimeType =  @"PNG";
                  } else {
                      imageData = UIImageJPEGRepresentation(image, 1.0);
                      mimeType = @"JPEG";
                  }
                response.data = @{@"base64":imageData.ss_base64EncodedString?:@"",
                                  @"mimeType":mimeType.lowercaseString};
                response.code = 1;
            }else{
                response.code = 0;
            }
            callback(response);
        } presentingViewController:self_weak_.webView.ss_viewController];
    }];
}

- (BOOL) imageHasAlpha: (UIImage *) image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

@end
