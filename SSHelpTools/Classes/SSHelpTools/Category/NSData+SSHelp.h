//
//  NSData+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (SSHelp)

#pragma mark - Hash

/**
 Returns a lowercase NSString for md5 hash.
 */
- (NSString *)ss_md5String;

/**
 Returns an NSData for md5 hash.
 */
- (nullable NSData *)ss_md5Data;

/**
 Returns a lowercase NSString for sha256 hash.
 */
- (NSString *)ss_sha256String;

/**
 Returns an NSData for sha256 hash.
 */
- (NSData *)ss_sha256Data;

#pragma mark - Encode and decode

/**
 Returns string decoded in UTF8.
 */
- (nullable NSString *)ss_utf8String;

/**
 Returns a uppercase NSString in HEX.
 */
- (NSString *)ss_hexString;

/**
 Returns an NSString for base64 encoded.
 */
- (nullable NSString *)ss_base64EncodedString;

/**
 Returns an NSDictionary or NSArray for decoded self.
 Returns nil if an error occurs.
 */
- (nullable id)ss_jsonValueDecoded;

@end

NS_ASSUME_NONNULL_END
