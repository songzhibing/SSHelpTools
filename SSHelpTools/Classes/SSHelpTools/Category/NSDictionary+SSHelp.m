//
//  NSDictionary+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/21.
//

#import "NSDictionary+SSHelp.h"
#import "NSData+SSHelp.h"

@implementation NSDictionary (SSHelp)

/**
 Convert dictionary to json string. return "" if an error occurs.
 */
- (NSString *)ss_jsonStringEncoded
{
    if ([NSJSONSerialization isValidJSONObject:self])
    {
        NSJSONWritingOptions opt = kNilOptions;
        if (@available(iOS 11.0, *)) {
            opt = NSJSONWritingSortedKeys;
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:self
                                                       options:opt
                                                         error:NULL];
        if (data) {
            return data.ss_utf8String?:@"";
        }
    }
    return @"";
}

@end
