//
//  SSHelpDefines.h
//  Pods
//
//  Created by 宋直兵 on 2022/6/9.
//

#import <Foundation/Foundation.h>
#import "SSHelpMetamacros.h"
#import "SSHelpToolsConfig.h"
#import "UIColor+SSHelp.h"
#import "NSDate+SSHelp.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^ _Nullable SSBlockVoid)(void);
typedef void(^ _Nullable SSBlockInt )(int number);
typedef void(^ _Nullable SSBlockBool)(BOOL success);
typedef void(^ _Nullable SSBlockDict)(__kindof NSDictionary * _Nullable dict);
typedef void(^ _Nullable SSBlockString)(__kindof NSString * _Nullable string);

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

/// 判断是空， 如：nil、Nil、NSNull、@""、@"<null>"、@[]、@{}、0Data
FOUNDATION_EXTERN BOOL SSEqualToEmpty(id object);

/// 非空对象
FOUNDATION_EXTERN BOOL SSEqualToNotEmpty(id object);

/// 非空字符串
FOUNDATION_EXTERN BOOL SSEqualToNotEmptyString(id string);

/// 非空数组
FOUNDATION_EXTERN BOOL SSEqualToNotEmptyArray(id array);

/// 非空字典
FOUNDATION_EXTERN BOOL SSEqualToNotEmptyDictionary(id dictionary);

//缩写

#define _kApplicationWindow    ([SSHelpToolsConfig sharedConfig].window)

#define _kGetImage(imageName)  [UIImage imageNamed:[NSString stringWithFormat:@"%@",imageName]]

#define _kDeviceSystemVersion  ([[UIDevice currentDevice] systemVersion])

#define _kAppVersion           ([[[NSBundle mainBundle] infoDictionary] \
                                    objectForKey:@"CFBundleShortVersionString"])

#define _kRetainCount(obj)     (CFGetRetainCount((__bridge CFTypeRef)(obj))) /// 引用计数值

#define _kUserDefaults         [NSUserDefaults standardUserDefaults]

#define _kNotificationCenter   [NSNotificationCenter defaultCenter]

//设备

#define _kDeviceIsiPad ([UIDevice currentDevice].userInterfaceIdiom==UIUserInterfaceIdiomPad)

#define _kScreenWidth  (MIN([UIScreen mainScreen].bounds.size.width, \
                            [UIScreen mainScreen].bounds.size.height)) //支持横竖屏

#define _kScreenHeight (MAX([UIScreen mainScreen].bounds.size.width, \
                            [UIScreen mainScreen].bounds.size.height)) //支持横竖屏

#define _kStatusBarHeight (CGRectGetHeight([UIApplication sharedApplication].statusBarFrame))

#define _kNavBarHeight    (44.f)

#define _kToolBarHeight   (49.f)

#define _kHomeIndicatorHeight  ([SSHelpToolsConfig sharedConfig].homeIndicatorHeight) //"home键"高度

//颜色

#define _kColorRGB(R, G, B)      [UIColor colorWithRed:(R)/255.0 \
                                                 green:(G)/255.0 \
                                                  blue:(B)/255.0 \
                                                 alpha:(1.0)]

#define _kColorRGBA(R, G, B, A)  [UIColor colorWithRed:(R)/255.0 \
                                                 green:(G)/255.0 \
                                                  blue:(B)/255.0 \
                                                 alpha:(A)]

#define _kColorFromHexRGB(hexString)      [UIColor ss_colorWithHexString:hexString alpha:1]

#define _kColorFromHexRGBA(hexString, a)  [UIColor ss_colorWithHexString:hexString alpha:a]

#define _kColorFromHexNumber(hexNumber)   [UIColor ss_colorWithHex:hexNumber alpha:1]

#define _kRandomColor  [[UIColor ss_randomColor] colorWithAlphaComponent:0.75f]

#define _kClearColor   [UIColor clearColor]

//GCD

#ifndef dispatch_main_async_safe
    #define dispatch_main_async_safe(block)\
        if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
            block();\
        } else {\
            dispatch_async(dispatch_get_main_queue(), block);\
        }
#endif

