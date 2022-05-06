//
//  SSHelpLogHttpServer.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2020/8/18.
//  Copyright © 2020 personal. All rights reserved.
//  日志服务系统，可通过浏览器直接加载App日志文件
//

#import <Foundation/Foundation.h>

@interface SSHelpLogHttpServer : NSObject

/// 启动日志服务
+ (void)startServer;

/// 停止日志服务
+ (void)stopServer;

@end
