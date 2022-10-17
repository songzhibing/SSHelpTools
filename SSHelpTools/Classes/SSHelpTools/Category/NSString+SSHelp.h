//
//  NSString+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/17.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (SSHelp)

#pragma mark - Hash

/**
 Returns a lowercase NSString for md5 hash.
 */
- (NSString *)ss_md5String;

/**
 Returns a lowercase NSString for sha256 hash.
 */
- (NSString *)ss_sha256String;

/**
 Returns a lowercase NSString for sha512 hash.
 */
- (NSString *)ss_sha512String;

#pragma mark - Encode and Decode

/**
 Returns an NSString for base64 encoded.
 */
- (NSString *)ss_base64EncodedString;

/**
 Returns an NSString for base64 encoded.
 */
- (NSString *)ss_base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)options;

/**
 Returns a Base64 decoded NSString.
 */
- (NSString *)ss_base64DecodedString;

/**
 URL encode a string in utf-8.
 @return the encoded string.
 */
- (NSString *)ss_stringByURLEncode;

/**
 URL decode a string in utf-8.
 @return the decoded string.
 */
- (NSString *)ss_stringByURLDecode;

#pragma mark - Utilities

/**
 Returns an NSDictionary/NSArray which is decoded from receiver.
 Returns nil if an error occurs.
 
 e.g. NSString: @"{\"name\":\"a\",\"count\":2}" => __NSDictionaryI: @{@"name":@"a",@"count":@2}
 
 e.g. NSString: @"[{\"name\":\"a\",\"count\":2}]" => __NSSingleObjectArrayI: @[@{@"name":@"a",@"count":@2}]
 
 e.g. NSString: @"[\"name\",\"coount\"]"  => __NSArrayI: @[@"name",@"count"]
 */
- (nullable id)ss_jsonValueDecoded;

/**
 Usually, we just want to return data of dictionary type.  Returns @{} if an error occurs.
 */
- (nonnull NSDictionary *)ss_toDictionary;

/**
 是否包含中文
 */
- (BOOL)ss_containChinese;

@end

NS_ASSUME_NONNULL_END
