/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "SSBHAppDelegate.h"
#import "SSBeeHive.h"
#import "SSBHModuleManager.h"
#import "SSBHTimeProfiler.h"

@implementation SSBHAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMSetupEvent];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMInitEvent];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [[SSBHModuleManager sharedManager] triggerEvent:SSBHMSplashEvent];
    });

    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    
    #ifdef DEBUG
    [[SSBHTimeProfiler sharedTimeProfiler] saveTimeProfileDataIntoFile:@"BeeHiveTimeProfiler"];
    #endif
    
    return YES;
}

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    [[SSBeeHive shareInstance].context.touchShortcutItem setShortcutItem: shortcutItem];
    [[SSBeeHive shareInstance].context.touchShortcutItem setScompletionHandler: completionHandler];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMQuickActionEvent];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMWillResignActiveEvent];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidEnterBackgroundEvent];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMWillEnterForegroundEvent];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidBecomeActiveEvent];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMWillTerminateEvent];
}

//- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
//{
//    [[SSBeeHive shareInstance].context.openURLItem setOpenURL:url];
//    [[SSBeeHive shareInstance].context.openURLItem setSourceApplication:sourceApplication];
//    [[SSBeeHive shareInstance].context.openURLItem setAnnotation:annotation];
//    [[BHModuleManager sharedManager] triggerEvent:BHMOpenURLEvent];
//    return YES;
//}

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80400
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<NSString *,id> *)options
{
    [[SSBeeHive shareInstance].context.openURLItem setOpenURL:url];
    [[SSBeeHive shareInstance].context.openURLItem setOptions:options];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMOpenURLEvent];
    return YES;
}
//#endif


- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidReceiveMemoryWarningEvent];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    [[SSBeeHive shareInstance].context.notificationsItem setNotificationsError:error];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidFailToRegisterForRemoteNotificationsEvent];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [[SSBeeHive shareInstance].context.notificationsItem setDeviceToken: deviceToken];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidRegisterForRemoteNotificationsEvent];
}

//- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
//{
//    [[SSBeeHive shareInstance].context.notificationsItem setUserInfo: userInfo];
//    [[BHModuleManager sharedManager] triggerEvent:BHMDidReceiveRemoteNotificationEvent];
//}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    [[SSBeeHive shareInstance].context.notificationsItem setUserInfo: userInfo];
    [[SSBeeHive shareInstance].context.notificationsItem setNotificationResultHander: completionHandler];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidReceiveRemoteNotificationEvent];
}

//- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
//{
//    [[SSBeeHive shareInstance].context.notificationsItem setLocalNotification: notification];
//    [[BHModuleManager sharedManager] triggerEvent:BHMDidReceiveLocalNotificationEvent];
//}

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (void)application:(UIApplication *)application didUpdateUserActivity:(NSUserActivity *)userActivity
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[SSBeeHive shareInstance].context.userActivityItem setUserActivity: userActivity];
        [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidUpdateUserActivityEvent];
    }
}

- (void)application:(UIApplication *)application didFailToContinueUserActivityWithType:(NSString *)userActivityType error:(NSError *)error
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[SSBeeHive shareInstance].context.userActivityItem setUserActivityType: userActivityType];
        [[SSBeeHive shareInstance].context.userActivityItem setUserActivityError: error];
        [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidFailToContinueUserActivityEvent];
    }
}

// Called on the main thread after the NSUserActivity object is available. Use the data you stored in the NSUserActivity object to re-create what the user was doing.
// You can create/fetch any restorable objects associated with the user activity, and pass them to the restorationHandler. They will then have the UIResponder restoreUserActivityState: method
// invoked with the user activity. Invoking the restorationHandler is optional. It may be copied and invoked later, and it will bounce to the main thread to complete its work and call
// restoreUserActivityState on all objects.
- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray<id<UIUserActivityRestoring>> * __nullable restorableObjects))restorationHandler API_AVAILABLE(ios(8.0))
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[SSBeeHive shareInstance].context.userActivityItem setUserActivity: userActivity];
        [[SSBeeHive shareInstance].context.userActivityItem setRestorationHandler: restorationHandler];
        [[SSBHModuleManager sharedManager] triggerEvent:SSBHMContinueUserActivityEvent];
    }
    return YES;
}

- (BOOL)application:(UIApplication *)application willContinueUserActivityWithType:(NSString *)userActivityType
{
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [[SSBeeHive shareInstance].context.userActivityItem setUserActivityType: userActivityType];
        [[SSBHModuleManager sharedManager] triggerEvent:SSBHMWillContinueUserActivityEvent];
    }
    return YES;
}
- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo reply:(void(^)(NSDictionary * __nullable replyInfo))reply {
    if([UIDevice currentDevice].systemVersion.floatValue >= 8.0f){
        [SSBeeHive shareInstance].context.watchItem.userInfo = userInfo;
        [SSBeeHive shareInstance].context.watchItem.replyHandler = reply;
        [[SSBHModuleManager sharedManager] triggerEvent:SSBHMHandleWatchKitExtensionRequestEvent];
    }
}
//#endif

//#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler {
    [[SSBeeHive shareInstance].context.notificationsItem setNotification: notification];
    [[SSBeeHive shareInstance].context.notificationsItem setNotificationPresentationOptionsHandler: completionHandler];
    [[SSBeeHive shareInstance].context.notificationsItem setCenter:center];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMWillPresentNotificationEvent];
};

// The method will be called on the delegate when the user responded to the notification by opening the application, dismissing the notification or choosing a UNNotificationAction. The delegate must be set before the application returns from application:didFinishLaunchingWithOptions:.
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)(void))completionHandler API_AVAILABLE(macos(10.14), ios(10.0), watchos(3.0)) API_UNAVAILABLE(tvos){
    [[SSBeeHive shareInstance].context.notificationsItem setNotificationResponse: response];
    [[SSBeeHive shareInstance].context.notificationsItem setNotificationCompletionHandler:completionHandler];
    [[SSBeeHive shareInstance].context.notificationsItem setCenter:center];
    [[SSBHModuleManager sharedManager] triggerEvent:SSBHMDidReceiveNotificationResponseEvent];
}
//#endif

@end

@implementation SSBHOpenURLItem

@end

@implementation SSBHShortcutItem

@end

@implementation SSBHUserActivityItem

@end

@implementation SSBHNotificationsItem

@end
