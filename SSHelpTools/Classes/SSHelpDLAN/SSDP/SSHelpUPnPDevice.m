//
//  SSHelpUPnPDevice.m
//  Pods
//
//  Created by 宋直兵 on 2023/12/20.
//

#import "SSHelpUPnPDevice.h"
#import <SSHelpTools/SSHelpDefines.h>
#import <KissXML/KissXML.h>

/**
  NOTIFY * HTTP/1.1
  Host: 239.255.255.250:1900
  NT: urn:schemas-upnp-org:service:AVTransport:1
  NTS: ssdp:alive
  Location: http://192.168.212.44:2869/upnphost/udhisapi.dll?content=uuid:df6ca7d1-4a4b-47d6-83d6-3f6248bd5a15
  USN: uuid:df6ca7d1-4a4b-47d6-83d6-3f6248bd5a15::urn:schemas-upnp-org:service:AVTransport:1
  Cache-Control: max-age=1800
  Server: Microsoft-Windows/10.0 UPnP/1.0 UPnP-Device-Host/1.0
  OPT:"http://schemas.upnp.org/upnp/1/0/"; ns=01
  01-NLS: 9b1a871f75f8d8b66a79df2956a80977
  
  NOTIFY * HTTP/1.1
  Host: 239.255.255.250:1900
  NT: urn:schemas-upnp-org:service:AVTransport:1
  NTS: ssdp:byebye
  Location: http://192.168.230.166:2869/upnphost/udhisapi.dll?content=uuid:20cbef6e-3e35-4ccd-9ed0-5b2f639689eb
  USN: uuid:20cbef6e-3e35-4ccd-9ed0-5b2f639689eb::urn:schemas-upnp-org:service:AVTransport:1
  Cache-Control: max-age=1800
  Server: Microsoft-Windows/10.0 UPnP/1.0 UPnP-Device-Host/1.0
  OPT:"http://schemas.upnp.org/upnp/1/0/"; ns=01
  01-NLS: a2fad118d0a349997bd4e868dc3915a9
  
  
  HTTP/1.1 200 OK
  Ext:
  St: urn:schemas-upnp-org:service:AVTransport:1
  Server: Linux/4.9.44 UPnP/1.0 Cling/2.0
  Host: 239.255.255.250:1900
  Usn: uuid:746fdb17-6ec3-3477-ffff-ffffc0860aa6::urn:schemas-upnp-org:service:AVTransport:1
  X-cling-iface-mac: 14:AE:85:DA:59:D4
  Cache-control: max-age=1800
  Location: http://192.168.212.26:39313/upnp/dev/746fdb17-6ec3-3477-ffff-ffffc0860aa6/desc
*/
 
/// 处理数据
NSDictionary *__ParsedDataString(NSString *dataString){
    if (dataString && [dataString isKindOfClass:NSString.class] && dataString.length>0) {
        NSMutableDictionary *dict = @{}.mutableCopy;
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
        NSArray *ary = [dataString componentsSeparatedByString:@"\r\n"];
        [ary enumerateObjectsUsingBlock:^(NSString  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            // 消息头处理
            if (idx==0 && obj.length>0) {
                [dict setValue:obj forKey:@"header"];
            }
            // 正文处理
            NSArray *sub = [obj componentsSeparatedByString:@":"];
            if (sub && sub.count>=2) {
                // key统一小写
                NSString *key = sub.firstObject;
                key = key.lowercaseString;
                // value 前后去空
                NSString *value = [obj substringFromIndex:key.length+1]?:@"";
                value = [value stringByTrimmingCharactersInSet:set];
                // 缓存
                [dict setValue:value forKey:key.lowercaseString];
                // 细化
                if ([key isEqualToString:@"USN".lowercaseString]) {
                    // USN: uuid:df6ca7d1-4a4b-47d6-83d6-3f6248bd5a15::urn:schemas-upnp-org:service:AVTransport:1
                    NSArray *usnAry = [value componentsSeparatedByString:@"::"];
                    if (usnAry.firstObject && [usnAry.firstObject hasPrefix:@"uuid:"]) {
                        NSString *uuid = [usnAry.firstObject substringFromIndex:5];
                        [dict setValue:uuid?:@"" forKey:@"uuid"];
                    }
                }
            }
        }];
        return dict;
    }
    return @{};
};


@implementation SSHelpUPnPDevice

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ...",self);
}

- (instancetype)initWithDataSting:(NSString *)dataString
{
    self = [super init];
    if (self) {
        _dataDict = __ParsedDataString(dataString);
        [self updateWithDataDict:_dataDict];
    }
    return self;
}

