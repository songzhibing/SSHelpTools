//
//  NSObject+SSHelp.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <objc/message.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (SSHelp)

+ (void)ss_enumerateClassUsingBlock:(void (^)(Class class, BOOL * stop))block;

+ (void)ss_enumeratePropertyUsingBlock:(void (^)(objc_property_t property, NSUInteger index, BOOL * stop))block;

+ (void)ss_enumeratePropertyNameUsingBlock:(void (^)(NSString *propertyName, NSUInteger index, BOOL *stop))block;

@end

NS_ASSUME_NONNULL_END
