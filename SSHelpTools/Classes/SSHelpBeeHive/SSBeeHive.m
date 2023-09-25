/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "SSBeeHive.h"

@implementation SSBeeHive

#pragma mark - public

+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    static id BHInstance = nil;
    
    dispatch_once(&p, ^{
        BHInstance = [[self alloc] init];
    });
    
    return BHInstance;
}

+ (void)registerDynamicModule:(Class)moduleClass
{
    [[SSBHModuleManager sharedManager] registerDynamicModule:moduleClass];
}

- (id)createService:(Protocol *)proto;
{
    return [[SSBHServiceManager sharedManager] createService:proto];
}

- (void)registerService:(Protocol *)proto service:(Class) serviceClass
{
    [[SSBHServiceManager sharedManager] registerService:proto implClass:serviceClass];
}
    
+ (void)triggerCustomEvent:(NSInteger)eventType
{
    if(eventType < 1000) {
        return;
    }
    
    [[SSBHModuleManager sharedManager] triggerEvent:eventType];
}

#pragma mark - Private

-(void)setContext:(SSBHContext *)context
{
    _context = context;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self loadStaticServices];
        [self loadStaticModules];
    });
}


- (void)loadStaticModules
{
    
    [[SSBHModuleManager sharedManager] loadLocalModules];
    
    [[SSBHModuleManager sharedManager] registedAllModules];
    
}

-(void)loadStaticServices
{
    [SSBHServiceManager sharedManager].enableException = self.enableException;
    
    [[SSBHServiceManager sharedManager] registerLocalServices];
    
}

@end
