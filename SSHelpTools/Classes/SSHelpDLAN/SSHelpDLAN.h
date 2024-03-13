//
//  SSHelpDLAN.h
//  Pods
//
//  Created by 宋直兵 on 2023/12/20.
//

#import <Foundation/Foundation.h>
#import <SSHelpTools/SSHelpDefines.h>
#import "SSHelpUPnPDevice.h"
#import "SSHelpUPnPControl.h"
@class SSHelpDLAN;

NS_ASSUME_NONNULL_BEGIN

/// 发送指令回调
typedef void(^_Nullable SSDLANPostActionCallback)(NSDictionary *_Nullable dict, NSError *_Nullable error);


@protocol SSHelpDLANDelegate <NSObject>
@optional
/// 搜索到设备
- (void)dlan:(SSHelpDLAN *)dlan findDevice:(SSHelpUPnPDevice *)device;
@end



@interface SSHelpDLAN : NSObject

@property(nonatomic, weak) id<SSHelpDLANDelegate> deleagte;

@property(nonatomic, strong) void(^findDevice)(SSHelpUPnPDevice *device);

#pragma mark -
#pragma mark - 搜索设备

/// 开始搜索设备
- (void)startSearch:(NSError **)error;

/// 停止搜索设备
- (void)stopSearch;

#pragma mark -
#pragma mark - 发送指令

/// 开始投屏 （设置源+播放）
- (void)startDLAN:(SSHelpUPnPDevice *)device url:(NSString *)url callback:(SSDLANPostActionCallback)callback;

/// 播放
- (void)play:(SSHelpUPnPDevice *)device callback:(SSDLANPostActionCallback)callback;

/// 暂停
- (void)pause:(SSHelpUPnPDevice *)device callback:(SSDLANPostActionCallback)callback;

/// 结束投屏
- (void)stopDLAN:(SSHelpUPnPDevice *)device callback:(SSDLANPostActionCallback)callback;

/// (通用)发送指令
- (void)postAction:(SSUPnPActionType)actionType device:(SSHelpUPnPDevice *)device data:(NSString *_Nullable)data callback:(SSDLANPostActionCallback)callback;


@end

NS_ASSUME_NONNULL_END


