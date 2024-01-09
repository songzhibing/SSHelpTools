//
//  SSHelpUPnPControl.m
//  Pods
//
//  Created by 宋直兵 on 2023/12/22.
//

#import "SSHelpUPnPControl.h"
#import <KissXML/KissXML.h>

NSString * SSUPnPBodyKeyInActionResponse(SSUPnPActionType type) {
    switch (type) {
        case SSUPnPActionSetAVTransportURI:
            return @"SetAVTransportURIResponse";
        case SSUPnPActionSetAVTransportNextURI:
            return @"SetNextAVTransportURIResponse";
        case SSUPnPActionPlay:
            return @"PlayResponse";
        case SSUPnPActionPause:
            return @"PauseResponse";
        case SSUPnPActionStop:
            return @"StopResponse";
        case SSUPnPActionPrevious:
            return @"PreviousResponse";
        case SSUPnPActionNext:
            return @"NextResponse";
        case SSUPnPActionGetVolume:
            return @"GetVolumeResponse";
        case SSUPnPActionSetVolume:
            return @"SetVolumeResponse";
        case SSUPnPActionSeek:
            return @"SeekResponse";
        case SSUPnPActionGetPositionInfo:
            return @"GetPositionInfoResponse";
        case SSUPnPActionGetTransportInfo:
            return @"GetTransportInfoResponse";
    }
    return @"";
}


NSDictionary * SSUPnPPrsedActionResponse(NSData *data, SSUPnPActionType type) {
    NSError *error;
    DDXMLDocument *doc = [[DDXMLDocument alloc] initWithData:data options:0 error:&error];
    if (doc && doc.rootElement && doc.rootElement.children) {
        __block DDXMLElement *bodyElement = nil;
        [doc.rootElement.children enumerateObjectsUsingBlock:^(DDXMLNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name hasSuffix:@":Body"]) {
                if (obj.children) {
                    bodyElement = obj;
                }
                *stop = YES;
            }
        }];
        __block DDXMLElement *resElement = nil;
        NSString *bodyKey = SSUPnPBodyKeyInActionResponse(type);
        [bodyElement.children enumerateObjectsUsingBlock:^(DDXMLNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.name && [obj.name hasSuffix:bodyKey]) {
                if (obj.children) {
                    resElement = obj;
                }
                *stop = YES;
            }
        }];
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        [resElement.children enumerateObjectsUsingBlock:^(DDXMLNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *key = obj.name;
            if (key && key.length) {
                [dict setValue:obj.stringValue?:@"" forKey:key];
            }
        }];
        return dict;
    }
    return @{};
}


@interface SSHelpUPnPControl()
@property(nonatomic, strong) SSHelpUPnPDevice *device;
@property(nonatomic, assign) BOOL logEnable;
@end

@implementation SSHelpUPnPControl

// 初始化绑定一台设备
+ (instancetype)bindDevice:(SSHelpUPnPDevice *)device
{
    SSHelpUPnPControl *transport = [[SSHelpUPnPControl alloc] init];
    transport.device = device;
    return transport;
}

/// 发送指令
- (void)postAction:(SSUPnPActionType)actionType data:(NSString *_Nullable)dataString callback:(SSBlockCallback)callback
{
    switch (actionType) {
        case SSUPnPActionSetAVTransportURI:
            [self setAVTransportURL:dataString callback:callback];
            break;
        case SSUPnPActionSetAVTransportNextURI:
            [self setAVTransportNextURL:dataString callback:callback];
            break;
            
        case SSUPnPActionPlay:
            [self play:callback];
            break;
        case SSUPnPActionPause:
            [self pause:callback];
            break;
        case SSUPnPActionStop:
            [self stop:callback];
            break;

        case SSUPnPActionPrevious:
            [self previous:callback];
            break;
        case SSUPnPActionNext:
            [self next:callback];
            break;
            
        case SSUPnPActionGetVolume:
            [self getVolume:callback];
            break;
        case SSUPnPActionSetVolume:
            [self setVolume:dataString callback:callback];
            break;
            
        case SSUPnPActionSeek:
            [self setPosition:dataString callback:callback];
            break;
        case SSUPnPActionGetPositionInfo:
            [self getPositionInfo:callback];
            break;
        case SSUPnPActionGetTransportInfo:
            [self getTransportInfo:callback];
            break;
            
        default:
            break;
    }
}

/// 设置播放资源地址
- (void)setAVTransportURL:(NSString *)URLSting callback:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionSetAVTransportURI;
    
    DDXMLElement *body = [DDXMLElement elementWithName:@"u:SetAVTransportURI"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    [body addChild:[DDXMLNode elementWithName:@"CurrentURI" stringValue:URLSting?:@""]];

    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#SetAVTransportURI";
        
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}

/// 设置下一个播放资源地址
- (void)setAVTransportNextURL:(NSString *)nextURLSting callback:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionSetAVTransportNextURI;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:SetNextAVTransportURI"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    [body addChild:[DDXMLNode elementWithName:@"NextURI" stringValue:nextURLSting?:@""]];

    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#SetNextAVTransportURI";

    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}

/// 播放
/// - Parameter callback: 回调
- (void)play:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionPlay;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:Play"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    [body addChild:[DDXMLNode elementWithName:@"Speed" stringValue:@"1"]];

    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#Play";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];}

/// 暂停
- (void)pause:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionPause;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:Pause"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    
    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#Pause";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}

