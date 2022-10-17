//
//  SSHelpBlockTarget.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/14.
//

//#import <objc/runtime.h>
//
////
//#define _GCUISynthesizeId(_getterName, _setterName, _policy) \
//_Pragma("clang diagnostic push") _Pragma(ClangWarningConcat("-Wmismatched-parameter-types")) _Pragma(ClangWarningConcat("-Wmismatched-return-types"))\
//static char kAssociatedObjectKey_##_getterName;\
//- (void)_setterName:(id)_getterName {\
//    objc_setAssociatedObject(self, &kAssociatedObjectKey_##_getterName, _getterName, OBJC_ASSOCIATION_##_policy##_NONATOMIC);\
//}\
//\
//- (id)_getterName {\
//    return objc_getAssociatedObject(self, &kAssociatedObjectKey_##_getterName);\
//}\
//_Pragma("clang diagnostic pop")
//
///// @property(nonatomic, strong) id xxx
//#define GCClassSynthesizeIdStrongProperty(_getterName, _setterName) _GCUISynthesizeId(_getterName, _setterName, RETAIN)
//
///**
// Example:
// QMUISynthesizeIdStrongProperty(customAction, setCustomAction)
// QMUISynthesizeIdStrongProperty(originContainerViewBackgroundColor, setOriginContainerViewBackgroundColor)
// */

#import "SSHelpBlockTarget.h"

@implementation SSHelpBlockTarget

- (void)dealloc
{
    //SSLi(@"%@ dealloc ... ",self);
}

- (id)initWithBlock:(void (^)(id sender))block
{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender
{
    if (self.block) self.block(sender);
}

@end
