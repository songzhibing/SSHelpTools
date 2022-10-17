//
//  SSHelpSimplePingManager.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/9/5.
//

#import "SSHelpSimplePingManager.h"
#import "SSHelpSimplePing.h"
#include <sys/socket.h>
#include <netdb.h>

@class PingItem, SSHelpSinglePinger;

/*! Returns the string representation of the supplied address.
 *  \param address Contains a (struct sockaddr) with the address to render.
 *  \returns A string representation of that address.
 */
static NSString *_displayAddressForAddress(NSData * address) {
    int         err;
    NSString *  result;
    char        hostStr[NI_MAXHOST];
    result = nil;
    if (address != nil) {
        err = getnameinfo(address.bytes, (socklen_t) address.length, hostStr, sizeof(hostStr), NULL, 0, NI_NUMERICHOST);
        if (err == 0) {
            result = @(hostStr);
        }
    }
    if (result == nil) {
        result = @"?";
    }
    return result;
}

/*! Returns a short error string for the supplied error.
 *  \param error The error to render.
 *  \returns A short string representing that error.
 */

/**
static NSString * _shortErrorFromError(NSError * error) {
    NSString *      result;
    NSNumber *      failureNum;
    int             failure;
    const char *    failureStr;
    assert(error != nil);
    result = nil;
    // Handle DNS errors as a special case.
    if ( [error.domain isEqual:(NSString *)kCFErrorDomainCFNetwork] && (error.code == kCFHostErrorUnknown) ) {
        failureNum = error.userInfo[(id) kCFGetAddrInfoFailureKey];
        if ( [failureNum isKindOfClass:[NSNumber class]] ) {
            failure = failureNum.intValue;
            if (failure != 0) {
                failureStr = gai_strerror(failure);
                if (failureStr != NULL) {
                    result = @(failureStr);
                }
            }
        }
    }
    // Otherwise try various properties of the error object.
    if (result == nil) {
        result = error.localizedFailureReason;
    }
    if (result == nil) {
        result = error.localizedDescription;
    }
    assert(result != nil);
    return result;
}

*/

//****************************************************************************//
//****************************************************************************//


@interface SSHelpSimplePingManager()<SSHelpSimplePingDelegate>

@property(nonatomic, strong) dispatch_queue_t pingQueue;

@property(nonatomic, strong) NSOperationQueue *operationQueue;

@property(nonatomic, strong) NSMutableArray *requestArray;

@end

@implementation SSHelpSimplePingManager

+ (instancetype)manager
{
    static SSHelpSimplePingManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSHelpSimplePingManager alloc] init];
        manager.pingQueue = dispatch_queue_create("SSHelpSimplePingManager.Queue.Identifer", DISPATCH_QUEUE_SERIAL);
        manager.operationQueue = [[NSOperationQueue alloc] init];
        manager.operationQueue.maxConcurrentOperationCount = 10;
        manager.requestArray = [[NSMutableArray alloc] initWithCapacity:1];
    });
    return manager;
}

+ (void)ping:(NSString *)hostName callBack:(SSPingCallback)callback
{
    [SSHelpSimplePingManager pingHostNames:@[hostName] callback:^(NSArray * _Nonnull hostNames, NSArray<NSArray<SSHelpPingPacketItem *> *> * _Nonnull response) {
        __block BOOL success = NO;
        [response enumerateObjectsUsingBlock:^(NSArray<SSHelpPingPacketItem *> * _Nonnull packets, NSUInteger idx, BOOL * _Nonnull stop) {
            [packets enumerateObjectsUsingBlock:^(SSHelpPingPacketItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.connected) {
                    success = YES;
                    *stop = YES;
                }
            }];
        }];
        if (callback) {
            callback(success,response.firstObject);
        }
    }];
}

