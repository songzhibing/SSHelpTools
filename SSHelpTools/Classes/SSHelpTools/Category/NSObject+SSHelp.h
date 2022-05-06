//
//  NSObject+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 字符串读取
/// @param dict 原始数据
/// @param key 目标字段
FOUNDATION_EXTERN NSString * _Nonnull SSEncodeStringFromDict(NSDictionary *dict, NSString *key);

/// 字典读取
/// @param dict 原始数据
/// @param key 目标字段
FOUNDATION_EXTERN NSDictionary * _Nullable SSEncodeDictFromDict(NSDictionary *dict, NSString *key);

/// 数组读取
/// @param dict 原始数据
/// @param key 目标字段
FOUNDATION_EXTERN NSArray * _Nullable SSEncodeArrayFromDict(NSDictionary *dict, NSString *key);

/// 自定义数组读取
/// @param dic 原始数据
/// @param key 目标字段
FOUNDATION_EXTERN NSArray * _Nullable SSEncodeArrayFromDictUsingBlock(NSDictionary *dic, NSString *key, id(^usingBlock)(NSDictionary *item));


@interface NSObject (SSHelp)

/// 判断对象是否为空
/// 常见的：nil、NSNull、@""、@"<null>"、@[]、@{}、0Data
/// @param object 判断目标
/// @return YES 为空  NO 为非空对象
+ (BOOL)ss_isEmpty:(id)object;

/// 判断对象是否不为空
/// @param object 判断目标
/// @return YES 为非空对象  NO 为空
+ (BOOL)ss_isNotEmpty:(id)object;

/// 非空字符串
/// @param string 判断目标
/// @return YES非空字符串  NO空字符串
+ (BOOL)ss_isNotEmptySting:(id)string;

/// 非空数组
/// @param array 判断目标
/// @return YES非空数组  NO空数组
+ (BOOL)ss_isNotEmptyArray:(id)array;

/// 非空字典
/// @param dictionary 判断目标
/// @return YES非空字典  NO空字典
+ (BOOL)ss_isNotEmptyDictionary:(id)dictionary;

@end

NS_ASSUME_NONNULL_END
