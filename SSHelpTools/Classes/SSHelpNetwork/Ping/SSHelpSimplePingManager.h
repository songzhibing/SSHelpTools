//
//  SSHelpSimplePingManager.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/// 响应数据包
/// 64 bytes from 192.168.1.1: icmp_seq=0 ttl=54 time=55.852 ms
///
@interface SSHelpPingPacketItem : NSObject
@property(nonatomic, assign, readonly) BOOL connected;
@property(nonatomic, assign, readonly) size_t length;
@property(nonatomic, copy,   readonly) NSString *from;
@property(nonatomic, assign, readonly) uint16_t icmp_seq;
@property(nonatomic, assign, readonly) double ttl;
@property(nonatomic, assign, readonly) NSTimeInterval time;
@end

typedef void(^SSPingCallback)(BOOL success, NSArray <SSHelpPingPacketItem *> *responsePackets);

typedef void(^SSPingHostNamesCallback)(NSArray *hostNames, NSArray <NSArray <SSHelpPingPacketItem *> *> *response);


@interface SSHelpSinglePinger : NSObject
+ (instancetype)startWithHostName:(NSString *)hostName count:(NSInteger)count pingCallback:(SSPingCallback)callback;
- (instancetype)initWithHostName:(NSString *)hostName count:(NSInteger)count pingCallback:(SSPingCallback)callback;
@end



@interface SSHelpSimplePingManager : NSObject

+ (void)ping:(NSString *)hostName callBack:(SSPingCallback)callBack;

+ (void)pingHostNames:(NSArray <NSString *> *)hostNames callback:(SSPingHostNamesCallback)callback;

@end

NS_ASSUME_NONNULL_END