+ (void)pingHostNames:(NSArray <NSString *> *)hostNames callback:(SSPingHostNamesCallback)callBack
{
    __block  NSInteger handleCount = 0;
    __block NSMutableArray <NSArray <SSHelpPingPacketItem *> *> *response = [NSMutableArray arrayWithCapacity:hostNames.count];
    for (NSUInteger index=0; index<hostNames.count; index++) {
        [response addObject:@[]];
    }
    
    SSHelpSimplePingManager *manager = [SSHelpSimplePingManager manager];
    dispatch_async(manager.pingQueue, ^{
        [hostNames enumerateObjectsUsingBlock:^(NSString * _Nonnull host, NSUInteger idx, BOOL * _Nonnull stop) {
            [manager.operationQueue addOperationWithBlock:^{
                [SSHelpSinglePinger startWithHostName:host count:4 pingCallback:^(BOOL success, NSArray<SSHelpPingPacketItem *> * _Nonnull responsePackets) {
                    [response replaceObjectAtIndex:idx withObject:responsePackets?:@[]];
                    handleCount ++;
                    if (handleCount==hostNames.count) {
                        if (callBack) {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                callBack(hostNames, response);
                            });
                        }
                    }
                }];
            }];
        }];
    });
}

@end



//****************************************************************************//
//****************************************************************************//



@interface SSHelpPingPacketItem()
@property(nonatomic, assign) BOOL connected;
@property(nonatomic, assign) size_t length;
@property(nonatomic, copy  ) NSString *from;
@property(nonatomic, assign) uint16_t icmp_seq;
@property(nonatomic, assign) NSTimeInterval time;
@property(nonatomic, strong) NSDate *startDate;
@property(nonatomic, strong) NSTimer *outTimer;
- (void)clearOutTimer;
@end

@implementation SSHelpPingPacketItem

- (void)clearOutTimer
{
    if (_outTimer && _outTimer.isValid) {
        [_outTimer invalidate];
    }
    _outTimer = nil;
}

@end


//****************************************************************************//
//****************************************************************************//


@interface SSHelpSinglePinger() <SSHelpSimplePingDelegate>

@property(nonatomic, copy  ) NSString *hostName;

@property(nonatomic, strong) SSHelpSimplePing *pinger;

@property(nonatomic, strong) NSTimer *sendTimer;

@property(nonatomic, assign) NSInteger sendCount;

@property(nonatomic, assign) NSInteger sendIndex;

@property(nonatomic, assign) NSInteger receivedCount;

@property(nonatomic, strong) NSMutableArray <SSHelpPingPacketItem *> *responseItems;

@property(nonatomic, copy  ) SSPingCallback pingCallback;

+ (instancetype)startWithHostName:(NSString *)hostName count:(NSInteger)count pingCallback:(SSPingCallback)callback;

- (instancetype)initWithHostName:(NSString *)hostName count:(NSInteger)count pingCallback:(SSPingCallback)callback;

@end

@implementation SSHelpSinglePinger

+ (instancetype)startWithHostName:(NSString *)hostName count:(NSInteger)count pingCallback:(SSPingCallback)callback
{
    return [[self alloc] initWithHostName:hostName count:count pingCallback:callback];
}

- (instancetype)initWithHostName:(NSString *)hostName count:(NSInteger)count pingCallback:(SSPingCallback)callback
{
    if (self = [super init]) {
        self.hostName = hostName;
        self.sendCount = count;
        self.sendIndex = 0;
        self.receivedCount = 0;
        self.pingCallback = callback;
        self.responseItems = [[NSMutableArray alloc] initWithCapacity:count];
        
        self.pinger = [[SSHelpSimplePing alloc] initWithHostName:hostName];
        self.pinger.addressStyle = SSHelpSimplePingAddressStyleAny;
        self.pinger.delegate = self;
        [self.pinger start];
        
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        } while (self.pinger != nil);
    }
    return self;
}

- (void)dealloc
{
    //NSLog(@"%@ dealloc ... ",self.hostName);
    _pingCallback = nil;
    _pinger = nil;
}

- (void)clearSendTimer
{
    if (_sendTimer && _sendTimer.isValid) {
        [_sendTimer invalidate];
    }
    _sendTimer = nil;
}

#pragma mark - Private Methods

- (void)sendPing
{
    self.sendIndex += 1;
    if (self.sendIndex<=self.sendCount) {
        if (self.sendIndex==self.sendCount) {
            [self clearSendTimer];
        }
        __weak typeof(self) self_weak_ = self;
        SSHelpPingPacketItem *pingItem = [[SSHelpPingPacketItem alloc] init];
        pingItem.startDate = [NSDate date];
        pingItem.outTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:NO block:^(NSTimer * _Nonnull timer) {
            //超时算一次ping动作
            [self_weak_ receivePing];
        }];
        [self.responseItems addObject:pingItem];
        [self.pinger sendPingWithData:nil];
    }
}

