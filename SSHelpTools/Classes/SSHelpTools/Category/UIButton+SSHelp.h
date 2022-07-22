//
//  UIButton+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (SSHelp)

/// 添加UIControlEventTouchUpInside事件回调
- (void)ss_addTouchUpInsideBlock:(void (^)(id sender))block;

/// 移除UIControlEventTouchUpInside事件回调
- (void)ss_removeTouchUpInsideBlock;

/// 添加*事件回调
- (void)ss_addControlEvents:(UIControlEvents)event block:(void (^)(id sender))block;

/// 移除*事件回调
- (void)ss_removeAllBlocksForControlEvents:(UIControlEvents)event;

@end

NS_ASSUME_NONNULL_END
