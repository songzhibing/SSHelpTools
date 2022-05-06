//
//  SSHelpNetworkInfo.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/16.
//

#import "SSHelpNetworkInfoManager.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
    #import <AFNetworking/AFNetworkReachabilityManager.h>
#else
    #import "AFNetworkReachabilityManager.h"
#endif

@interface SSHelpNetworkInfoManager()

@property(nonatomic, strong) CTTelephonyNetworkInfo *telephonyNetworkInfo;

@property(nonatomic, strong) CTCellularData *cellularData;

@property(nonatomic, strong) AFNetworkReachabilityManager *reachabilityManager;

@property(nonatomic, assign, readwrite) SSNetworkReachabilityStatus reachabilityStatus;

@end

@implementation SSHelpNetworkInfoManager

+ (instancetype)sharedManager
{
    static SSHelpNetworkInfoManager *networkInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        networkInfo = [[SSHelpNetworkInfoManager alloc] init];
    });
    return networkInfo;
}

- (void)dealloc
{
    [self stopMonitoring];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reachabilityStatus = SSNetworkReachabilityStatusUnknown;
    }
    return self;
}

/// 开始监测
- (void)startMonitoring
{
    __weak typeof(self) __weak_self = self;

    //AF: 开始监测
    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(__weak_self) __strong_self = __weak_self;
            if (__strong_self.reachabilityDidChanage) {
                __strong_self.reachabilityDidChanage(__strong_self.reachabilityStatus);
            }
        });
    }];
    [self.reachabilityManager startMonitoring];
    
    //监测: APP设置-无线数据-蜂窝数据模式变化
    self.cellularData.cellularDataRestrictionDidUpdateNotifier = ^(CTCellularDataRestrictedState state){
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(__weak_self) __strong_self = __weak_self;
            if (__strong_self.cellularDataRestrictionDidUpdateNotifier) {
                __strong_self.cellularDataRestrictionDidUpdateNotifier(state);
            }
            [__strong_self _printInfomation];
        });
    };
    
    //卡变更
    if (@available(iOS 12.0, *)) {
        self.telephonyNetworkInfo.serviceSubscriberCellularProvidersDidUpdateNotifier = ^(NSString * _Nonnull str) {
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(__weak_self) __strong_self = __weak_self;
                [__strong_self _printInfomation];
            });
        };
    } else {
        self.telephonyNetworkInfo.subscriberCellularProviderDidUpdateNotifier = ^(CTCarrier *carrier){
            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(__weak_self) __strong_self = __weak_self;
                [__strong_self _printInfomation];
            });
        };
    }
}

/// 停止监测
- (void)stopMonitoring
{
    [self.reachabilityManager stopMonitoring];
}

#pragma mark - sim卡

- (BOOL)isInsertedSimCard
{
    __block BOOL insert = NO;
    if (@available(iOS 12.1, *)) {
        if ([self.telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
            NSDictionary *dic = [self.telephonyNetworkInfo serviceSubscriberCellularProviders];
            [dic enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, CTCarrier * _Nonnull carrier, BOOL * _Nonnull stop) {
                if (carrier.isoCountryCode.length) {
                    insert = YES;
                    *stop = YES;
                }
            }];
        }
    } else {
        CTCarrier *carrier = [self.telephonyNetworkInfo subscriberCellularProvider];
        if (carrier.isoCountryCode.length) {
            insert = YES;
        }
    }
    _insertedSimCard = insert;
    return _insertedSimCard;
}

#pragma mark - 通讯运营商

- (NSMutableArray<CTCarrier *> *)carrieres
{
    __block NSMutableArray *muArray = [NSMutableArray array];
    if (@available(iOS 12.1, *)) {
        if ([self.telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
            NSDictionary *dic = [self.telephonyNetworkInfo serviceSubscriberCellularProviders];
            [dic.allValues enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [muArray addObject:obj];
            }];
        }
    } else {
        CTCarrier *carrier = [self.telephonyNetworkInfo subscriberCellularProvider];
        if (carrier) {
            [muArray addObject:carrier];
        }
    }
    _carrieres = [NSMutableArray arrayWithArray:muArray];
    return _carrieres;
}

- (void)setCarrierDidChanage:(void (^)(NSMutableArray<CTCarrier *> * _Nullable))carrierDidChanage
{
    _carrierDidChanage = carrierDidChanage;
}

#pragma mark - 飞行模式