- (void)receivePing
{
    self.receivedCount += 1; //接收数据包计数自增
    if (self.receivedCount == self.sendCount) {
        [self stopPing];
    }
}

- (void)stopPing
{
    [self clearSendTimer];
    if (self.pingCallback) {
        __block BOOL success = NO;
        [self.responseItems enumerateObjectsUsingBlock:^(SSHelpPingPacketItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj.connected) {
                success = YES;
                *stop = YES;
            }
        }];
        self.pingCallback(success,self.responseItems);
        self.pingCallback = nil;
        self.pinger = nil; //释放当前实例
    }
}

#pragma mark - Ping Delegate

// 解析 HostName 拿到 ip 地址之后，发送封包
- (void)simplePing:(SSHelpSimplePing *)pinger didStartWithAddress:(NSData *)address
{
    #pragma unused(pinger)
    assert(pinger == self.pinger);
    assert(address != nil);
    //NSLog(@"pinging %@", _displayAddressForAddress(address));
    
    // Send the first ping straight away.
    [self sendPing];
    // And start a timer to send the subsequent pings.
    assert(self.sendTimer == nil);

    __weak typeof(self) self_weak_ = self;
    self.sendTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [self_weak_ sendPing];
    }];
    //[[NSRunLoop currentRunLoop] addTimer:self.sendTimer forMode:NSDefaultRunLoopMode];
}

// ping 功能启动失败
- (void)simplePing:(SSHelpSimplePing *)pinger didFailWithError:(NSError *)error
{
    #pragma unused(pinger)
    assert(pinger == self.pinger);
    //SSLog(@"failed: %@", _shortErrorFromError(error));

    [self.sendTimer invalidate];
    self.sendTimer = nil;

    // No need to call -stop.  The pinger will stop itself in this case.
    // We do however want to nil out pinger so that the runloop stops.
    self.pinger = nil;
    
    //结束
    [self stopPing];
}

// ping 成功发送封包
- (void)simplePing:(SSHelpSimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    #pragma unused(pinger)
    assert(pinger == self.pinger);
    #pragma unused(packet)
    //NSlog(@"#%u sent host=%@", (unsigned int) sequenceNumber,pinger.hostName);
}


// ping 发送封包失败
- (void)simplePing:(SSHelpSimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error
{
    #pragma unused(pinger)
    assert(pinger == self.pinger);
    #pragma unused(packet)
    //SSLog(@"#%u send failed: %@", (unsigned int) sequenceNumber, _shortErrorFromError(error));
    
    if (sequenceNumber<self.responseItems.count) {
        SSHelpPingPacketItem *pingItem = self.responseItems[sequenceNumber];
        [pingItem clearOutTimer];
        pingItem.connected = NO;
    }
    
    //完成一次ping动作
    [self receivePing];
}

// ping 发送封包之后收到响应
- (void)simplePing:(SSHelpSimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber
{
    #pragma unused(pinger)
    assert(pinger == self.pinger);
    #pragma unused(packet)
    //NSlog(@"#%u received, size=%zu, host=%@", (unsigned int) sequenceNumber, (size_t) packet.length, pinger.hostName);
    
    if (sequenceNumber<self.responseItems.count) {
        SSHelpPingPacketItem *pingItem = self.responseItems[sequenceNumber];
        [pingItem clearOutTimer];
        
        pingItem.connected = YES;
        pingItem.time = [[NSDate date] timeIntervalSinceDate:pingItem.startDate] * 1000;
        pingItem.from = _displayAddressForAddress(pinger.hostAddress);
        pingItem.length = packet.length;
        pingItem.icmp_seq = sequenceNumber;
    }

    //完成一次ping动作
    [self receivePing];
}

// 接收到未知的包
- (void)simplePing:(SSHelpSimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet
{
    #pragma unused(pinger)
    assert(pinger == self.pinger);
    //NSlog(@"unexpected packet, size=%zu, host=%@", (size_t) packet.length,pinger.hostName);
    
    //未知的包不做任何处理
}

@end
