//
//  UIView+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/20.
//

#import <UIKit/UIKit.h>
#import "UIResponder+SSHelp.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (SSHelp)

@property(nonatomic, assign, readwrite) CGFloat ss_originX;

@property(nonatomic, assign, readwrite) CGFloat ss_originY;

@property(nonatomic, assign, readonly ) CGFloat ss_width;

@property(nonatomic, assign, readonly ) CGFloat ss_height;

@property(nonatomic, assign, readonly ) CGFloat ss_frameBottom;

@property(nonatomic, assign, readonly ) CGFloat ss_frameRight;

@end

NS_ASSUME_NONNULL_END
