//
//  NSObject+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "NSObject+SSHelp.h"

/// 字符串读取
/// @param dict 原始数据
/// @param key 目标字段
NSString *_Nonnull SSEncodeStringFromDict(NSDictionary *dict, NSString *key)
{
    if ([NSObject ss_isNotEmptyDictionary:dict] &&
        [NSObject ss_isNotEmptySting:key])
    {
        id value = [dict objectForKey:key];
        if ([NSObject ss_isNotEmpty:value])
        {
            if ([value isKindOfClass:[NSString class]])
            {
                return value;
            }
            else if ([value isKindOfClass:[NSNumber class]])
            {
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
    if ([NSObject ss_isNotEmptyDictionary:dict] && [NSObject ss_isNotEmptySting:key])
    {
        id value = [dict objectForKey:key];
        if ([NSObject ss_isNotEmptyDictionary:value])
        {
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
    if ([NSObject ss_isNotEmptyDictionary:dict] &&
        [NSObject ss_isNotEmptySting:key])
    {
        id value = [dict objectForKey:key];
        if ([NSObject ss_isNotEmptyArray:value])
        {
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
    NSArray *_temArray = SSEncodeArrayFromDict(dic, key);
    if ([NSObject ss_isNotEmptyArray:_temArray])
    {
        NSMutableArray *_resultArray = [NSMutableArray arrayWithCapacity:[_temArray count]];
        for (NSInteger index=0; index<[_temArray count]; index++)
        {
            NSDictionary *_item = _temArray[index];
            if (usingBlock && [NSObject ss_isNotEmptyDictionary:_item])
            {
                id _model = usingBlock(_temArray[index]);
                if ([NSObject ss_isNotEmpty:_model])
                {
                    [_resultArray addObject:_model];
                }
            }
        }
        return _resultArray;
    }
    return nil;
}

@implementation NSObject (SSHelp)

/// 判断对象是否为空
/// 常见的：nil、NSNull、@""、@"<null>"、@[]、@{}、0Data
/// @param object 判断目标
/// @return YES 为空  NO 为实例对象
+ (BOOL)ss_isEmpty:(id)object
{
    if (object == nil || [object isEqual:[NSNull null]])
    {
        return YES;
    }
    else if ([object isKindOfClass:[NSString class]])
    {
        if ([object isEqualToString:@""] || [object isEqualToString:@"<null>"]) {
            return YES;
        }
    }
    else if ([object isKindOfClass:[NSArray class]])
    {
        if ([object respondsToSelector:@selector(count)])
        {
            return 0==[object count];
        }
    }
    else if ([object isKindOfClass:[NSDictionary class]])
    {
        if ([object respondsToSelector:@selector(allKeys)])
        {
            return 0==[object allKeys];
        }
    }
    else if ([object isKindOfClass:[NSData class]])
    {
        if ([object respondsToSelector:@selector(length)])
        {
            return 0==[object length];
        }
    }
    return NO;
}

/// 判断对象是否不为空
/// @param object 判断目标
/// @return YES 为实例对象  NO 为空
+ (BOOL)ss_isNotEmpty:(id)object
{
    return (NO == [self ss_isEmpty:object]);
}

/// 非空字符串
/// @param string 判断目标
/// @return YES非空字符串  NO空字符串
+ (BOOL)ss_isNotEmptySting:(id)string
{
    if ([self ss_isNotEmpty:string])
    {
        if([[string class] isSubclassOfClass:[NSString class]])
        {
            return YES;
        }
    }
    return NO;
}

/// 非空数组
/// @param array 判断目标
/// @return YES非空数组  NO空数组
+ (BOOL)ss_isNotEmptyArray:(id)array
{
    if ([self ss_isNotEmpty:array])
    {
        if([[array class] isSubclassOfClass:[NSArray class]])
        {
            return YES;
        }
    }
    return NO;
}

/// 非空字典
/// @param dictionary 判断目标
/// @return YES非空字典  NO空字典
+ (BOOL)ss_isNotEmptyDictionary:(id)dictionary
{
    if ([self ss_isNotEmpty:dictionary])
    {
        if([[dictionary class] isSubclassOfClass:[NSDictionary class]])
        {
            return YES;
        }
    }
    return NO;
}

@end
