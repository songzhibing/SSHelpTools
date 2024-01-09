//
//  SSHelpDLAN.m
//  Pods
//
//  Created by 宋直兵 on 2023/12/20.
//

#import "SSHelpDLAN.h"
#import "SSHelpUPnPServer.h"

@interface SSHelpDLAN()<SSHelpUPnPServerDelegate>
@property(nonatomic, strong) SSHelpUPnPServer *server;
@property(nonatomic, strong) NSMutableArray <SSHelpUPnPDevice *> *devices;
@end


@implementation SSHelpDLAN

- (void)dealloc
{
    [self stopSearch];
    self.server = nil;
}

#pragma mark -
#pragma mark - 搜索设备

/// 开始搜索设备
- (void)startSearch:(NSError **)error;
{
    if (!self.server) {
        self.server = [[SSHelpUPnPServer alloc] init];
        self.server.delegate = self;
    }
    [self.server start:error];
}

/// 停止搜索设备
- (void)stopSearch
{
    if (self.server) {
        [self.server stop];
    }
}

#pragma mark - SSHelpUPnPServerDelegate Method

/// 搜索到设备
- (void)server:(SSHelpUPnPServer *)server findDevice:(SSHelpUPnPDevice *)device
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    dispatch_async(dispatch_get_main_queue(), ^{
        __block BOOL isNewDevice = YES;
        [self.devices enumerateObjectsUsingBlock:^(SSHelpUPnPDevice * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.uuid isEqualToString:device.uuid ]) {
                // 收到同一设备信息，则更新设备信息
                [obj updateWithDataDict:device.dataDict];
                isNewDevice = NO;
                *stop = YES;
            }
        }];
        if (isNewDevice) {
            // 新设备需要查询服务信息
            [device requestLocationXML];
            [self.devices addObject:device];
        }
        
        // 代理
        SEL sel = @selector(dlan:findDevice:);
        if (self.deleagte && [self.deleagte respondsToSelector:sel]) {
            [self.deleagte dlan:self findDevice:device];
        }
        // 回调
        if (self.findDevice) {
            self.findDevice(device);
        }
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
}


#pragma mark -
#pragma mark - 投屏

/// 发送指令
- (void)postAction:(SSUPnPActionType)actionType device:(SSHelpUPnPDevice *)device data:(NSString *_Nullable)data callback:(SSDLANPostActionCallback)callback
{
    SSHelpUPnPControl *transport = [SSHelpUPnPControl bindDevice:device];
    [transport postAction:actionType data:data callback:^(id  _Nullable response, NSError * _Nullable error) {
        if (error) {
            callback(nil, error);
        } else {
            NSDictionary *dict = SSUPnPPrsedActionResponse(response, actionType);
            callback(dict, nil);
        }
    }];
}

#pragma mark - 快捷执行指令

/// 开始投屏 （设置源+播放）
- (void)startDLAN:(SSHelpUPnPDevice *)device url:(NSString *)url callback:(SSDLANPostActionCallback)callback
{
    SSHelpUPnPControl *transport = [SSHelpUPnPControl bindDevice:device];
    @Tweakify(transport);
    [transport setAVTransportURL:url callback:^(id  _Nullable response, NSError * _Nullable error) {
        if (error) {
            callback(nil, error);
        } else {
            @Tstrongify(transport);
            [transport play:^(id  _Nullable response, NSError * _Nullable error) {
                callback(@{},error);
            }];
        }
    }];
}

/// 播放
- (void)play:(SSHelpUPnPDevice *)device callback:(SSDLANPostActionCallback)callback
{
    SSHelpUPnPControl *transport = [SSHelpUPnPControl bindDevice:device];
    [transport play:^(id  _Nullable response, NSError * _Nullable error) {
        callback(@{},error);
    }];
}

/// 暂停
- (void)pause:(SSHelpUPnPDevice *)device callback:(SSDLANPostActionCallback)callback
{
    SSHelpUPnPControl *transport = [SSHelpUPnPControl bindDevice:device];
    [transport pause:^(id  _Nullable response, NSError * _Nullable error) {
        callback(@{},error);
    }];
}

/// 结束投屏
- (void)stopDLAN:(SSHelpUPnPDevice *)device callback:(SSDLANPostActionCallback)callback
{
    SSHelpUPnPControl *transport = [SSHelpUPnPControl bindDevice:device];
    [transport stop:^(id  _Nullable response, NSError * _Nullable error) {
        callback(@{},error);
    }];
}

@end
