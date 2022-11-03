//
//  SSHelpDefines.m
//  Pods
//
//  Created by 宋直兵 on 2022/6/9.
//

#import "SSHelpDefines.h"

/// 字符串读取
/// @param dict 原始数据
/// @param key 目标字段
NSString *_Nonnull SSEncodeStringFromDict(NSDictionary *dict, NSString *key)
{
    if (SSEqualToNotEmptyDictionary(dict) && SSEqualToNotEmptyString(key)) {
        id value = [dict objectForKey:key];
        if (SSEqualToNotEmpty(value)) {
            if ([value isKindOfClass:[NSString class]]) {
                return value;
            } else if ([value isKindOfClass:[NSNumber class]]) {
                return [value stringValue];
            }
        }
    }
    return @"";
}

/// 字典读取
/// @param dict 原始数据
/// @param key 目标字段
NSDictionary * _Nullable SSEncodeDictFromDict(NSDictionary *dict, NSString *key)
{
    if (SSEqualToNotEmptyDictionary(dict) && SSEqualToNotEmptyString(key)) {
        id value = [dict objectForKey:key];
        if (SSEqualToNotEmptyDictionary(value)) {
            return value;
        }
    }
    return nil;
}

/// 数组读取
/// @param dict 原始数据
/// @param key 目标字段
NSArray * _Nullable SSEncodeArrayFromDict(NSDictionary *dict, NSString *key)
{
    if (SSEqualToNotEmptyDictionary(dict) && SSEqualToNotEmptyString(key)){
        id value = [dict objectForKey:key];
        if (SSEqualToNotEmptyArray(value)) {
            return value;
        }
    }
    return nil;
}

/// 自定义数组读取
/// @param dic 原始数据
/// @param key 目标字段
NSMutableArray * _Nullable SSEncodeArrayFromDictUsingBlock(NSDictionary *dic, NSString *key, id(^usingBlock)(NSDictionary *item))
{
    NSMutableArray *_resultArray = nil;
    NSArray *_temArray = SSEncodeArrayFromDict(dic, key);
    if (SSEqualToNotEmptyArray(_temArray)) {
        _resultArray = [[NSMutableArray alloc] init];
        for (NSInteger index=0; index<[_temArray count]; index++) {
            NSDictionary *_item = _temArray[index];
            if (usingBlock && SSEqualToNotEmptyDictionary(_item)) {
                id _model = usingBlock(_temArray[index]);
                if (SSEqualToNotEmpty(_model)) {
                    [_resultArray addObject:_model];
                }
            }
        }
    }
    return _resultArray;
}

BOOL SSEqualToEmpty(id object)
{
    if (object == nil || [object isEqual:[NSNull null]]) {
        return YES;
    } else if ([object isKindOfClass:[NSString class]]) {
        if ([object isEqualToString:@""] || [object isEqualToString:@"<null>"]) {
            return YES;
        }
    } else if ([object isKindOfClass:[NSArray class]]) {
        if ([object respondsToSelector:@selector(count)]) {
            return 0==[(NSArray *)object count];
        }
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        if ([object respondsToSelector:@selector(allKeys)]) {
            return 0==[(NSArray *)[object allKeys] count];
        }
    } else if ([object isKindOfClass:[NSData class]]) {
        if ([object respondsToSelector:@selector(length)]) {
            return 0==[(NSData *)object length];
        }
    }
    return NO;
}

BOOL SSEqualToNotEmpty(id object)
{
    return !SSEqualToEmpty(object);
}

BOOL SSEqualToNotEmptyString(id string)
{
    if (SSEqualToNotEmpty(string)) {
        if([[string class] isSubclassOfClass:[NSString class]]) {
            return YES;
        }
    }
    return NO;
}

BOOL SSEqualToNotEmptyArray(id array)
{
    if (SSEqualToNotEmpty(array)) {
        if([[array class] isSubclassOfClass:[NSArray class]]) {
            return YES;
        }
    }
    return NO;
}

BOOL SSEqualToNotEmptyDictionary(id dictionary)
{
    if (SSEqualToNotEmpty(dictionary)) {
        if([[dictionary class] isSubclassOfClass:[NSDictionary class]]) {
            return YES;
        }
    }
    return NO;
}

@implementation SSHelpDefines

@end
