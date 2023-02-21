//
//  NSObject+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import "NSObject+SSHelp.h"

@implementation NSObject (SSHelp)

+ (void)ss_enumerateClassUsingBlock:(void (^)(Class class, BOOL *stop))block
{
    __block BOOL stop = NO;
    Class class = [self class];
    while (class && !stop) {
        if ([NSObject class] == class) {
            // 已经是根类了
            stop = YES;
            break;
        }
        block(class, &stop);
        class = class_getSuperclass(class);
    }
}

+ (void)ss_enumeratePropertyUsingBlock:(void (^)(objc_property_t property, NSUInteger index, BOOL *stop))block
{
    [self ss_enumerateClassUsingBlock:^(__unsafe_unretained Class class, BOOL *stop) {
        unsigned int propertyCount = 0;
        objc_property_t *properties = class_copyPropertyList(class, &propertyCount);
        for (unsigned int index = 0; index < propertyCount; index++) {
            objc_property_t property = properties[index];
            block(property,index,stop);
            if (*stop) {
                break;
            }
        }
        free(properties);
    }];
}

+ (void)ss_enumeratePropertyNameUsingBlock:(void (^)(NSString *propertyName, NSUInteger index, BOOL *stop))block
{
    [self ss_enumeratePropertyUsingBlock:^(objc_property_t property, NSUInteger index, BOOL *stop) {
        const char *name = property_getName(property);
        NSString *nameString = [NSString stringWithUTF8String:name];
        block(nameString,index,stop);
    }];
}

@end
