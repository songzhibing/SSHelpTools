//
//  NSArray+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/21.
//

#import "NSArray+SSHelp.h"
#import "NSData+SSHelp.h"

@implementation NSArray (SSHelp)

/**
 Convert object to json string. return nil if an error occurs.
 NSString/NSNumber/NSDictionary/NSArray
 */
- (nullable NSString *)ss_jsonStringEncoded
{
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                       options:kNilOptions
                                                         error:NULL];
        if (data) {
            return data.ss_utf8String?:@"";
        }
    }
    return @"";
}

@end
