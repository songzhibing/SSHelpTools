//
//  UIDevice+SSHelp.m
//  Pods
//
//  Created by 宋直兵 on 2022/6/24.
//

#import "UIDevice+SSHelp.h"
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <net/if.h>
#import <sys/sysctl.h>
#import <mach/mach.h>
#import <CoreLocation/CoreLocation.h>
#import <NetworkExtension/NetworkExtension.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import <UICKeyChainStore/UICKeyChainStore.h>


#define __UNIT_KB (1024)
#define __UNIT_MB (__UNIT_KB * 1024)
#define __UNIT_GB (__UNIT_MB * 1024)


//iPhone设备上蜂窝网络名称
//也可能为 pdp_ip1 pdp_ip2 pdp_ip3 pdp_ip4 双卡双待设备就有不同的名称
#define SS_IOS_CELLULAR    @"pdp_ip0"

//iPhone设备上WI-FI名称
//其他设备不一定是这个 可能是en1 en2 en3 ，Mac、 windows、Linux、unix都可能不一样
#define SS_IOS_WIFI        @"en0"

//VPN名称 utun2 utun3
#define SS_IOS_VPN         @"utun0"

#define SS_IP_ADDR_IPv4    @"ipv4"
#define SS_IP_ADDR_IPv6    @"ipv6"

@implementation UIDevice (SSHelp)

