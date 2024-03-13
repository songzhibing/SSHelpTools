/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SSBHModuleLevel)
{
    SSBHModuleBasic  = 0,
    SSBHModuleNormal = 1
};

typedef NS_ENUM(NSInteger, SSBHModuleEventType)
{
    SSBHMSetupEvent = 0,
    SSBHMInitEvent,
    SSBHMTearDownEvent,
    SSBHMSplashEvent,
    SSBHMQuickActionEvent,
    SSBHMWillResignActiveEvent,
    SSBHMDidEnterBackgroundEvent,
    SSBHMWillEnterForegroundEvent,
    SSBHMDidBecomeActiveEvent,
    SSBHMWillTerminateEvent,
    SSBHMUnmountEvent,
    SSBHMOpenURLEvent,
    SSBHMDidReceiveMemoryWarningEvent,
    SSBHMDidFailToRegisterForRemoteNotificationsEvent,
    SSBHMDidRegisterForRemoteNotificationsEvent,
    SSBHMDidReceiveRemoteNotificationEvent,
    SSBHMDidReceiveLocalNotificationEvent,
    SSBHMWillPresentNotificationEvent,
    SSBHMDidReceiveNotificationResponseEvent,
    SSBHMWillContinueUserActivityEvent,
    SSBHMContinueUserActivityEvent,
    SSBHMDidFailToContinueUserActivityEvent,
    SSBHMDidUpdateUserActivityEvent,
    SSBHMHandleWatchKitExtensionRequestEvent,
    SSBHMDidCustomEvent = 1000
    
};


@interface SSBHModuleManager : NSObject

+ (instancetype)sharedManager;

// If you do not comply with set Level protocol, the default Normal
- (void)registerDynamicModule:(Class)moduleClass;

- (void)registerDynamicModule:(Class)moduleClass
       shouldTriggerInitEvent:(BOOL)shouldTriggerInitEvent;

- (void)unRegisterDynamicModule:(Class)moduleClass;

- (void)loadLocalModules;

- (void)registedAllModules;

- (void)registerCustomEvent:(NSInteger)eventType
         withModuleInstance:(id)moduleInstance
             andSelectorStr:(NSString *)selectorStr;

- (void)triggerEvent:(NSInteger)eventType;

- (void)triggerEvent:(NSInteger)eventType
     withCustomParam:(NSDictionary *)customParam;



@end

