//
//  SSHelpBarButtonItem.h
//  Pods
//
//  Created by 宋直兵 on 2023/8/10.
//

#import <UIKit/UIKit.h>
#import "SSHelpButton.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpBarButtonItem : UIBarButtonItem

+ (instancetype)ss_sapce;

+ (instancetype)ss_fixedSapce:(CGFloat)width;


+ (instancetype)ss_customButton;

@property(nonatomic, weak, nullable) SSHelpButton *customButton;

@end

NS_ASSUME_NONNULL_END