/// 更新属性
- (void)updateWithDataDict:(NSDictionary *)dict
{
    self.cacheControl = SSEncodeStringFromDict(dict, @"Cache-Control".lowercaseString);
    self.usn      = SSEncodeStringFromDict(dict, @"USN".lowercaseString);
    self.location = SSEncodeStringFromDict(dict, @"Location".lowercaseString);
    self.server   = SSEncodeStringFromDict(dict, @"Server".lowercaseString);
    self.date     = SSEncodeStringFromDict(dict, @"Date".lowercaseString);
    self.ext      = SSEncodeStringFromDict(dict, @"Ext".lowercaseString);
    self.st       = SSEncodeStringFromDict(dict, @"St".lowercaseString);
    self.nt       = SSEncodeStringFromDict(dict, @"NT".lowercaseString);
    self.nts      = SSEncodeStringFromDict(dict, @"NTS".lowercaseString);

    self.header   = SSEncodeStringFromDict(dict, @"header");
    self.uuid     = SSEncodeStringFromDict(dict, @"uuid");
}


/// 查询设备详情、服务等信息
- (void)requestLocationXML
{
    @Tweakify(self);
    if (self.location.length == 0) {
        SSLog(@"设备Location地址为空");
        return;
    }
    NSURL *url = [NSURL URLWithString:self.location];
    if (!url) {
        SSLog(@"设备Location地址构建URL失败：%@",self.location);
        return;
    }
    // 构建远程设备服务地址
    self.serverURL = [NSString stringWithFormat:@"%@://%@:%@",url.scheme,url.host,url.port];
    // 查询设备服务及相关信息
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData timeoutInterval:5.0];
    request.HTTPMethod = @"GET";
    
    [[[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            SSLog(@"查询设备详情出错:%@",error);
        }
        if (data) {
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                    NSError *error;
                    DDXMLDocument *xml = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
                    if (error) {
                        SSLog(@"处理XML数据出错:%@",error);
                        return;
                    }
                    DDXMLElement *device = [xml.rootElement elementForName:@"device"];
                    
                    // 设备名称
                    self_weak_.deviceFriendlyName = [device elementForName:@"friendlyName"].stringValue?:@"";
                    
                    // 设备图标
                    [[device elementsForName:@"iconList"] enumerateObjectsUsingBlock:^(DDXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        // 默认取第一条数据
                        self_weak_.deviceIconUrl = [obj elementForName:@"url"].stringValue?:@"";
                        self_weak_.deviceIconMimetype = [obj elementForName:@"mimetype"].stringValue?:@"";
                        *stop = YES;
                    }];
                    
                    // 设备服务
                    DDXMLElement *serviceList =  [device elementForName:@"serviceList"];
                    [[serviceList elementsForName:@"service"] enumerateObjectsUsingBlock:^(DDXMLElement * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        NSString *serviceType = [obj elementForName:@"serviceType"].stringValue?:@"";
                        NSString *serviceId   = [obj elementForName:@"serviceId"].stringValue?:@"";
                        NSString *SCPDURL     = [obj elementForName:@"SCPDURL"].stringValue?:@"";
                        NSString *controlURL  = [obj elementForName:@"controlURL"].stringValue?:@"";
                        NSString *eventSubURL = [obj elementForName:@"eventSubURL"].stringValue?:@"";

                        if ([serviceType isEqualToString:_kUPnPServiceType_AVTransport]) {
                            self_weak_.serviceAVTransportSCPDURL     = SCPDURL;
                            self_weak_.serviceAVTransportControlURL  = controlURL;
                            self_weak_.serviceAVTransportEventSubURL = eventSubURL;
                            self_weak_.serviceAVTransportServiceType = serviceType;
                            self_weak_.serviceAVTransportId          = serviceId;
                        } else if ([serviceType isEqualToString:_kUPnPServiceType_RenderingControl]) {
                            self_weak_.serviceRenderingControlSCPDURL     = SCPDURL;
                            self_weak_.serviceRenderingControlControlURL  = controlURL;
                            self_weak_.serviceRenderingControlEventSubURL = eventSubURL;
                            self_weak_.serviceRenderingControlServiceType = serviceType;
                            self_weak_.serviceRenderingControlId          = serviceId;
                        }
                    }];
                } @catch (NSException *exception) {
                    SSLog(@"解析出错：%@",exception.description);
                } @finally {
                }
            });
        }
    }] resume] ;
}

@end
