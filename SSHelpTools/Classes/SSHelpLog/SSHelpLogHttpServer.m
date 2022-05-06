//
//  SSHelpLogHttpServer.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2020/8/18.
//  Copyright © 2020 personal. All rights reserved.
//

#import "SSHelpLogHttpServer.h"
#import "SSHelpLogManager.h"
#import <GCDWebServer/GCDWebServer.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerPrivate.h>

@interface SSHelpLogHttpServer ()<GCDWebServerDelegate>

@property(nonatomic, strong) GCDWebServer *webServer;

@end

@implementation SSHelpLogHttpServer

+ (void)startServer
{
    [[SSHelpLogHttpServer shared] startServer];
}

+ (void)stopServer
{
    [[SSHelpLogHttpServer shared] stopServer];
}

+ (instancetype)shared
{
    static dispatch_once_t onceToken;
    static SSHelpLogHttpServer *shared;
    dispatch_once(&onceToken, ^{
        shared = [[SSHelpLogHttpServer alloc] init];
    });
    return shared;
}

- (void)dealloc
{
    [self stopServer];
}

- (void)startServer
{
    if (!_webServer){
        #ifdef DEBUG
        [GCDWebServer setLogLevel:kGCDWebServerLoggingLevel_Debug];
        #endif
        
        NSString *logFilePath = [SSHelpLogManager manager].fileLogger.logFileManager.logsDirectory;
        _webServer =  [[GCDWebServer alloc] init];
        _webServer.delegate = self;
        [_webServer addGETHandlerForBasePath:@"/"
                               directoryPath:logFilePath
                               indexFilename:nil
                                    cacheAge:0
                          allowRangeRequests:YES]; //设置目录
        [_webServer startWithOptions:@{GCDWebServerOption_Port:@(48065),
                                       GCDWebServerOption_BindToLocalhost: @(NO)}
                               error:nil]; //配置服务信息
        
        #ifdef DEBUG
            SSLogDebug(@"日志服务启动信息:%@",_webServer.serverURL.absoluteString);
        #endif
    }

    // Add a handler to respond to GET requests on any URL
    /*
    [self.webServer addDefaultHandlerForMethod:@"GET"
                                  requestClass:[GCDWebServerRequest class]
                                  processBlock:^GCDWebServerResponse *(GCDWebServerRequest* request) {
                                    return [weakSelf createResponseBody:request];
    }];
    */
}

- (void)stopServer
{
    if (_webServer) {
        [_webServer stop];
    }
    _webServer = nil;
}

#pragma mark - GCDWebServerDelegate Method

/**
 *  This method is called after the server has successfully started.
 */
- (void)webServerDidStart:(GCDWebServer*)server
{
    
}

/**
 *  This method is called after the Bonjour registration for the server has
 *  successfully completed.
 *
 *  Use the "bonjourServerURL" property to retrieve the Bonjour address of the
 *  server.
 */
- (void)webServerDidCompleteBonjourRegistration:(GCDWebServer*)server
{
    
}

/**
 *  This method is called after the NAT port mapping for the server has been
 *  updated.
 *
 *  Use the "publicServerURL" property to retrieve the public address of the
 *  server.
 */
- (void)webServerDidUpdateNATPortMapping:(GCDWebServer*)server
{
    
}

/**
 *  This method is called when the first GCDWebServerConnection is opened by the
 *  server to serve a series of HTTP requests.
 *
 *  A series of HTTP requests is considered ongoing as long as new HTTP requests
 *  keep coming (and new GCDWebServerConnection instances keep being opened),
 *  until before the last HTTP request has been responded to (and the
 *  corresponding last GCDWebServerConnection closed).
 */
- (void)webServerDidConnect:(GCDWebServer*)server
{
    
}

/**
 *  This method is called when the last GCDWebServerConnection is closed after
 *  the server has served a series of HTTP requests.
 *
 *  The GCDWebServerOption_ConnectedStateCoalescingInterval option can be used
 *  to have the server wait some extra delay before considering that the series
 *  of HTTP requests has ended (in case there some latency between consecutive
 *  requests). This effectively coalesces the calls to -webServerDidConnect:
 *  and -webServerDidDisconnect:.
 */
- (void)webServerDidDisconnect:(GCDWebServer*)server
{
    
}

/**
 *  This method is called after the server has stopped.
 */
- (void)webServerDidStop:(GCDWebServer*)server
{
    
}

@end


