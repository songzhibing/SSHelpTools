//
//  SSHelpToolsTests.m
//  SSHelpToolsTests
//
//  Created by 宋直兵 on 12/17/2021.
//  Copyright (c) 2021 宋直兵. All rights reserved.
//

@import XCTest;
#import <SSHelpTools/SSHelpTools.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    XCTFail(@"No implementation for \"%s\"", __PRETTY_FUNCTION__);
}

- (void)testApi
{
    
    NSString *str = @"2020-12-30";
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = locale;
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    
//    NSString *str = @"{\"name\":\"a\",\"count\":2}";
//    id result = str.ss_jsonValueDecoded;
//    NSLog(@"\n===\n%@\n===\n",result);
//
//    NSArray *arr = @[@{@"name":@"a",@"count":@2}];
//    NSString *arrStr = arr.ss_jsonStringEncoded;
//    result = arrStr.ss_jsonValueDecoded;
//    NSLog(@"\n===\n%@\n===\n",result);
//
//    arr = @[@"name",@"coount"];
//    arrStr = arr.ss_jsonStringEncoded;
//    result = arrStr.ss_jsonValueDecoded;
//    NSLog(@"\n===\n%@\n===\n",result);
}

@end

