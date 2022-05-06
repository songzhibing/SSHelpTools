//
//  NSData+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/21.
//

#import "NSData+SSHelp.h"
#include <CommonCrypto/CommonCrypto.h>

@implementation NSData (SSHelp)

#pragma mark - Hash

/**
 Returns a lowercase NSString for md5 hash.
 */
- (NSString *)ss_md5String
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

/**
 Returns an NSData for md5 hash.
 */
- (NSData *)ss_md5Data
{
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(self.bytes, (CC_LONG)self.length, result);
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

/**
 Returns a lowercase NSString for sha256 hash.
 */
- (NSString *)ss_sha256String
{
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, result);
    NSMutableString *hash = [NSMutableString
                             stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [hash appendFormat:@"%02x", result[i]];
    }
    return hash;
}

/**
 Returns an NSData for sha256 hash.
 */
- (NSData *)ss_sha256Data
{
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(self.bytes, (CC_LONG)self.length, result);
    return [NSData dataWithBytes:result length:CC_SHA256_DIGEST_LENGTH];
}

#pragma mark - Encode and decode

/**
 Returns string decoded in UTF8.
 */
- (nullable NSString *)ss_utf8String
{
    if (self.length > 0) {
        return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
    }
    return @"";
}

/**
 Returns a uppercase NSString in HEX.
 */
- (NSString *)ss_hexString
{
    NSUInteger length = self.length;
    NSMutableString *result = [NSMutableString stringWithCapacity:length * 2];
    const unsigned char *byte = self.bytes;
    for (int i = 0; i < length; i++, byte++) {
        [result appendFormat:@"%02X", *byte];
    }
    return result;
}

/**
 Returns an NSString for base64 encoded.
 */
- (nullable NSString *)ss_base64EncodedString
{
    if (self.length > 0) {
        return [self base64EncodedStringWithOptions:kNilOptions];
    }
    return @"";
}

/**
 Returns an NSDictionary or NSArray for decoded self.
 Returns nil if an error occurs.
 */
- (nullable id)ss_jsonValueDecoded
{
    id value = [NSJSONSerialization JSONObjectWithData:self options:kNilOptions error:NULL];
    return value;
}

@end
