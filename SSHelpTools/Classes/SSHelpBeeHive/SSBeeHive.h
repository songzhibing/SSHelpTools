/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 * 基于 https://github.com/alibaba/BeeHive 改写！！！
 */

#import <Foundation/Foundation.h>
#import "SSBHModuleProtocol.h"
#import "SSBHContext.h"
#import "SSBHAppDelegate.h"
#import "SSBHModuleManager.h"
#import "BHServiceManager.h"

@interface SSBeeHive : NSObject

//save application global context
@property(nonatomic, strong) SSBHContext *context;

@property (nonatomic, assign) BOOL enableException;

+ (instancetype)shareInstance;

+ (void)registerDynamicModule:(Class) moduleClass;

- (id)createService:(Protocol *)proto;

//Registration is recommended to use a static way
- (void)registerService:(Protocol *)proto service:(Class) serviceClass;

+ (void)triggerCustomEvent:(NSInteger)eventType;
    
@end
