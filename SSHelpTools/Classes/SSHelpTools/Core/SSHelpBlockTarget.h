//
//  SSHelpBlockTarget.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/14.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpBlockTarget : NSObject

@property(nonatomic, copy, readonly) void (^block)(id sender);

@property(nonatomic, assign, readonly) UIControlEvents event;


- (id)initWithBlock:(void (^)(id sender))block events:(UIControlEvents)event;

- (id)initWithBlock:(void (^)(id sender))block;

- (void)invoke:(id)sender;

@end

NS_ASSUME_NONNULL_END
