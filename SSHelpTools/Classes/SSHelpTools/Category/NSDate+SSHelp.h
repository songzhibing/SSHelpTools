//
//  NSDate+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString *_kNSDateFormatFullDateWithTime    = @"MMM d, yyyy h:mm a";
static NSString *_kNSDateFormatFullDate            = @"MMM d, yyyy";
static NSString *_kNSDateFormatShortDateWithTime   = @"MMM d h:mm a";
static NSString *_kNSDateFormatShortDate           = @"MMM d";
static NSString *_kNSDateFormatWeekday             = @"EEEE";
static NSString *_kNSDateFormatWeekdayWithTime     = @"EEEE h:mm a";
static NSString *_kNSDateFormatTime                = @"h:mm a";
static NSString *_kNSDateFormatTimeWithPrefix      = @"'at' h:mm a";
static NSString *_kNSDateFormatSQLDate             = @"yyyy-MM-dd";
static NSString *_kNSDateFormatSQLDay              = @"yyyyMMdd";
static NSString *_kNSDateFormatSQLTime             = @"HH:mm:ss";
static NSString *_kNSDateFormatSQLDateWithTime     = @"yyyy-MM-dd HH:mm:ss";

@interface NSDate (SSHelp)

/// 默认时间格式 时区'GMT+0800'+地区'zh_CN'+公历'NSCalendarIdentifierGregorian'
+ (NSDateFormatter *)ss_dateFormatter;

/// 字符串转时间
+ (NSDate *)ss_dateFromString:(NSString *)string withFormat:(NSString *)format;

/// 时间转字符串
+ (NSString *)ss_stringFromDate:(NSDate *)date withFormat:(NSString *)format;

/// Convenience method that returns a formatted string representing the receiver's date formatted to a given date format, time zone, locale and calendar
/// @param format   NSString - String representing the desired date format
/// @param timeZone NSTimeZone - Desired time zone， default by 'GMT+0800'
/// @param locale   NSLocale - Desired locale,  default by 'zh_CN'
/// @param calendar NSCalendar - Desired calendar,  default by 'NSCalendarIdentifierGregorian'
- (NSString *)ss_stringWithFormat:(NSString *)format timeZone:(NSTimeZone * _Nullable)timeZone locale:(NSLocale * _Nullable)locale calendar:(NSCalendar * _Nullable)calendar;

/// 当前时分秒 yyyyMMddHHmmss
+ (NSString *)ss_currentTime;

@end

NS_ASSUME_NONNULL_END
