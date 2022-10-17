//
//  UIBarButtonItem+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIBarButtonItem (SSHelp)

@property(nonatomic, strong) void(^gc_actionBlock)(id sender);

@end

NS_ASSUME_NONNULL_END
