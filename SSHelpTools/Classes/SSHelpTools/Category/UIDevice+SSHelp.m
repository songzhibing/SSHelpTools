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
 
#define SS_IOS_CELLULAR    @"pdp_ip0"
#define SS_IOS_WIFI        @"en0"
#define SS_IOS_VPN         @"utun0"
#define SS_IP_ADDR_IPv4    @"ipv4"
#define SS_IP_ADDR_IPv6    @"ipv6"

@implementation UIDevice (SSHelp)

/// 优先返回ipv4，次之ipv6
+ (NSString *)ss_IPAdress
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
        NSTextCheckingResult *firstMatch=[regex firstMatchInString:ipAddress options:0 range:NSMakeRange(0, [ipAddress length])];
        
        if (firstMatch) {
            //输出结果
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            NSString *result = [ipAddress substringWithRange:resultRange];
            NSLog(@"%@",result);
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

@end
