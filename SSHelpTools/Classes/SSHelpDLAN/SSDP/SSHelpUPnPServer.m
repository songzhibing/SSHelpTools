//
//  SSHelpUPnPServer.m
//  Pods
//
//  Created by 宋直兵 on 2023/12/20.
//

#import "SSHelpUPnPServer.h"
#import <SSHelpTools/SSHelpDefines.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>

@interface SSHelpUPnPServer()<GCDAsyncUdpSocketDelegate>
@property(nonatomic, copy  ) NSString *ip;
@property(nonatomic, assign) uint16_t port;
@property(nonatomic, strong) GCDAsyncUdpSocket *socket;
@end


@implementation SSHelpUPnPServer

- (void)dealloc
{
    if (self.socket) {
        [self.socket close];
    }
    self.socket = nil;
}

/// 开始搜索服务
- (void)start:(NSError **)error
{
    if (!self.socket) {
        // 多播地址
        self.ip = self.isIPv6Enable?@"[2FF02::1:2]":@"239.255.255.250";
        self.port = 1900;

        // 构建Socket
        GCDAsyncUdpSocket *socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
        // 绑定端口
        [socket bindToPort:self.port error:error];
        if (*error) return;
        // 加入多播组
        [socket joinMulticastGroup:self.ip error:error];
        if (*error) return;
        
        self.socket = socket;
    }
    // 开始接受消息
    [self.socket beginReceiving:error];
    if (*error) return;
    // 发送消息
    [self sendSearchMessage];
}

/// 停止搜索服务
- (void)stop
{
    if (self.socket) {
        // 停止接受消息
        [self.socket pauseReceiving];
    }
}

/// 发送搜索消息
- (void)sendSearchMessage
{
    /**
     多播搜索消息
     M-SEARCH * HTTP/1.1             // 请求头 不可改变
     MAN: "ssdp:discover"            // 设置协议查询的类型，必须是：ssdp:discover
     MX: 5                           // 设置设备响应最长等待时间，设备响应在0和这个值之间随机选择响应延迟的值。这样可以为控制点响应平衡网络负载。
     HOST: 239.255.255.250:1900      // 设置为协议保留多播地址和端口，必须是：239.255.255.250:1900（IPv4）或FF0x::C(IPv6
     ST: upnp:rootdevice             // 设置服务查询的目标，它必须是下面的类型：
                                     // ssdp:all  搜索所有设备和服务
                                     // upnp:rootdevice  仅搜索网络中的根设备
                                     // uuid:device-UUID  查询UUID标识的设备
                                     // urn:schemas-upnp-org:device:device-Type:version  查询device-Type字段指定的设备类型，设备类型和版本由UPNP组织定义。
                                     // urn:schemas-upnp-org:service:service-Type:version  查询service-Type字段指定的服务类型，服务类型和版本由UPNP组织定义。
     如果需要实现投屏，则设备类型 ST 为 urn:schemas-upnp-org:service:AVTransport:1
     */
    NSString *host = [NSString stringWithFormat:@"HOST: %@:%d\r\n",self.ip,self.port];
    NSString *st   = [NSString stringWithFormat:@"ST: %@\r\n",_kUPnPServiceType_AVTransport];
    
    NSString *message = @"";
    message = [message stringByAppendingString:@"M-SEARCH * HTTP/1.1\r\n"];
    message = [message stringByAppendingString:@"MAN: \"ssdp:discover\"\r\n"];
    message = [message stringByAppendingString:@"MX: 3\r\n"];
    //message = [message stringByAppendingString:@"HOST: 239.255.255.250:1900\r\n"];
    //message = [message stringByAppendingString:@"ST: ssdp:all\r\n"];
    message = [message stringByAppendingString:host];
    message = [message stringByAppendingString:st];
    message = [message stringByAppendingString:@"USER-AGENT: iOS UPnP/1.1 iPhone\r\n"];
    
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket sendData:data toHost:self.ip port:self.port withTimeout:-1 tag:1];
    SSLog(@"已经发送搜索消息...");
}


#pragma mark -
#pragma mark - GCDAsyncUdpSocketDelegate Method

/**
 * Called when the datagram with the given tag has been sent.
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    SSLog(@"Socket发送消息成功：%ld",tag);
}

/**
 * Called if an error occurs while trying to send a datagram.
 * This could be due to a timeout, or something more serious such as the data being too large to fit in a sigle packet.
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError * _Nullable)error
{
    SSLog(@"Socket发送消息失败：%ld 错误：%@",tag,error.localizedDescription);
}

/**
 * Called when the socket has received the requested datagram.
 */
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(nullable id)filterContext
{
    if (data) {
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (dataString) {
           if ([dataString hasPrefix:@"NOTIFY * HTTP/1.1"]) {
               SSLog(@"收到其它设备的主动消息:%@",dataString);
                // 其它设备的主动消息
                if (self.delegate && [self.delegate respondsToSelector:@selector(server:findDevice:)]) {
                    SSHelpUPnPDevice *dev = [[SSHelpUPnPDevice alloc] initWithDataSting:dataString];
                    if (dev.uuid.length) {
                        [self.delegate server:self findDevice:dev];
                    }
                }
            } else if ([dataString hasPrefix:@"HTTP/1.1 200 OK"]) {
                SSLog(@"收到搜索响应消息:%@",dataString);
                // 搜索响应消息
                if (self.delegate && [self.delegate respondsToSelector:@selector(server:findDevice:)]) {
                    SSHelpUPnPDevice *dev = [[SSHelpUPnPDevice alloc] initWithDataSting:dataString];
                    if (dev.uuid.length) {
                        [self.delegate server:self findDevice:dev];
                    }
                }
            }
        }
    }
}

@end
