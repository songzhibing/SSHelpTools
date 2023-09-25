/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "SSBHAnnotation.h"
@class SSBHContext;
@class SSBeeHive;

#define SSBH_EXPORT_MODULE(isAsync) \
+ (void)load { [SSBeeHive registerDynamicModule:[self class]]; } \
-(BOOL)async { return [[NSString stringWithUTF8String:#isAsync] boolValue];}


@protocol SSBHModuleProtocol <NSObject>


@optional

//如果不去设置Level默认是Normal
//basicModuleLevel不去实现默认Normal
- (void)basicModuleLevel;
//越大越优先
- (NSInteger)modulePriority;

- (BOOL)async;

- (void)modSetUp:(SSBHContext *)context;

- (void)modInit:(SSBHContext *)context;

- (void)modSplash:(SSBHContext *)context;

- (void)modQuickAction:(SSBHContext *)context;

- (void)modTearDown:(SSBHContext *)context;

- (void)modWillResignActive:(SSBHContext *)context;

- (void)modDidEnterBackground:(SSBHContext *)context;

- (void)modWillEnterForeground:(SSBHContext *)context;

- (void)modDidBecomeActive:(SSBHContext *)context;

- (void)modWillTerminate:(SSBHContext *)context;

- (void)modUnmount:(SSBHContext *)context;

- (void)modOpenURL:(SSBHContext *)context;

- (void)modDidReceiveMemoryWaring:(SSBHContext *)context;

- (void)modDidFailToRegisterForRemoteNotifications:(SSBHContext *)context;

- (void)modDidRegisterForRemoteNotifications:(SSBHContext *)context;

- (void)modDidReceiveRemoteNotification:(SSBHContext *)context;

- (void)modDidReceiveLocalNotification:(SSBHContext *)context;

- (void)modWillPresentNotification:(SSBHContext *)context;

- (void)modDidReceiveNotificationResponse:(SSBHContext *)context;

- (void)modWillContinueUserActivity:(SSBHContext *)context;

- (void)modContinueUserActivity:(SSBHContext *)context;

- (void)modDidFailToContinueUserActivity:(SSBHContext *)context;

- (void)modDidUpdateContinueUserActivity:(SSBHContext *)context;

- (void)modHandleWatchKitExtensionRequest:(SSBHContext *)context;

- (void)modDidCustomEvent:(SSBHContext *)context;
@end
