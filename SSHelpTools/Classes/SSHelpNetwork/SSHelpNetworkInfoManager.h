//
//  SSHelpNetworkInfo.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/16.
//  封装网络信息，主要目的是提供统一的外部接口，内部适配系统及三方API
//

#import <Foundation/Foundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <CoreTelephony/CTCellularData.h>

NS_ASSUME_NONNULL_BEGIN

/**
 "飞行模式"是禁止蜂窝信号接收,但蓝牙、无线还是可以正常使用，所以飞行模式下也可以上网
 */
typedef NS_OPTIONS(NSInteger, SSNetworkAirplaneModel) {
    SSNetworkAirplaneModeUnknown = 1<<0, //未知 （可能无sim卡）
    SSNetworkAirplaneModeEnable  = 1<<1, //飞行模式开启
    SSNetworkAirplaneModeDisable = 1<<2  //飞行模式关闭
};

typedef NS_OPTIONS(NSInteger, SSNetworkReachabilityStatus) {
    SSNetworkReachabilityStatusUnknown          = 1<<0,
    SSNetworkReachabilityStatusNotReachable     = 1<<1,
    SSNetworkReachabilityStatusReachableViaWWAN = 1<<2,
    SSNetworkReachabilityStatusReachableViaWiFi = 2<<3,
};

@interface SSHelpNetworkInfoManager : NSObject

+ (instancetype)sharedManager;

/// 开始监测
- (void)startMonitoring;

#pragma mark - sim卡

@property(nonatomic, assign, getter=isInsertedSimCard) BOOL insertedSimCard;

@property(nonatomic, copy) void((^simCardDidChanage)(BOOL inserted));

#pragma mark - 通讯运营商

@property(nonatomic, strong) NSMutableArray <CTCarrier *> * _Nullable carrieres;

@property(nonatomic, copy) void(^carrierDidChanage)(NSMutableArray <CTCarrier *> * _Nullable);

#pragma mark - 飞行模式

@property(nonatomic, assign, readonly) SSNetworkAirplaneModel airplaneModel;

@property(nonatomic, copy) void((^airplaneDidChange)(SSNetworkAirplaneModel model));

#pragma mark - (APP)设置-无线数据-模式模式

@property(nonatomic, readonly) CTCellularDataRestrictedState restrictedState;

@property(nonatomic, copy) CellularDataRestrictionDidUpdateNotifier cellularDataRestrictionDidUpdateNotifier;

#pragma mark - 访问互联网权限

@property(nonatomic, assign, readonly) SSNetworkReachabilityStatus reachabilityStatus;

@property(nonatomic, copy) void(^reachabilityDidChanage)(SSNetworkReachabilityStatus status);

@end

NS_ASSUME_NONNULL_END
