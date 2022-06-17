//
//  NSDate+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/19.
//

#import "NSDate+SSHelp.h"

@implementation NSDate (SSHelp)

/// Convenience method that returns a formatted string representing the receiver's date formatted to a given date format, time zone, locale and calendar
/// @param format   NSString - String representing the desired date format
/// @param timeZone NSTimeZone - Desired time zone， default by GMT+0800
/// @param locale   NSLocale - Desired locale,  default by en_US_POSIX
/// @param calendar NSCalendar - Desired calendar,  default by NSCalendarIdentifierISO8601
- (NSString *)ss_formattedDateWithFormat:(NSString *)format
                                timeZone:(NSTimeZone * _Nullable)timeZone
                                  locale:(NSLocale * _Nullable)locale
                                calendar:(NSCalendar * _Nullable)calendar
{
    static NSDateFormatter *formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
    });

    [formatter setDateFormat:format];
    [formatter setTimeZone:timeZone?:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"]];
    [formatter setLocale:locale?:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    [formatter setCalendar:calendar?:[[NSCalendar  alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601]];
    return [formatter stringFromDate:self];
}

/// 今天
+ (NSString *)ss_day
{
    return [[NSDate date] ss_formattedDateWithFormat:@"yyyyMMdd" timeZone:nil locale:nil calendar:nil];
}

/// 现在
+ (NSString *)ss_now
{
    return [[NSDate date] ss_formattedDateWithFormat:@"yyyyMMddHHmmss" timeZone:nil locale:nil calendar:nil];
}



@end
