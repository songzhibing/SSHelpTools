//
//  UIButton+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (SSHelp)

/**
 添加 UIControlEventTouchUpInside 事件回调
 */
- (void)ss_addTouchUpInsideBlock:(void (^)(id sender))block;

/**
 移除 UIControlEventTouchUpInside 事件回调
 */
- (void)ss_removeTouchUpInsideBlock;

/**
 添加指定事件回调
 */
- (void)ss_addBlockForControlEvents:(UIControlEvents)controlEvents
                              block:(void (^)(id sender))block;

/**
 移除指定事件回调
 */
- (void)ss_removeAllBlocksForControlEvents:(UIControlEvents)controlEvents;

@end

NS_ASSUME_NONNULL_END