/// 打印当前设备相关信息，仅支持Debug模式
+ (void)ss_debugPrintf
{
#ifdef DEBUG
    NSString *resolution = [NSString stringWithFormat:@"%.0fx%.0f",UIDevice.ss_resolution.width,UIDevice.ss_resolution.height];
    
    NSString *totalMemory = [NSString stringWithFormat:@"%.2fMB ≈ %.2fG",UIDevice.ss_memoryTotalCapacity,UIDevice.ss_memoryTotalCapacity/1000.f];
    NSString *freeMemory = [NSString stringWithFormat:@"%.2fMB ≈ %.2fG",UIDevice.ss_memoryFreeCapacity,UIDevice.ss_memoryFreeCapacity/1000.f];
    NSString *usageMemory = [NSString stringWithFormat:@"%.2fMB ≈ %.2fG",UIDevice.ss_memoryUsageCapacity,UIDevice.ss_memoryUsageCapacity/1000.f];

    NSString *diskTotal = [NSString stringWithFormat:@"%.2fMB ≈ %.2fG",UIDevice.ss_diskTotalCapacity,UIDevice.ss_diskTotalCapacity/1000.f];
    NSString *diskFree = [NSString stringWithFormat:@"%.2fMB ≈ %.2fG",UIDevice.ss_diskFreeCapacity,UIDevice.ss_diskFreeCapacity/1000.f];

    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    __block NSString *WiFi = @"";
    [UIDevice ss_WiFi:^(SSHotspotNetwork * _Nullable network) {
        if (network) {
            WiFi = network.SSID;
        }
        dispatch_semaphore_signal(semaphore);
    }];
    
    __block NSString *SIM = @"";
    [UIDevice ss_SIM:^(NSArray<CTCarrier *> * _Nullable data) {
        if (data) {
            [data enumerateObjectsUsingBlock:^(CTCarrier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                SIM = [obj carrierName];
                dispatch_semaphore_signal(semaphore);
            }];
        } else {
            dispatch_semaphore_signal(semaphore);
        }
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    printf("/********************************************* \n");
    printf("/* 设备唯一标识符: %s \n",[UIDevice ss_UUID].UTF8String);
    printf("/* 设备分辨率: %s \n",resolution.UTF8String);
    printf("/* 设备IP地址: %s \n",UIDevice.ss_IP.UTF8String);
    printf("/* 设备总内存:   %s \n",totalMemory.UTF8String);
    printf("/* 设备空闲内存:   %s \n",freeMemory.UTF8String);
    printf("/* 设备使用内存:   %s \n",usageMemory.UTF8String);
    printf("/* 设备总容量:  %s \n",diskTotal.UTF8String);
    printf("/* 设备可用容量: %s \n",diskFree.UTF8String);
    printf("/* 设备WiFi: %s \n",WiFi.UTF8String);
    printf("/* 设备SIM: %s \n",SIM.UTF8String);
    printf("/********************************************* \n");
#endif
}

/// 是否是模拟器
+ (BOOL)ss_isSimulator
{
    #if TARGET_OS_SIMULATOR
    return YES;
    #else
    return NO;
    #endif
}

/// 设备唯一标识符
+ (NSString *)ss_UUID
{
    NSString *key = [[[NSBundle mainBundle] bundleIdentifier] stringByAppendingString:@".UUID"];
    NSString *UUIDString = [UICKeyChainStore stringForKey:key];
    if (!UUIDString) {
        //获取UUID
        UUIDString = [UIDevice currentDevice].identifierForVendor.UUIDString;
        //将该UUID保存到keychain
        [UICKeyChainStore setString:UUIDString forKey:key];
    }
    return UUIDString;
}

/// 屏幕分辨率
+ (CGSize)ss_resolution
{
    // 屏幕宽高
    CGSize size = [UIScreen mainScreen].bounds.size;
    // 屏幕缩放率
    CGFloat scale = [UIScreen mainScreen].scale;
    // 屏幕像素分辨率
    return CGSizeMake(size.width * scale, size.height * scale);
}

/// 物理内存总容量，单位MB
+ (CGFloat)ss_memoryTotalCapacity
{
    return [NSProcessInfo processInfo].physicalMemory/(CGFloat)__UNIT_MB;
}

/// 物理内存空闲容量，单位MB
+ (CGFloat)ss_memoryFreeCapacity
{
    mach_port_t host_port = mach_host_self();
    mach_msg_type_number_t count = HOST_VM_INFO64_COUNT;
 
    vm_size_t page_size;
    vm_statistics64_data_t vminfo;
    host_page_size(host_port, &page_size);
    host_statistics64(host_port, HOST_VM_INFO64, (host_info64_t)&vminfo,&count);
 
    uint64_t free_size = (vminfo.free_count + vminfo.external_page_count + vminfo.purgeable_count - vminfo.speculative_count) * page_size;
    return free_size /(CGFloat)__UNIT_MB;
}

// 物理内存使用容量，单位MB
+ (CGFloat)ss_memoryUsageCapacity
{
    task_vm_info_data_t vmInfo;
    mach_msg_type_number_t count = TASK_VM_INFO_COUNT;
    kern_return_t kernelReturn = task_info(mach_task_self(), TASK_VM_INFO, (task_info_t) &vmInfo, &count);
    if(kernelReturn == KERN_SUCCESS) {
        CGFloat usage =  (int64_t) vmInfo.phys_footprint/(CGFloat)__UNIT_MB;
        return usage;
    }
    return NSNotFound;
}

/// 设备磁盘总容量，单位MB
+ (CGFloat)ss_diskTotalCapacity
{
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:NSTemporaryDirectory()];
    NSDictionary *dict = [fileURL resourceValuesForKeys:@[NSURLVolumeTotalCapacityKey] error:nil];
    if (dict) {
        NSNumber *number = dict[NSURLVolumeTotalCapacityKey];
        //以1024计算，误差较大
        return [number unsignedLongLongValue]/(CGFloat)(1000*1000);
    }
    return NSNotFound;
}

/// 设备磁盘可用容量，单位MB
+ (CGFloat)ss_diskFreeCapacity
{
    NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:NSTemporaryDirectory()];
    NSDictionary *dict = [fileURL resourceValuesForKeys:@[NSURLVolumeAvailableCapacityForImportantUsageKey] error:nil];
    if (dict) {
        NSNumber *number = dict[NSURLVolumeAvailableCapacityForImportantUsageKey];
        //以1024计算，误差较大
        return [number unsignedLongLongValue]/(CGFloat)(1000*1000);
    }
    return NSNotFound;
}

/// 设备ip地址
+ (NSString *)ss_IP
{
    NSString *IP = [self getIPAddress:YES];
    if ([IP isEqualToString:@"0.0.0.0"]) {
        IP = [self getIPAddress:NO];
    }
    return IP;
}