#ifndef dispatch_global_queue_safe
    #define dispatch_global_queue_safe(block) \
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
#endif

/******************************************************************************/
/******************************************************************************/

//日志

#ifdef DEBUG
    #define SSLog(fmt, ...) @autoreleasepool { (void)fprintf(stderr,"\n[SSLOG][%s][%s:%d] %s\n", [[NSDate ss_stringFromDate:[NSDate date] withFormat:@"yyyy-MM-dd HH:mm:ss.SSS Z"] UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]); };
#else
    #define SSLog(...) @{};
#endif

#define SSToolsLog(fmt, ...) @autoreleasepool { ([SSHelpToolsConfig sharedConfig].enableLog)?((void)fprintf(stderr,"\n[SSTOOLSLOG][%s][%s:%d] %s\n", [[NSDate ss_stringFromDate:[NSDate date] withFormat:@"yyyy-MM-dd HH:mm:ss.SSS Z"] UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String])):(NULL); };

// WKWebView日志
#define SSWebLog(fmt, ...) @autoreleasepool { ([SSHelpToolsConfig sharedConfig].enableLog)?((void)fprintf(stderr,"\n[SSWEBLOG][%s][%s:%d] %s\n", [[NSDate ss_stringFromDate:[NSDate date] withFormat:@"yyyy-MM-dd HH:mm:ss.SSS Z"] UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String])):(NULL); };

#define SSLifeCycleLog(fmt, ...) @autoreleasepool { ([SSHelpToolsConfig sharedConfig].enableLifeCycleLog)?((void)fprintf(stderr,"\n[SSLIFELOG][%s][%s:%d] %s\n", [[NSDate ss_stringFromDate:[NSDate date] withFormat:@"yyyy-MM-dd HH:mm:ss.SSS Z"] UTF8String],[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String])):(NULL); };

//文件

#define _kTempPath      NSTemporaryDirectory()

#define _kDocumentPath  [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,\
                            NSUserDomainMask, YES) firstObject]

#define _kCachePath     [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, \
                            NSUserDomainMask, YES) firstObject]

#define _kLibPath       [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,\
                            NSUserDomainMask,YES) firstObject]

//__weak && __strong

#ifndef weakify // 该宏在YYKit、ReactiveObjC、...  等内部都含有
    #define weakify(...) \
        ss_keywordify \
        metamacro_foreach_cxt(ss_weakify_,, __weak, __VA_ARGS__)
#endif

#ifndef strongify
    #define strongify(...) \
        ss_keywordify \
        _Pragma("clang diagnostic push") \
        _Pragma("clang diagnostic ignored \"-Wshadow\"") \
        metamacro_foreach(ss_strongify_,, __VA_ARGS__) \
        _Pragma("clang diagnostic pop")
#endif

// 为了消除 Ambiguous expansion of macro 'weakify' 警告，增加变体
#define Tweakify(...) \
    ss_keywordify \
    metamacro_foreach_cxt(ss_weakify_,, __weak, __VA_ARGS__)

#define Tstrongify(...) \
    ss_keywordify \
    _Pragma("clang diagnostic push") \
    _Pragma("clang diagnostic ignored \"-Wshadow\"") \
    metamacro_foreach(ss_strongify_,, __VA_ARGS__) \
    _Pragma("clang diagnostic pop")


#if DEBUG
    #define ss_keywordify autoreleasepool {}
#else
    #define ss_keywordify try {} @catch (...) {}
#endif

#define ss_weakify_(INDEX, CONTEXT, VAR) \
    CONTEXT __typeof__(VAR) metamacro_concat(VAR, _weak_) = (VAR);

#define ss_strongify_(INDEX, VAR) \
    __strong __typeof__(VAR) VAR = metamacro_concat(VAR, _weak_);

//函数

#define _kDegreesToRadian(degrees)  (M_PI * (degrees) / 180.0) //角度转换弧度

#define _kRadianToDegrees(radian)   (radian*180.0)/(M_PI) //弧度转换角度

//Other

#define _kRandSixValue [NSString stringWithFormat:@"%06d",arc4random() % 100000]

@interface SSHelpDefines : NSObject

@end

NS_ASSUME_NONNULL_END
