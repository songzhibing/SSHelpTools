//
//  NSDate+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/19.
//

#import "NSDate+SSHelp.h"

@implementation NSDate (SSHelp)

+ (NSDateFormatter *)ss_dateFormatter
{
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        //时区
        [dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
        //地区
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        //公历
        [dateFormatter setCalendar:[[NSCalendar  alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian]];
    });
    return dateFormatter;
}

/// 字符串转时间
+ (NSDate *)ss_dateFromString:(NSString *)string withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [self ss_dateFormatter];
    [formatter setDateFormat:format];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

/// 时间转字符串
+ (NSString *)ss_stringFromDate:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *formatter = [self ss_dateFormatter];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

/// Convenience method that returns a formatted string representing the receiver's date formatted to a given date format, time zone, locale and calendar
/// @param format   NSString - String representing the desired date format
/// @param timeZone NSTimeZone - Desired time zone， default by GMT+0800
/// @param locale   NSLocale - Desired locale,  default by en_US_POSIX
/// @param calendar NSCalendar - Desired calendar,  default by NSCalendarIdentifierISO8601
- (NSString *)ss_stringWithFormat:(NSString *)format timeZone:(NSTimeZone * _Nullable)timeZone locale:(NSLocale * _Nullable)locale calendar:(NSCalendar * _Nullable)calendar;
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setTimeZone:timeZone?:[NSDate ss_dateFormatter].timeZone];
    [formatter setLocale:locale?:[NSDate ss_dateFormatter].locale];
    [formatter setCalendar:calendar?:[NSDate ss_dateFormatter].calendar];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:self];
}

+ (NSString *)ss_currentTime
{
    NSString *timeString = [NSDate ss_stringFromDate:[NSDate dateWithTimeIntervalSinceReferenceDate:[NSDate timeIntervalSinceReferenceDate]] withFormat:@"yyyyMMddHHmmss"];
    return timeString;
}

/// 格式化秒数  60s -> 00:01:00
+ (NSString *)ss_formatSeconds:(NSInteger)totalSeconds
{
    NSInteger hour = totalSeconds / 3600;
    NSInteger minute = (totalSeconds % 3600) / 60;
    NSInteger second = (totalSeconds % 3600) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", hour, minute, second];
}

@end
