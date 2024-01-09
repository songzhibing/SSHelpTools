//
//  SSHelpUPnPDevice.h
//  Pods
//
//  Created by 宋直兵 on 2023/12/20.
//

#import <Foundation/Foundation.h>

#define _kUPnP_NTS_SSDP_Alive    @"ssdp:alive"
#define _kUPnP_NTS_SSDP_Byebye   @"ssdp:byebye"

/// 服务类型
#define _kUPnPServiceType_AVTransport        @"urn:schemas-upnp-org:service:AVTransport:1"
#define _kUPnPServiceType_RenderingControl   @"urn:schemas-upnp-org:service:RenderingControl:1"
#define _kUPnPServiceType_MediaServer        @"urn:schemas-upnp-org:device:MediaServer:1"
#define _kUPnPServiceType_MediaRenderer      @"urn:schemas-upnp-org:device:MediaRenderer:1"
#define _kUPnPServiceType_ContentDirectory   @"urn:schemas-upnp-org:service:ContentDirectory:1"
#define _kUPnPServiceType_ConnectionManager  @"urn:schemas-upnp-org:service:ConnectionManager:1"


NS_ASSUME_NONNULL_BEGIN

@interface SSHelpUPnPDevice : NSObject

/// 初始化
- (instancetype)initWithDataSting:(NSString *)dataString;

/// 数据
@property(nonatomic, strong, readonly) NSDictionary *dataDict;

/// 同一设备用此方法更新属性
- (void)updateWithDataDict:(NSDictionary *)dataDict;

/// 查询设备详情、服务等信息
- (void)requestLocationXML;

/// 消息头
@property(nonatomic, copy) NSString *header;

/// 指定通知消息存活时间
@property(nonatomic, copy) NSString *cacheControl;

/// 表示不同服务的统一服务名
@property(nonatomic, copy) NSString *usn;

/// 包含根设备描述得URL地址
@property(nonatomic, copy) NSString *location;

/// 包含操作系统名，版本，产品名和产品版本信息
@property(nonatomic, copy) NSString *server;

/// 响应生成时间
@property(nonatomic, copy) NSString *date;

/// 为了符合HTTP协议要求，并未使用
@property(nonatomic, copy) NSString *ext;

/// 服务的服务类型
@property(nonatomic, copy) NSString *st;

@property(nonatomic, copy) NSString *nt;

/// 表示通知消息的子类型
@property(nonatomic, copy) NSString *nts;

#pragma mark -

@property(nonatomic, copy) NSString *uuid;

@property(nonatomic, copy, nullable) NSString *serverURL;

#pragma mark -

@property(nonatomic, copy, nullable) NSString *deviceFriendlyName;

@property(nonatomic, copy, nullable) NSString *deviceIconUrl;
@property(nonatomic, copy, nullable) NSString *deviceIconMimetype;

@property(nonatomic, copy, nullable) NSString *serviceAVTransportSCPDURL;
@property(nonatomic, copy, nullable) NSString *serviceAVTransportControlURL;
@property(nonatomic, copy, nullable) NSString *serviceAVTransportEventSubURL;
@property(nonatomic, copy, nullable) NSString *serviceAVTransportServiceType;
@property(nonatomic, copy, nullable) NSString *serviceAVTransportId;

@property(nonatomic, copy, nullable) NSString *serviceRenderingControlSCPDURL;
@property(nonatomic, copy, nullable) NSString *serviceRenderingControlControlURL;
@property(nonatomic, copy, nullable) NSString *serviceRenderingControlEventSubURL;
@property(nonatomic, copy, nullable) NSString *serviceRenderingControlServiceType;
@property(nonatomic, copy, nullable) NSString *serviceRenderingControlId;


@end



NS_ASSUME_NONNULL_END