/// 结束
- (void)stop:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionStop;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:Stop"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    
    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#Stop";
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}


/// 上一个
- (void)previous:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionPrevious;
    DDXMLElement *body = [DDXMLElement elementWithName:@"u:Previous"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    
    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#Previous";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];

}

/// 下一个
- (void)next:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionNext;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:Next"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    
    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#Next";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}


/// 设置进度
- (void)setPosition:(NSString *)totalSeconds callback:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionSeek;
    NSString *time = [NSDate ss_formatSeconds:totalSeconds.integerValue];
    
    DDXMLElement *body = [DDXMLElement elementWithName:@"u:Seek"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    [body addChild:[DDXMLNode elementWithName:@"Unit" stringValue:@"REL_TIME"]];
    [body addChild:[DDXMLNode elementWithName:@"Target" stringValue:time]];

    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#Seek";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}

/// 获取播放进度
- (void)getPositionInfo:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionGetPositionInfo;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:GetPositionInfo"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    
    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#GetPositionInfo";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}

/// 获取播放状态
- (void)getTransportInfo:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionGetTransportInfo;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:GetTransportInfo"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    
    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:AVTransport:1#GetTransportInfo";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}



/// 获取音量
- (void)getVolume:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionGetVolume;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:GetVolume"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    [body addChild:[DDXMLNode elementWithName:@"Channel" stringValue:@"Master"]];

    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:RenderingControl:1#GetVolume";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
    
}

/// 设置音量
- (void)setVolume:(NSString *)numberString callback:(SSBlockCallback)callback
{
    SSUPnPActionType actionType = SSUPnPActionSetVolume;

    DDXMLElement *body = [DDXMLElement elementWithName:@"u:SetVolume"];
    [body addChild:[DDXMLNode elementWithName:@"InstanceID" stringValue:@"0"]];
    [body addChild:[DDXMLNode elementWithName:@"Channel" stringValue:@"Master"]];
    [body addChild:[DDXMLNode elementWithName:@"DesiredVolume" stringValue:numberString?:@"0"]];

    DDXMLElement *xml = [self XMLElementByAction:actionType addBody:body];
    NSString *SOAPAction = @"urn:schemas-upnp-org:service:RenderingControl:1#SetVolume";
    
    [self postActionRequest:actionType
           headerSOAPAction:SOAPAction
                 bodyString:xml.XMLString
                   callback:callback];
}



/// 构建通用XML
- (DDXMLElement *)XMLElementByAction:(SSUPnPActionType)actionType addBody:(DDXMLElement *)bodyElement
{
    NSString *serviceType = _kUPnPServiceType_AVTransport;
    if (actionType == SSUPnPActionGetVolume || actionType == SSUPnPActionSetVolume) {
        serviceType = _kUPnPServiceType_RenderingControl;
    }
    
    DDXMLElement *XML = [DDXMLElement elementWithName:@"s:Envelope"];
    [XML addAttribute:[DDXMLElement attributeWithName:@"s:encodingStyle"
                                          stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [XML addAttribute:[DDXMLElement attributeWithName:@"s:encodingStyle"
                                          stringValue:@"http://schemas.xmlsoap.org/soap/encoding/"]];
    [XML addAttribute:[DDXMLElement attributeWithName:@"xmlns:s"
                                          stringValue:@"http://schemas.xmlsoap.org/soap/envelope/"]];
    [XML addAttribute:[DDXMLElement attributeWithName:@"xmlns:u"
                                          stringValue:serviceType]];
    
    DDXMLElement *body = [DDXMLElement elementWithName:@"s:Body"];
    [body addChild:bodyElement];
    
    [XML addChild:body];
    
    return XML;
}

#pragma mark -
#pragma mark - Post Request

- (void)postActionRequest:(SSUPnPActionType)actionType headerSOAPAction:(NSString *)SOAPAction bodyString:(NSString *)bodyString callback:(SSBlockCallback)callback
{
    NSString *urlPath =  self.device.serviceAVTransportControlURL;
    if (actionType == SSUPnPActionGetVolume || actionType == SSUPnPActionSetVolume) {
        urlPath = self.device.serviceRenderingControlControlURL;
    }
    if (![urlPath hasPrefix:@"/"]) {
        urlPath = [@"/" stringByAppendingString:urlPath];
    }
    NSString *host = [NSString stringWithFormat:@"%@%@",self.device.serverURL,urlPath];
    NSURL *url = [NSURL URLWithString:host];
    if (!url) {
        callback(nil, _kLocalError(@"地址错误:%@",host));
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [bodyString?:@"" dataUsingEncoding:NSUTF8StringEncoding];
    request.allHTTPHeaderFields = @{
        @"Content-Type":@"text/xml",
        @"SOAPAction":SOAPAction?:@""
    };
    if (self.logEnable) {
        SSLog(@"\n发送指令数据：【%@】%@  到: %@", SOAPAction?:@"",bodyString?:@"", url.absoluteString);
    }

    [[NSURLSession.sharedSession dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (response && [response isKindOfClass:NSHTTPURLResponse.class]) {
                NSHTTPURLResponse *httpResponse = response;
                if (httpResponse.statusCode == 200) {
                    callback(data, nil);
                    return;
                }
            }
            if (error) {
                callback(nil, error);
            } else {
                callback(nil, _kLocalError(@"异常:%@",response.description));
            }
        });
    }] resume];
}

@end


