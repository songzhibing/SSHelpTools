//
//  UIDevice+SSHelp.h
//  Pods
//
//  Created by 宋直兵 on 2022/6/24.
//

#import <UIKit/UIKit.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCellularData.h>
#import <CoreTelephony/CTCarrier.h>

@class SSHotspotNetwork;

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (SSHelp)

/// 打印当前设备相关信息，仅支持Debug模式
+ (void)ss_debugPrintf;

/// 是否是模拟器
+ (BOOL)ss_isSimulator;

/// 设备唯一标识符
+ (NSString *)ss_UUID;

/// 屏幕分辨率
+ (CGSize)ss_resolution;

/// 物理内存总容量，单位MB
+ (CGFloat)ss_memoryTotalCapacity;

/// 物理内存空闲容量，单位MB
+ (CGFloat)ss_memoryFreeCapacity;

/// 应用程序占用物理内存，单位MB
+ (CGFloat)ss_memoryUsageCapacity;

/// 磁盘总容量，单位MB
+ (CGFloat)ss_diskTotalCapacity;

/// 磁盘可用容量，单位MB
+ (CGFloat)ss_diskFreeCapacity;

/// 设备IP地址
+ (NSString *)ss_IP;

/// 设备WiFi
+ (void)ss_WiFi:(void(^_Nonnull)(SSHotspotNetwork *_Nullable network))completion;

/// 设备SIM卡
+ (void)ss_SIM:(void(^_Nonnull)(NSArray <CTCarrier *> *_Nullable data))completion;

@end


//******************************************************************************

@interface SSHotspotNetwork : NSObject

/*!
 * @property SSID
 * @discussion The SSID of the Wi-Fi network.
 */
@property(nonatomic , copy) NSString * SSID;

/*!
 * @property BSSID
 * @discussion The BSSID of the Wi-Fi network.
 */
@property(nonatomic , copy) NSString * BSSID;

@end


NS_ASSUME_NONNULL_END
