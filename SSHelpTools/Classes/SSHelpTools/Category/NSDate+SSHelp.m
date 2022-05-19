//
//  NSDate+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/19.
//

#import "NSDate+SSHelp.h"

@implementation NSDate (SSHelp)

/// 当前时间字符串 @"yyyyMMdd"
+ (NSString *)ss_nowDate
{
    static NSDateFormatter *formatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [NSDateFormatter new];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        formatter.calendar = [[NSCalendar  alloc] initWithCalendarIdentifier:NSCalendarIdentifierISO8601];
        formatter.dateFormat = @"yyyyMMdd";
    });
    return [formatter stringFromDate:NSDate.date];
}

@end
