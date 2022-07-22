//
//  SSHelpWebObjcResponse.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpWebObjcResponse : NSObject

/// 快速构建一个成功报文对象
/// @param data @{}
+ (instancetype )successWithData:(NSDictionary *_Nullable)data;

/// 快速构建一个失败报文对象
/// @param error 错误信息
+ (instancetype )failedWithError:(NSString *_Nullable)error;

/// 快速构建一个自定义报文对象
/// @param code 0，1
/// @param data @{}
/// @param error 错误信息
+ (instancetype )responseCode:(NSInteger)code
                         data:(NSDictionary *_Nullable)data
                        error:(NSString *_Nullable)error;

/// 快速构建jsonSting
/// @param code 0，1
/// @param data @{}
/// @param error 错误信息
/// @return eg. "{\"code\":1,\"state\":\"success\",\"data\":{\"imbData\":\"imDaBa64Str\",...}}"
+ (NSString *)jsonStringWithCode:(NSInteger)code
                            data:(NSDictionary *_Nullable)data
                           error:(NSString *_Nullable)error;

/// 整形：0，1
@property(nonatomic, assign) unsigned short int code;

/// 字符型："success"，"failure"
@property(nonatomic, copy) NSString *state;

/// 错误信息
@property(nonatomic, copy) NSString *error;

/// Json串中data字段对应的值. eg. \"data\":{\"imbData\":\"imDaBa64Str\",...}}
@property(nonatomic, strong, nullable) NSDictionary *data;

/// 格式化后的json字符串, eg. "{\"code\":1,\"state\":\"success\",\"data\":{\"imbData\":\"imDaBa64Str\",...}}"
- (NSString *)toJsonString;

@end

NS_ASSUME_NONNULL_END