+ (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[ SS_IOS_VPN @"/" SS_IP_ADDR_IPv4, SS_IOS_VPN @"/" SS_IP_ADDR_IPv6, SS_IOS_WIFI @"/" SS_IP_ADDR_IPv4, SS_IOS_WIFI @"/" SS_IP_ADDR_IPv6, SS_IOS_CELLULAR @"/" SS_IP_ADDR_IPv4, SS_IOS_CELLULAR @"/" SS_IP_ADDR_IPv6 ] :
    @[ SS_IOS_VPN @"/" SS_IP_ADDR_IPv6, SS_IOS_VPN @"/" SS_IP_ADDR_IPv4, SS_IOS_WIFI @"/" SS_IP_ADDR_IPv6, SS_IOS_WIFI @"/" SS_IP_ADDR_IPv4, SS_IOS_CELLULAR @"/" SS_IP_ADDR_IPv6, SS_IOS_CELLULAR @"/" SS_IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop){
         address = addresses[key];
         //筛选出IP地址格式
         if([self isValidatIP:address]) *stop = YES;
     }];
    return address ? address : @"0.0.0.0";
}
 
+ (BOOL)isValidatIP:(NSString *)ipAddress
{
    if (ipAddress.length == 0) {
        return NO;
    }
    NSString *urlRegEx = @"^([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])\\."
    "([01]?\\d\\d?|2[0-4]\\d|25[0-5])$";
    
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:urlRegEx options:0 error:&error];
    if (regex != nil) {
        NSTextCheckingResult *result=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        if (result) {
            return YES;
        }
    }
    return NO;
}

+ (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP) /* || (interface->ifa_flags & IFF_LOOPBACK) */ ) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = SS_IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = SS_IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}

/// 设备WiFi
+ (void)ss_WiFi:(void(^_Nonnull)(SSHotspotNetwork *_Nullable network))callback
{
    /**
     * iOS12以上的版本获取wifi信息，需在中设Capability置Access WIFI Infomation = ON
     * iOS13获取之前需获判断是否同意app适用地理位置信息
     */
    if (@available(iOS 14.0, *)) {
        CLLocationManager *location= [[CLLocationManager alloc] init];
        CLAuthorizationStatus authorization = location.authorizationStatus;
        if ([CLLocationManager locationServicesEnabled] &&
            (authorization== kCLAuthorizationStatusAuthorizedAlways||
             authorization == kCLAuthorizationStatusAuthorizedWhenInUse)) {
            [NEHotspotNetwork fetchCurrentWithCompletionHandler:^(NEHotspotNetwork * _Nullable currentNetwork) {
                if (currentNetwork) {
                    SSHotspotNetwork *network = [[SSHotspotNetwork alloc] init];
                    network.SSID = currentNetwork.SSID;
                    network.BSSID = currentNetwork.BSSID;
                    callback(network);
                } else {
                    callback(nil);
                }
            }];
        } else {
            //需要权限，否则获取不到
            callback(nil);
        }
    } else {
        if (@available(iOS 13.0, *)) {
            CLAuthorizationStatus authorization = [CLLocationManager authorizationStatus];
            if ([CLLocationManager locationServicesEnabled] &&
                (authorization== kCLAuthorizationStatusAuthorizedAlways||
                 authorization == kCLAuthorizationStatusAuthorizedWhenInUse)) {
                //具备权限，可以获取
            } else {
                //需要权限，否则获取不到
                callback(nil);
                return;
            }
        } else {
            //iOS 13 之前系统
        }
        NSDictionary *info = nil;
        NSArray *interfaceNames = CFBridgingRelease(CNCopySupportedInterfaces());
        for (NSString *interfaceName in interfaceNames) {
            info = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)interfaceName));
            if (info.count) {
                break;
            }
        }
        if (info && info[@"SSID"]) {
            SSHotspotNetwork *network = [[SSHotspotNetwork alloc] init];
            network.SSID = info[@"SSID"];
            network.BSSID = info[@"BSSID"];
            callback(network);
        } else {
            callback(nil);
        }
    }
}

/// 设备SIM卡
+ (void)ss_SIM:(void(^_Nonnull)(NSArray <CTCarrier *> *_Nullable data))callback
{
    __block NSMutableArray *dataArray = [NSMutableArray array];
    CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    if (@available(iOS 12.1, *)) {
        if ([telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
            NSDictionary <NSString *, CTCarrier *> *providers = [telephonyNetworkInfo serviceSubscriberCellularProviders];
            [providers enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, CTCarrier * _Nonnull obj, BOOL * _Nonnull stop) {
                [dataArray addObject:obj];
            }];
        }
    } else {
        CTCarrier *carrier = [telephonyNetworkInfo subscriberCellularProvider];
        if (carrier) {
            [dataArray addObject:carrier];
        }
    }
    callback(dataArray);
}

@end

//******************************************************************************

@implementation SSHotspotNetwork


@end



