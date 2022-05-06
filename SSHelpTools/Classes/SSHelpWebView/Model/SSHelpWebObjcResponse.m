//
//  SSHelpWebObjcResponse.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/10.
//

#import "SSHelpWebObjcResponse.h"
#import <SSHelpTools/NSDictionary+SSHelp.h>

@implementation SSHelpWebObjcResponse

/// 快速构建一个成功报文对象
/// @param data @{}
+ (instancetype )successWithData:(NSDictionary *_Nullable)data
{
    SSHelpWebObjcResponse *_response = [[SSHelpWebObjcResponse alloc] init];
    _response.code = 1;
    _response.data = data;
    return _response;
}

/// 快速构建一个失败报文对象
/// @param error 错误信息
+ (instancetype )failedWithError:(NSString *_Nullable)error
{
    SSHelpWebObjcResponse *_response = [[SSHelpWebObjcResponse alloc] init];
    _response.code = 0;
    _response.error = error;
    return _response;
}

/// 快速构建一个自定义报文对象
/// @param code 0，1
/// @param data @{}
/// @param error 错误信息
+ (instancetype )responseCode:(NSInteger)code
                         data:(NSDictionary *_Nullable)data
                        error:(NSString *_Nullable)error
{
    SSHelpWebObjcResponse *_response = [[SSHelpWebObjcResponse alloc] init];
    _response.code = code;
    _response.data = data;
    _response.error = error;
    return _response;
}

/// 快速构建jsonSting
/// @param code 0，1
/// @param data success，failure
/// @param error 错误信息
+ (NSString *)jsonStringWithCode:(NSInteger)code
                            data:(NSDictionary *_Nullable)data
                           error:(NSString *_Nullable)error
{
    SSHelpWebObjcResponse *_response = [[SSHelpWebObjcResponse alloc] init];
    _response.code = code;
    _response.data = data;
    _response.error = error;
    return _response.finalJsonString;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _code = 0;
        _state = @"failure";
    }
    return self;
}

- (NSString *)finalJsonString
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    if (self.code==1) {
        [dict setValue:[NSNumber numberWithInteger:1] forKey:@"code"];
        [dict setValue:@"success" forKey:@"state"];
    }else{
        [dict setValue:[NSNumber numberWithInteger:0] forKey:@"code"];
        [dict setValue:@"failure" forKey:@"state"];
    }
    
    if (_error && [_error isKindOfClass:[NSString class]]) {
        [dict setValue:_error forKey:@"error"];
    }
    
    if (_data && [_data isKindOfClass:[NSDictionary class]]) {
        [dict setValue:_data forKey:@"data"];
    }
    
    NSString *jsonString = [dict ss_jsonStringEncoded];
    return jsonString?:@"";
}



@end
