//
//  SSHelpUPnPControl.h
//  Pods
//
//  Created by 宋直兵 on 2023/12/22.
//

#import <Foundation/Foundation.h>
#import <SSHelpTools/SSHelpDefines.h>
#import <KissXML/KissXML.h>
#import "SSHelpUPnPDevice.h"

NS_ASSUME_NONNULL_BEGIN

/// UPnP Action Request 指令类型
typedef NS_OPTIONS(NSUInteger, SSUPnPActionType) {
    SSUPnPActionSetAVTransportURI     = 1 << 0, // 设置当前播放源地址
    SSUPnPActionSetAVTransportNextURI = 1 << 1, // 设置下一个播放源地址
    SSUPnPActionPlay                  = 1 << 2,
    SSUPnPActionPause                 = 1 << 3,
    SSUPnPActionStop                  = 1 << 4,
    SSUPnPActionPrevious              = 1 << 5,
    SSUPnPActionNext                  = 1 << 6,
    SSUPnPActionGetVolume             = 1 << 7,
    SSUPnPActionSetVolume             = 1 << 8,
    SSUPnPActionSeek                  = 1 << 9,  // 设置播放进度
    SSUPnPActionGetPositionInfo       = 1 << 10, // 获取播放进度
    SSUPnPActionGetTransportInfo      = 1 << 11, // 获取播放状态
};

/// 解析 UPnP Action Response
FOUNDATION_EXPORT NSDictionary * SSUPnPPrsedActionResponse(NSData *data, SSUPnPActionType type);


@interface SSHelpUPnPControl : NSObject

/// 初始化绑定设备
+ (instancetype)bindDevice:(SSHelpUPnPDevice *)device;

/// (通用)发送指令
- (void)postAction:(SSUPnPActionType)actionType data:(NSString *_Nullable)dataString callback:(SSBlockCallback)callback;


/// 设置播放资源地址
- (void)setAVTransportURL:(NSString *)URLSting callback:(SSBlockCallback)callback;

/// 设置下一个播放资源地址
- (void)setAVTransportNextURL:(NSString *)nextURLSting callback:(SSBlockCallback)callback;

/// 获取播放状态
- (void)getTransportInfo:(SSBlockCallback)callback;


/// 播放
- (void)play:(SSBlockCallback)callback;

/// 暂停
- (void)pause:(SSBlockCallback)callback;

/// 结束
- (void)stop:(SSBlockCallback)callback;


/// 上一个
- (void)previous:(SSBlockCallback)callback;

/// 下一个
- (void)next:(SSBlockCallback)callback;


/// 获取进度
- (void)getPositionInfo:(SSBlockCallback)callback;

/// 设置进度
- (void)setPosition:(NSString *)totalSeconds callback:(SSBlockCallback)callback;


/// 获取音量
- (void)getVolume:(SSBlockCallback)callback;

/// 设置音量
- (void)setVolume:(NSString *)numberString callback:(SSBlockCallback)callback;

@end

NS_ASSUME_NONNULL_END


