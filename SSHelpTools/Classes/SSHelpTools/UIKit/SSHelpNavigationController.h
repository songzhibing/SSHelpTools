//
//  SSHelpNavigationController.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/4/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpNavigationController : UINavigationController

/// 是否关闭侧滑返回, By default NO.
@property(nonatomic, assign) BOOL interactivePopGestureRecognizerDisable;

@end

NS_ASSUME_NONNULL_END
