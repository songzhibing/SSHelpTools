//
//  SSHelpQLPreviewController.h
//  Pods
//
//  Created by 宋直兵 on 2023/7/24.
//

#import <UIKit/UIKit.h>
#import <QuickLook/QuickLook.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpQLPreviewController : QLPreviewController

+ (instancetype)ss_new;

@property(nonatomic, strong) NSURL *fileURL;

@end

NS_ASSUME_NONNULL_END
