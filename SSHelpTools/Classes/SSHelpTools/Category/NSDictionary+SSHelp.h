//
//  NSDictionary+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (SSHelp)

- (NSData * _Nullable)ss_jsonDataEncoded;

/**
 Convert dictionary to json string. return "" if an error occurs.
 */
- (NSString *)ss_jsonStringEncoded;

@end

NS_ASSUME_NONNULL_END
