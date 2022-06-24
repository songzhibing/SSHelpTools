//
//  SSHelpLogManager.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/9/3.
//

#import "SSHelpLogManager.h"
#import "SSHelpLogHttpServer.h"

//设置默认的log等级
#ifdef DEBUG
    DDLogLevel ddLogLevel = DDLogLevelDebug;
#else
    DDLogLevel ddLogLevel = DDLogLevelWarning;
#endif


static NSString *logCurrentTime(void)
{
    static dispatch_once_t onceToken;
    static NSDateFormatter *dateFromatter;
    dispatch_once(&onceToken, ^{
        dateFromatter = [NSDateFormatter new];
        dateFromatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        dateFromatter.calendar = [[NSCalendar  alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
        dateFromatter.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
        dateFromatter.dateFormat = @"yyyy.MM.dd.HH.mm.ss.SSS";
    });
    return [dateFromatter stringFromDate:NSDate.date];
}

//##############################################################################
//##############################################################################

@interface SSHelpLogFileManager : DDLogFileManagerDefault

@end

@implementation SSHelpLogFileManager

//重写方法(log文件名生成规则)
- (NSString *)newLogFileName
{
    NSString *timeStamp = logCurrentTime();
    return [NSString stringWithFormat:@"%@.log.txt", timeStamp];
}

//重写方法(是否是log文件)
- (BOOL)isLogFile:(NSString *)fileName
{
    BOOL hasProperSuffix = [fileName hasSuffix:@".log.txt"];
    return hasProperSuffix;
}

@end

//##############################################################################
//##############################################################################

@interface SSHelpLogFormatter : NSObject <DDLogFormatter>

@end

@implementation SSHelpLogFormatter

- (nullable NSString *)formatLogMessage:(DDLogMessage *)logMessage NS_SWIFT_NAME(format(message:))
{
    NSString *logLevel = nil;
    switch (logMessage->_flag) {
        case DDLogFlagError:
            logLevel = @"Error";
            break;
        case DDLogFlagWarning:
            logLevel = @"Warn";
            break;
        case DDLogFlagInfo:
            logLevel = @"Info";
            break;
        case DDLogFlagDebug:
            logLevel = @"Debug";
            break;
        default:
            logLevel = @"Verbose";
            break;
    }
    NSString *formatLog = [NSString stringWithFormat:@"%@ %@%@-%ld %@",[NSDate date],logLevel,logMessage->_function,logMessage->_line,logMessage->_message];
    return formatLog;
}

@end

//##############################################################################
//##############################################################################


@interface SSHelpLogManager()

/// 将日志输入到Xcode控制台
@property(nonatomic, strong) DDTTYLogger *xcodeLogger;

/// 将日志输入到文件中
@property(nonatomic, strong) DDFileLogger *fileLogger;

/// 将Log输出到 控制台.app 和 Xcode控制台
@property(nonatomic, strong) DDOSLogger *osLogger;

@end

@implementation SSHelpLogManager

+ (SSHelpLogManager *)manager
{
    static SSHelpLogManager *_logger;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _logger = [[SSHelpLogManager alloc] init];
        [_logger addXcodeLogger];
        [_logger addFileLogger];
        #ifdef DEBUG
            DDLogDebug(@"日志路径:%@",_logger.fileLogger.logFileManager.logsDirectory);
            DDLogDebug(@"日志文件:%@",_logger.fileLogger.logFileManager.sortedLogFileNames);
        #endif
    });
    return _logger;
}

#pragma mark - 等级切换

//切换log等级
- (void)switchLogLevel:(DDLogLevel)logLevel
{
    ddLogLevel = logLevel;
}

#pragma mark - 添加 & 移除

- (void)addXcodeLogger
{
    [DDLog addLogger:self.xcodeLogger];
}

/// 写到iOS10之后的系统日志
- (void)addOSLogger
{
    [DDLog addLogger:self.osLogger];
}

/// 添加文件写入Logger
- (void)addFileLogger
{
    [DDLog addLogger:self.fileLogger];
}

/// 移除Xcode控制台日志
- (void)removeXcodeLogger
{
    if (_xcodeLogger) [DDLog removeLogger:_xcodeLogger];
}

/// 移除iOS10之后的系统日志
- (void)removeOSLogger
{
    if (_osLogger) [DDLog removeLogger:_osLogger];
}

/// 移除文件写入日志
- (void)removeFileLogger
{
    if (_fileLogger) [DDLog removeLogger:_fileLogger];
}

#pragma mark - Lazy loading

- (DDTTYLogger *)xcodeLogger
{
    if (!_xcodeLogger) {
        _xcodeLogger = [DDTTYLogger sharedInstance];
        //_xcodeLogger.logFormatter = [[SSHelpLogFormatter alloc] init];
    }
    return _xcodeLogger;
}

/// 控制台logger
- (DDOSLogger *)osLogger
{
    if (!_osLogger){
        _osLogger = [DDOSLogger sharedInstance];
        //_osLogger.logFormatter = [[SSHelpLogFormatter alloc] init]; //自定义输出格式
    }
    return _osLogger;
}

/// 文件写入Logger
- (DDFileLogger *)fileLogger
{
    if (!_fileLogger)
    {
        //使用自定义的logFileManager
        SSHelpLogFileManager *fileManager = [[SSHelpLogFileManager alloc] init];
        _fileLogger = [[DDFileLogger alloc] initWithLogFileManager:fileManager];
        //使用自定义的Logformatter
        //_fileLogger.logFormatter = [[SSHelpLogFormatter alloc] init];
        //重用log文件，不要每次启动都创建新的log文件(默认值是NO)
        _fileLogger.doNotReuseLogFiles = NO;
        //log文件在24小时内有效，超过时间创建新log文件(默认值是24小时)
        _fileLogger.rollingFrequency = 60*60*24;
        //log文件的最大3M(默认值1M)
        _fileLogger.maximumFileSize = 1024*1024*1;
        //最多保存7个log文件(默认值是5)
        _fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
        //log文件夹最多保存20M(默认值是20M)
        _fileLogger.logFileManager.logFilesDiskQuota = 1014*1024*20;
    }
    return _fileLogger;
}

@end

