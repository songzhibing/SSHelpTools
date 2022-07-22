//
//  NSKeyedUnarchiver+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/24.
//

#import "NSKeyedUnarchiver+SSHelp.h"

@implementation NSKeyedUnarchiver (SSHelp)

+ (NSData *)ss_archivedDataWithRootObject:(id)rootObject
{
    if (@available(iOS 11.0, *)) {
        return [NSKeyedArchiver archivedDataWithRootObject:rootObject requiringSecureCoding:YES error:NULL];
    } else {
        return [NSKeyedArchiver archivedDataWithRootObject:rootObject];
    }
}

+ (nullable id)ss_unarchiveObjectWithData:(NSData *)data
{
    if (@available(iOS 11.0, *)) {
        return  [NSKeyedUnarchiver unarchivedObjectOfClass:[NSObject class] fromData:data error:NULL];
    } else {
        return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
}

@end
