//
//  SSHelpNetworkConfig.h
//  SSHelpTools
//
//  Modification by 宋直兵 on 2021/9/13.
//

#import <Foundation/Foundation.h>
#import "SSHelpNetworkRequest.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#else
#import "AFNetworking.h"
#import "AFNetworkActivityIndicatorManager.h"
#endif

NS_ASSUME_NONNULL_BEGIN

///---------------------
/// @name Category
///---------------------
@interface NSURLSessionTask (SSHelpNetworkRequest)

/**
 Retain `SSHelpNetworkRequest` object.
 */
@property (nonatomic, strong) SSHelpNetworkRequest *bindedRequest;

@end

/**
 `SSHelpNetworkConfig` is a global engine to lauch the all network requests, which package the API of `AFNetworking`.
 */
@interface SSHelpNetworkEngine : NSObject

///---------------------
/// @name Initialization
///---------------------

/**
 Creates and returns a new `SSHelpNetworkConfig` object.
 */
+ (instancetype)engine;

/**
 Returns the default shared `SSHelpNetworkConfig` singleton object.
 */
+ (instancetype)sharedEngine;

///------------------------
/// @name Request Operation
///------------------------

/**
 Runs a real network reqeust with a `SSHelpNetworkRequest` object and completion handler block.
 
 @param request The `SSHelpNetworkRequest` object to be launched.
 @param completion The completion block for network response callback.
 */
- (void)sendRequest:(SSHelpNetworkRequest *)request completion:(SSNetFinishe)completion;

/**
 Method to cancel a runnig request by identifier
 
 @param identifier The unique identifier of a running request.
 */
- (void)cancel:(NSString *)identifier completion:(SSNetCancel)completion;

/**
 Method to get a runnig request object matching to identifier.
 
 @param identifier The unique identifier of a running request.
 @return return The runing requset object (if exist) matching to identifier.
 */
- (nullable SSHelpNetworkRequest *)getRequest:(NSString *)identifier;

///--------------------------
/// @name Network Reachablity
///--------------------------

/**
 Method to get the current network reachablity status, see `AFNetworkReachabilityManager.h` for details.

 @return Network reachablity status code
 */
- (NSInteger)reachabilityStatus;

/**
 [NSURLSessionConfiguration defaultSessionConfiguration] by default
 */
@property(nonatomic, strong) NSURLSessionConfiguration *configuration;

///----------------------------
/// @name SSL Pinning for HTTPS
///----------------------------

/**
 [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate]  by default
 */
@property(nonatomic, strong) AFSecurityPolicy *securityPolicy;

/**
 Add host url of a server whose trust should be evaluated against the pinned SSL certificates.

 @param url The host url of a server.
 */
- (void)addSSLPinningURL:(NSString *)url;

/**
 Add certificate used to evaluate server trust according to the SSL pinning URL.

 @param cert The local pinnned certificate data.
 */
- (void)addSSLPinningCert:(NSData *)cert;

///---------------------------------------
/// @name Two-way Authentication for HTTPS
///---------------------------------------

/**
 Add client p12 certificate used for HTTPS Two-way Authentication.

 @param p12 The PKCS#12 certificate file data.
 @param password The special key password for PKCS#12 data.
 */
- (void)addTwowayAuthenticationPKCS12:(NSData *)p12 keyPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
