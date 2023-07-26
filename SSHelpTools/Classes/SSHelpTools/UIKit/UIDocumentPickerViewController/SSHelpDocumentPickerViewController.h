//
//  SSHelpDocumentPickerViewController.h
//  Pods
//
//  Created by 宋直兵 on 2023/7/20.
//

#import <UIKit/UIKit.h>
#import "SSHelpDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpDocumentPickerViewController : UIDocumentPickerViewController

+ (instancetype)ss_new;

@property(nonatomic, strong) SSBlockArray callback;

@end

NS_ASSUME_NONNULL_END
