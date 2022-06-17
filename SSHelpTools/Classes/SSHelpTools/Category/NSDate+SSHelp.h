//
//  NSDate+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/19.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (SSHelp)

/// Convenience method that returns a formatted string representing the receiver's date formatted to a given date format, time zone, locale and calendar
/// @param format   NSString - String representing the desired date format
/// @param timeZone NSTimeZone - Desired time zone， default by GMT+0800
/// @param locale   NSLocale - Desired locale,  default by en_US_POSIX
/// @param calendar NSCalendar - Desired calendar,  default by NSCalendarIdentifierISO8601
- (NSString *)ss_formattedDateWithFormat:(NSString *)format
                                timeZone:(NSTimeZone * _Nullable)timeZone
                                  locale:(NSLocale * _Nullable)locale
                                calendar:(NSCalendar * _Nullable)calendar;

/// 今天 yyyyMMdd
+ (NSString *)ss_day;

/// 现在 yyyyMMddHHmmss
+ (NSString *)ss_now;

@end

NS_ASSUME_NONNULL_END
