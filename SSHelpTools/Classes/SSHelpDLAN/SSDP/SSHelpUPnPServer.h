//
//  SSHelpUPnPServer.h
//  Pods
//
//  Created by 宋直兵 on 2023/12/20.
//

#import <Foundation/Foundation.h>
#import "SSHelpUPnPDevice.h"
@class SSHelpUPnPServer;

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpUPnPServerDelegate <NSObject>
@optional
/// 搜索到设备
- (void)server:(SSHelpUPnPServer *)server findDevice:(SSHelpUPnPDevice *)device;
@end


@interface SSHelpUPnPServer : NSObject

/// 是否是IPv6
@property(nonatomic, assign) BOOL isIPv6Enable;

/// 代理
@property(nonatomic, weak) id<SSHelpUPnPServerDelegate> delegate;

/// 开始搜索服务
- (void)start:(NSError **)error;

/// 停止搜索服务
- (void)stop;

@end

NS_ASSUME_NONNULL_END
