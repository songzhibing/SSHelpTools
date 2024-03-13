/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import <Foundation/Foundation.h>
#import "SSBHServiceProtocol.h"
#import "SSBHConfig.h"
#import "SSBHAppDelegate.h"

typedef enum
{
    SSBHEnvironmentDev = 0,
    SSBHEnvironmentTest,
    SSBHEnvironmentStage,
    SSBHEnvironmentProd
}SSBHEnvironmentType;


@interface SSBHContext : NSObject <NSCopying>

//global env
@property(nonatomic, assign) SSBHEnvironmentType env;

//global config
@property(nonatomic, strong) SSBHConfig *config;

//application appkey
@property(nonatomic, strong) NSString *appkey;

//customEvent>=1000
@property(nonatomic, assign) NSInteger customEvent;

@property(nonatomic, strong) UIApplication *application;

@property(nonatomic, strong) NSDictionary *launchOptions;

@property(nonatomic, strong) NSString *moduleConfigName;

@property(nonatomic, strong) NSString *serviceConfigName;

//3D-Touch model
#if __IPHONE_OS_VERSION_MAX_ALLOWED > 80400
@property (nonatomic, strong) SSBHShortcutItem *touchShortcutItem;
#endif

//OpenURL model
@property (nonatomic, strong) SSBHOpenURLItem *openURLItem;

//Notifications Remote or Local
@property (nonatomic, strong) SSBHNotificationsItem *notificationsItem;

//user Activity Model
@property (nonatomic, strong) SSBHUserActivityItem *userActivityItem;

//watch Model
@property (nonatomic, strong) SSBHWatchItem *watchItem;

//custom param
@property (nonatomic, copy) NSDictionary *customParam;

+ (instancetype)shareInstance;

- (void)addServiceWithImplInstance:(id)implInstance serviceName:(NSString *)serviceName;

- (void)removeServiceWithServiceName:(NSString *)serviceName;

- (id)getServiceInstanceFromServiceName:(NSString *)serviceName;

@end
