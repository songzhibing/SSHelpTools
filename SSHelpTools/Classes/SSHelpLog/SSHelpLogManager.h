//
//  SSHelpLogManager.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/9/3.
//  封装CocoaLumberjack日志库
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

#define SSLogError(frmt, ...)   LOG_MAYBE(NO,                LOG_LEVEL_DEF, DDLogFlagError,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define SSLogWarn(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagWarning, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define SSLogInfo(frmt, ...)    LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagInfo,    0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define SSLogDebug(frmt, ...)   LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagDebug,   0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

#define SSLogVerbose(frmt, ...) LOG_MAYBE(LOG_ASYNC_ENABLED, LOG_LEVEL_DEF, DDLogFlagVerbose, 0, nil, __PRETTY_FUNCTION__, frmt, ##__VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

/// 声明外部变量
extern DDLogLevel ddLogLevel;

@interface SSHelpLogManager : NSObject

- (instancetype)init NS_UNAVAILABLE;

/// 单列  [加载了addXcodeLogger、addFileLogger]
+ (SSHelpLogManager *)manager;

#pragma mark - 添加支持日志类型

/// 写到Xcode控制台
- (void)addXcodeLogger;

/// 写到iOS10之后的系统日志
- (void)addOSLogger;

/// 写到文件中
- (void)addFileLogger;

#pragma mark - 移除支持的日志类型

/// 移除Xcode控制台日志
- (void)removeXcodeLogger;

/// 移除iOS10之后的系统日志
- (void)removeOSLogger;

/// 移除文件写入日志
- (void)removeFileLogger;

#pragma mark -

/// 切换日志等级
- (void)switchLogLevel:(DDLogLevel)logLevel;

/// 获取文件日志对象
- (DDFileLogger *)fileLogger;

@end

NS_ASSUME_NONNULL_END
