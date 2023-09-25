//
//  SSAppDelegate.m
//  SSHelpTools
//
//  Created by 宋直兵 on 12/17/2021.
//  Copyright (c) 2021 宋直兵. All rights reserved.
//

#import "SSAppDelegate.h"
#import <SSHelpTools/SSBeeHive.h>
#import <SSHelpTools/SSBHTimeProfiler.h>

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    printf("应用程序启动>>>");
    [SSBHContext shareInstance].application = application;
    [SSBHContext shareInstance].launchOptions = launchOptions;
    //[BHContext shareInstance].moduleConfigName = @"BeeHive.bundle/BeeHive";//可选，默认为BeeHive.bundle/BeeHive.plist
    //[BHContext shareInstance].serviceConfigName = @"BeeHive.bundle/BHService";
    
    [SSBeeHive shareInstance].enableException = YES;
    [[SSBeeHive shareInstance] setContext:[SSBHContext shareInstance]];
    [[SSBHTimeProfiler sharedTimeProfiler] recordEventTime:@"SSBeeHive::super start launch"];

    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    //[SSHelpLogHttpServer startServer];
    [SSHelpToolsConfig sharedConfig].enableLog = NO;
    [SSHelpToolsConfig sharedConfig].enableLifeCycleLog = YES;

    [[SSBHTimeProfiler sharedTimeProfiler] printOutTimeProfileResult];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
