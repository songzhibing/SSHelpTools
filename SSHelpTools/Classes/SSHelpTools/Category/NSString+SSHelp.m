//
//  NSString+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/17.
//

#import "NSString+SSHelp.h"
#import "NSData+SSHelp.h"

@interface NSString (SSHelp)

- (NSData *)_UTF8Data;

@end

@implementation NSString (SSHelp)

- (NSData *)_UTF8Data
{
    return [self dataUsingEncoding:NSUTF8StringEncoding];
}

#pragma mark - Hash

/**
 Returns a lowercase NSString for md5 hash.
 */
- (NSString *)ss_md5String
{
    if (self.length>0) {
        return self._UTF8Data.ss_md5String?:@"";
    }
    return @"";
}

/**
 Returns a lowercase NSString for sha256 hash.
 */
- (NSString *)ss_sha256String
{
    if (self.length>0) {
        return self._UTF8Data.ss_sha256String?:@"";
    }
    return @"";
}

/**
 Returns a lowercase NSString for sha512 hash.
 */
- (NSString *)ss_sha512String
{
    if (self.length>0) {
        return self._UTF8Data.ss_sha256String?:@"";
    }
    return @"";
}

#pragma mark - Encode and Decode

/**
 Returns an NSString for base64 encoded.
 */
- (NSString *)ss_base64EncodedString
{
    return [self ss_base64EncodedStringWithOptions:kNilOptions];
}

/**
 Returns an NSString for base64 encoded.
 */
- (NSString *)ss_base64EncodedStringWithOptions:(NSDataBase64EncodingOptions)options
{
    //字符串进行UTF-8编码，获得Unicode字符集下的二进制数据。UTF-8是Unicode字符集的编码规则
    if (self._UTF8Data) {
        //将二进制数据进行Base64编码，将不属于ASCII中的可打印字符转换为可打印字符；
        //Base64要求被编码字符是8位(一个字节),所以像中文是不行的(中文是两个字节16位)
        NSString *base64String = [self._UTF8Data base64EncodedStringWithOptions:options];
        return base64String?:@"";
    }
    return @"";
}

/**
 Returns a Base64 decoded NSString.
 */
- (NSString *)ss_base64DecodedString
{
    NSDataBase64DecodingOptions options = NSDataBase64DecodingIgnoreUnknownCharacters;
    if (self.length>0) {
        NSData *data = [[NSData alloc] initWithBase64EncodedString:self options:options];
        if (data) {
            return data.ss_utf8String?:@"";
        }
    }
    return @"";
}

/**
 URL encode a string in utf-8.
 @return the encoded string.
 */
- (NSString *)ss_stringByURLEncode
{
    if ([self respondsToSelector:@selector(stringByAddingPercentEncodingWithAllowedCharacters:)]) {
        /**
         AFNetworking/AFURLRequestSerialization.m
         
         Returns a percent-escaped string following RFC 3986 for a query string key or value.
         RFC 3986 states that the following characters are "reserved" characters.
            - General Delimiters: ":", "#", "[", "]", "@", "?", "/"
            - Sub-Delimiters: "!", "$", "&", "'", "(", ")", "*", "+", ",", ";", "="
         In RFC 3986 - Section 3.4, it states that the "?" and "/" characters should not be escaped to allow
         query strings to include a URL. Therefore, all "reserved" characters with the exception of "?" and "/"
         should be percent-escaped in the query string.
            - parameter string: The string to be percent-escaped.
            - returns: The percent-escaped string.
         */
        static NSString * const kAFCharactersGeneralDelimitersToEncode = @":#[]@"; // does not include "?" or "/" due to RFC 3986 - Section 3.4
        static NSString * const kAFCharactersSubDelimitersToEncode = @"!$&'()*+,;=";
        
        NSMutableCharacterSet * allowedCharacterSet = [[NSCharacterSet URLQueryAllowedCharacterSet] mutableCopy];
        [allowedCharacterSet removeCharactersInString:[kAFCharactersGeneralDelimitersToEncode stringByAppendingString:kAFCharactersSubDelimitersToEncode]];
        static NSUInteger const batchSize = 50;
        
        NSUInteger index = 0;
        NSMutableString *escaped = @"".mutableCopy;
        
        while (index < self.length) {
            NSUInteger length = MIN(self.length - index, batchSize);
            NSRange range = NSMakeRange(index, length);
            // To avoid breaking up character sequences such as 👴🏻👮🏽
            range = [self rangeOfComposedCharacterSequencesForRange:range];
            NSString *substring = [self substringWithRange:range];
            NSString *encoded = [substring stringByAddingPercentEncodingWithAllowedCharacters:allowedCharacterSet];
            [escaped appendString:encoded];
            
            index += range.length;
        }
        return escaped?:@"";
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding cfEncoding = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *encoded = (__bridge_transfer NSString *)
        CFURLCreateStringByAddingPercentEscapes(
                                                kCFAllocatorDefault,
                                                (__bridge CFStringRef)self,
                                                NULL,
                                                CFSTR("!#$&'()*+,/:;=?@[]"),
                                                cfEncoding);
        return encoded?:@"";
#pragma clang diagnostic pop
    }
}

/**
 URL decode a string in utf-8.
 @return the decoded string.
 */
- (NSString *)ss_stringByURLDecode
{
    if ([self respondsToSelector:@selector(stringByRemovingPercentEncoding)]) {
        return [self stringByRemovingPercentEncoding]?:@"";
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        CFStringEncoding en = CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding);
        NSString *decoded = [self stringByReplacingOccurrencesOfString:@"+"
                                                            withString:@" "];
        decoded = (__bridge_transfer NSString *)
        CFURLCreateStringByReplacingPercentEscapesUsingEncoding(
                                                                NULL,
                                                                (__bridge CFStringRef)decoded,
                                                                CFSTR(""),
                                                                en);
        return decoded?:@"";
#pragma clang diagnostic pop
    }
}

#pragma mark - Utilities

/**
 Returns an NSDictionary/NSArray which is decoded from receiver.
 Returns nil if an error occurs.
 
 e.g. NSString: @"{\"name\":\"a\",\"count\":2}" => __NSDictionaryI: @{@"name":@"a",@"count":@2}
 
 e.g. NSString: @"[{\"name\":\"a\",\"count\":2}]" => __NSSingleObjectArrayI: @[@{@"name":@"a",@"count":@2}]
 
 e.g. NSString: @"[\"name\",\"coount\"]"  => __NSArrayI: @[@"name",@"count"]
 */
- (nullable id)ss_jsonValueDecoded
{
    if (self.length>0) {
        return self._UTF8Data.ss_jsonValueDecoded;
    }
    return nil;
}

 /**
  Usually, we just want to return data of dictionary type.  Returns @{} if an error occurs.
  */
 - (nonnull NSDictionary *)ss_toDictionary;
{
    id result = [self ss_jsonValueDecoded];
    if (result && [result isKindOfClass:[NSDictionary class]]) {
        return  result;
    }
    return @{};
}

@end
