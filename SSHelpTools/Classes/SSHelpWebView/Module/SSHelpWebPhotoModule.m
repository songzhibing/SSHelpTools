//
//  SSHelpWebPhotoModule.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/4/7.
//

#import "SSHelpWebPhotoModule.h"

@implementation SSHelpWebPhotoModule

+ (id)sharedInstance
{
    static SSHelpWebPhotoModule *photoModule;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        photoModule = [[SSHelpWebPhotoModule alloc] init];
    });
    return photoModule;
}

+ (nullable NSArray <NSString *> *)suppertJsNames;
{
    return @[kWebApiTakePhoto];
}

- (void)evaluateJsHandler:(SSHelpWebObjcHandler *)handler
{
    if ([handler.api isEqualToString:kWebApiTakePhoto]) {
        [SSHelpPhotoManager toAccessCameraOrPhoto:^(UIImage * _Nullable image) {
            SSHelpWebObjcResponse *response = [[SSHelpWebObjcResponse alloc] init];
            if (image) {
                NSData *imageData = nil;
                NSString *mimeType = nil;
                  if ([SSHelpWebPhotoModule imageHasAlpha:image]) {
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
            handler.callback(response);
        } presentingViewController:self.webView.ss_viewController];
    }
}

+ (BOOL)imageHasAlpha:(UIImage *)image
{
    CGImageAlphaInfo alpha = CGImageGetAlphaInfo(image.CGImage);
    return (alpha == kCGImageAlphaFirst ||
            alpha == kCGImageAlphaLast ||
            alpha == kCGImageAlphaPremultipliedFirst ||
            alpha == kCGImageAlphaPremultipliedLast);
}

@end
