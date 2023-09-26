//
//  SSAppDelegate.m
//  SSHelpTools
//
//  Created by 宋直兵 on 12/17/2021.
//  Copyright (c) 2021 宋直兵. All rights reserved.
//

#import "SSAppDelegate.h"
#import <SSHelpTools/SSBHTimeProfiler.h>

@implementation SSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    printf("应用程序启动>>>");
    [SSBHContext shareInstance].application = application;
    [SSBHContext shareInstance].launchOptions = launchOptions;
    
    //[BHContext shareInstance].moduleConfigName = @"BeeHive.bundle/BeeHive";//可选，默认为BeeHive.bundle/BeeHive.plist
    //[BHContext shareInstance].serviceConfigName = @"BeeHive.bundle/BHService";
    
    [SSBeeHive shareInstance].enableException = NO;
    [[SSBeeHive shareInstance] setContext:[SSBHContext shareInstance]];
    [[SSBHTimeProfiler sharedTimeProfiler] recordEventTime:@"SSBeeHive::super start launch"];

    
    [super application:application didFinishLaunchingWithOptions:launchOptions];
    
    //[SSHelpLogHttpServer startServer];
    [SSHelpToolsConfig sharedConfig].enableLog = NO;
    [SSHelpToolsConfig sharedConfig].enableLifeCycleLog = YES;

    [[SSBHTimeProfiler sharedTimeProfiler] printOutTimeProfileResult];
    
    return YES;
}

@end