- (SSNetworkAirplaneModel)airplaneModel
{
    SSNetworkAirplaneModel _airplaneModel =  SSNetworkAirplaneModeUnknown;
    if (self.isInsertedSimCard) {
        if (@available(iOS 12.1, *)) {
            if ([self.telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
                NSDictionary *dic = [self.telephonyNetworkInfo serviceSubscriberCellularProviders];
                if (dic && dic.allKeys.count) {
                    _airplaneModel =  SSNetworkAirplaneModeDisable;
                }else{
                    _airplaneModel =  SSNetworkAirplaneModeEnable;
                }
            }
        } else {
            NSString *radioType = [self.telephonyNetworkInfo currentRadioAccessTechnology];
            if (radioType && radioType.length) {
                _airplaneModel =  SSNetworkAirplaneModeDisable;
            }else{
                _airplaneModel =  SSNetworkAirplaneModeEnable;
            }
        }
    }
    return _airplaneModel;
}

#pragma mark - APP设置-无线数据-模式模式

/// 当前无线数据模式
- (CTCellularDataRestrictedState)restrictedState
{
    return self.cellularData.restrictedState;
}

/// APP设置-无线数据-模式变更
/// @param handler 回调
- (void)setCellularDataRestrictionDidUpdateNotifier:(CellularDataRestrictionDidUpdateNotifier)handler
{
    _cellularDataRestrictionDidUpdateNotifier = handler;
}

#pragma mark -  访问互联网权限

- (SSNetworkReachabilityStatus)reachabilityStatus
{
    NSString *radioType = nil;
    if (@available(iOS 12.1, *)) {
        if ([self.telephonyNetworkInfo respondsToSelector:@selector(serviceCurrentRadioAccessTechnology)]) {
            NSDictionary *radioDic = [self.telephonyNetworkInfo serviceCurrentRadioAccessTechnology];
            if (radioDic.allKeys.count) {
                radioType = [radioDic objectForKey:radioDic.allKeys[0]];
            }
        }
    } else {
        radioType = [self.telephonyNetworkInfo currentRadioAccessTechnology];
    }
    
    /**
     AFNetworkReachabilityStatusUnknown          = -1,
     AFNetworkReachabilityStatusNotReachable     = 0,
     AFNetworkReachabilityStatusReachableViaWWAN = 1,
     AFNetworkReachabilityStatusReachableViaWiFi = 2,
     */
    
    SSNetworkReachabilityStatus _tmpStatus =  SSNetworkReachabilityStatusUnknown;
    AFNetworkReachabilityStatus afStatus = self.reachabilityManager.networkReachabilityStatus;
    if (afStatus == AFNetworkReachabilityStatusUnknown)
    {
        _tmpStatus = SSNetworkReachabilityStatusUnknown;
    }
    else if (afStatus == AFNetworkReachabilityStatusUnknown)
    {
        _tmpStatus = SSNetworkReachabilityStatusUnknown;
    }
    else if (afStatus == AFNetworkReachabilityStatusNotReachable)
    {
        _tmpStatus = SSNetworkReachabilityStatusNotReachable;
    }
    else if (afStatus == AFNetworkReachabilityStatusReachableViaWWAN)
    {
        _tmpStatus = SSNetworkReachabilityStatusReachableViaWWAN;
    }
    else if (afStatus == AFNetworkReachabilityStatusReachableViaWiFi)
    {
        _tmpStatus = SSNetworkReachabilityStatusReachableViaWiFi;
    }
    _reachabilityStatus = _tmpStatus;
    return _reachabilityStatus;
}

- (void)setReachabilityDidChanage:(void (^)(SSNetworkReachabilityStatus))reachabilityDidChanage
{
    _reachabilityDidChanage = reachabilityDidChanage;
}

#pragma mark -

- (CTCellularData *)cellularData
{
    if (!_cellularData) {
        _cellularData = [[CTCellularData alloc] init];
    }
    return _cellularData;
}

- (CTTelephonyNetworkInfo *)telephonyNetworkInfo
{
    if (!_telephonyNetworkInfo) {
        _telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    }
    return _telephonyNetworkInfo;
}

- (AFNetworkReachabilityManager *)reachabilityManager
{
    if (!_reachabilityManager) {
        _reachabilityManager = [AFNetworkReachabilityManager manager];
    }
    return _reachabilityManager;
}

- (void)_printInfomation
{
    __block NSString *simString = @"";
    if (self.isInsertedSimCard ) {
        [self.carrieres enumerateObjectsUsingBlock:^(CTCarrier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            simString = [simString stringByAppendingString:[NSString stringWithFormat:@"卡%td:%@ ",idx,obj.carrierName]];
        }];
    }else{
        simString = @"无";
    }
    simString = [@"sim卡:" stringByAppendingString:simString];

    
    NSString *airString = @"";
    SSNetworkAirplaneModel model = self.airplaneModel;
    switch (model) {
        case SSNetworkAirplaneModeEnable:
            airString = @"开启";
            break;
        case SSNetworkAirplaneModeDisable:
            airString = @"关闭";
            break;
        default:
            airString = @"未知";
            break;
    }
    airString = [@"飞行模式:" stringByAppendingString:airString];

    
    NSString *cellularStr =  @"";
    switch (self.cellularData.restrictedState) {
        case kCTCellularDataRestricted:
            cellularStr = @"限制";
            break;
        case kCTCellularDataNotRestricted:
            cellularStr = @"无限制";
            break;
        default:
            cellularStr = @"未知";
            break;
    }
    cellularStr = [@"蜂窝数据:" stringByAppendingString:cellularStr];

    NSString *afString =  @"";
    switch (self.reachabilityManager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusNotReachable:
            afString = @"不可用";
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            afString = @"wifi";
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            afString = @"4G";
            break;
        default:
            afString = @"未知";
            break;
    }
    afString = [@"互联网:" stringByAppendingString:afString];
    
    @autoreleasepool {
        printf("*************************************\n");
        printf("** %s\n",[[NSString stringWithFormat:@"%@",simString] UTF8String]);
        printf("** %s\n",[[NSString stringWithFormat:@"%@",airString] UTF8String]);
        printf("** %s\n",[[NSString stringWithFormat:@"%@",cellularStr] UTF8String]);
        printf("** %s\n",[[NSString stringWithFormat:@"%@",afString] UTF8String]);
        printf("*************************************\n");
    };
}

@end
