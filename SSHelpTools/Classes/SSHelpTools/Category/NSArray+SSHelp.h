//
//  NSArray+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (SSHelp)

/**
 Convert object to json string. return nil if an error occurs.
 NSString/NSNumber/NSDictionary/NSArray
 */
- (nullable NSString *)ss_jsonStringEncoded;

@end

NS_ASSUME_NONNULL_END
