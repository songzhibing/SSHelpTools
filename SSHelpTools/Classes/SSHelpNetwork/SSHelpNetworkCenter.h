//
//  SSHelpNetworkCenter.h
//  SSHelpTools
//
//  Modification by 宋直兵 on 2021/9/13.
//

#import <Foundation/Foundation.h>
#import "SSHelpNetworkRequest.h"

NS_ASSUME_NONNULL_BEGIN

@class SSHelpNetworkConfig, SSHelpNetworkEngine;

/**
 `SSHelpNetworkCenter` is a global central place to send and manage all network requests.
 `+center` method is used to creates a new `SSHelpNetworkCenter` object,
 `+defaultCenter` method will return a default shared `SSHelpNetworkCenter` singleton object.
 
 The class methods for `SSHelpNetworkCenter` are invoked by `[SSHelpNetworkCenter defaultCenter]`, which are recommend to use `Class Method` instead of manager a `SSHelpNetworkCenter` yourself.
 
 Usage:
 
 (1) Config SSHelpNetworkCenter
 
 [[SSHelpNetworkCenter defaultCenter] setupConfig:^(SSHelpNetworkConfig *config) {
     config.server = @"general server address";
     config.headers = @{@"general header": @"general header value"};
     config.parameters = @{@"general parameter": @"general parameter value"};
     config.callbackQueue = dispatch_get_main_queue(); // set callback dispatch queue
 }];
 
 [[SSHelpNetworkCenter defaultCenter] setRequestProcessBlock:^(SSHelpNetworkRequest *request) {
     // Do the custom request pre processing logic by yourself.
 }];
 
 [[SSHelpNetworkCenter defaultCenter] setResponseProcessBlock:^(SSHelpNetworkRequest *request, id responseObject, NSError *__autoreleasing *error) {
     // Do the custom response data processing logic by yourself.
     // You can assign the passed in `error` argument when error occurred, and the failure block will be called instead of success block.
 }];
 
 (2) Send a Request
 
 [[SSHelpNetworkCenter defaultCenter] sendRequest:^(SSHelpNetworkRequest *request) {
     request.server = @"server address"; // optional, if `nil`, the genneal server is used.
     request.api = @"api path";
     request.parameters = @{@"param1": @"value1", @"param2": @"value2"}; // and the general parameters will add to reqeust parameters.
 } success:^(id responseObject) {
     // success code here...
 } failure:^(NSError *error) {
     // failure code here...
 }];
 
 */
@interface SSHelpNetworkCenter : NSObject

///---------------------
/// @name Initialization
///---------------------

/**
 Creates and returns a new `SSHelpNetworkCenter` object.
 */
+ (instancetype)center;

/**
 Returns the default shared `SSHelpNetworkCenter` singleton object.
 */
+ (instancetype)defaultCenter;

///-----------------------
/// @name General Property
///-----------------------

// NOTE: The following properties could only be assigned by `SSHelpNetworkConfig` through invoking `-setupConfig:` method.

/**
 The general server address for SSHelpNetworkCenter, if SSHelpNetworkRequest.server is `nil` and the SSHelpNetworkRequest.useGeneralServer is `YES`, this property will be assigned to SSHelpNetworkRequest.server.
 */
@property (nonatomic, copy, nullable) NSString *generalServer;

/**
 The general parameters for SSHelpNetworkCenter, if SSHelpNetworkRequest.useGeneralParameters is `YES` and this property is not empty, it will be appended to SSHelpNetworkRequest.parameters.
 */
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary<NSString *, id> *generalParameters;

/**
 The general headers for SSHelpNetworkCenter, if SSHelpNetworkRequest.useGeneralHeaders is `YES` and this property is not empty, it will be appended to SSHelpNetworkRequest.headers.
 */
@property (nonatomic, strong, nullable, readonly) NSMutableDictionary<NSString *, NSString *> *generalHeaders;

/**
 The general user info for SSHelpNetworkCenter, if SSHelpNetworkRequest.userInfo is `nil` and this property is not `nil`, it will be assigned to SSHelpNetworkRequest.userInfo.
 */
@property (nonatomic, strong, nullable) NSDictionary *generalUserInfo;

/**
 The dispatch queue for callback blocks. If `NULL` (default), the main queue is used.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;

/**
 The global requests engine for current SSHelpNetworkCenter object, `[SSHelpNetworkConfig sharedEngine]` by default.
 */
@property (nonatomic, strong) SSHelpNetworkEngine *engine;

/**
 Whether or not to print the request and response info in console, `NO` by default.
 */
@property (nonatomic, assign) BOOL consoleLog;

///--------------------------------------------
/// @name Instance Method to Configure SSHelpNetworkCenter
///--------------------------------------------

#pragma mark - Instance Method

/**
 Method to config the SSHelpNetworkCenter properties by a `SSHelpNetworkConfig` object.

 @param block The config block to assign the values for `SSHelpNetworkConfig` object.
 */
- (void)setupConfig:(void(^_Nonnull)(SSHelpNetworkConfig *_Nonnull config))block;

/**
 Method to set custom request pre processing block for SSHelpNetworkCenter.
 
 @param block The custom processing block (`SSHelpRequestProcessBlock`).
 */
- (void)setRequestProcessBlock:(SSNetCenterRequestProcess)block;

/**
 Method to set custom response data processing block for SSHelpNetworkCenter.

 @param block The custom processing block (`XMCenterResponseProcessBlock`).
 */
- (void)setResponseProcessBlock:(SSNetCenterResponseProcess)block;

/**
 Method to set custom error processing block for SSHelpNetworkCenter.
 
 @param block The custom processing block (`XMCenterErrorProcessBlock`).
 */
- (void)setErrorProcessBlock:(SSNetCenterErrorProcess)block;

/**
 Sets the value for the general HTTP headers of SSHelpNetworkCenter, If value is `nil`, it will remove the existing value for that header field.
 
 @param value The value to set for the specified header, or `nil`.
 @param field The HTTP header to set a value for.
 */
- (void)setGeneralHeaderValue:(nullable NSString *)value forField:(NSString *)field;

/**
 Sets the value for the general parameters of SSHelpNetworkCenter, If value is `nil`, it will remove the existing value for that parameter key.
 
 @param value The value to set for the specified parameter, or `nil`.
 @param key The parameter key to set a value for.
 */
- (void)setGeneralParameterValue:(nullable id)value forKey:(NSString *)key;

///---------------------------------------
/// @name Instance Method to Send Requests
///---------------------------------------

#pragma mark -

/**
 Creates and runs a Normal `SSHelpNetworkRequest`.

 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup;

/**
 Creates and runs a Normal `SSHelpNetworkRequest` with success block.
 
 NOTE: The success block will be called on `callbackQueue` of SSHelpNetworkCenter.

 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @param success Success callback block for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup success:(SSNetSuccess)success;

/**
 Creates and runs a Normal `SSHelpNetworkRequest` with failure block.
 
 NOTE: The failure block will be called on `callbackQueue` of SSHelpNetworkCenter.

 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @param failure Failure callback block for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup failure:(SSNetFailure)failure;

/**
 Creates and runs a Normal `SSHelpNetworkRequest` with finished block.

 NOTE: The finished block will be called on `callbackQueue` of SSHelpNetworkCenter.
 
 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @param finished Finished callback block for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup finished:(SSNetFinishe)finished;

/**
 Creates and runs a Normal `SSHelpNetworkRequest` with success/failure blocks.

 NOTE: The success/failure blocks will be called on `callbackQueue` of SSHelpNetworkCenter.
 
 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @param success Success callback block for the new created SSHelpNetworkRequest object.
 @param failure Failure callback block for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup success:(SSNetSuccess)success failure:(SSNetFailure)failure;

/**
 Creates and runs a Normal `SSHelpNetworkRequest` with success/failure/finished blocks.

 NOTE: The success/failure/finished blocks will be called on `callbackQueue` of SSHelpNetworkCenter.
 
 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @param success Success callback block for the new created SSHelpNetworkRequest object.
 @param failure Failure callback block for the new created SSHelpNetworkRequest object.
 @param finished Finished callback block for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup
                           success:(SSNetSuccess)success
                           failure:(SSNetFailure)failure
                          finished:(SSNetFinishe)finished;

/**
 Creates and runs an Upload/Download `SSHelpNetworkRequest` with progress/success/failure blocks.

 NOTE: The success/failure blocks will be called on `callbackQueue` of SSHelpNetworkCenter.
 BUT !!! the progress block is called on the session queue, not the `callbackQueue` of SSHelpNetworkCenter.
 
 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @param progress Progress callback block for the new created SSHelpNetworkRequest object.
 @param success Success callback block for the new created SSHelpNetworkRequest object.
 @param failure Failure callback block for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup
                          progress:(SSNetProgress)progress
                           success:(SSNetSuccess)success
                           failure:(SSNetFailure)failure;

/**
 Creates and runs an Upload/Download `SSHelpNetworkRequest` with progress/success/failure/finished blocks.

 NOTE: The success/failure/finished blocks will be called on `callbackQueue` of SSHelpNetworkCenter.
 BUT !!! the progress block is called on the session queue, not the `callbackQueue` of SSHelpNetworkCenter.
 
 @param setup The config block to setup context info for the new created SSHelpNetworkRequest object.
 @param progress Progress callback block for the new created SSHelpNetworkRequest object.
 @param success Success callback block for the new created SSHelpNetworkRequest object.
 @param failure Failure callback block for the new created SSHelpNetworkRequest object.
 @param finished Finished callback block for the new created SSHelpNetworkRequest object.
 @return Unique identifier for the new running SSHelpNetworkRequest object,`nil` for fail.
 */
- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup
                          progress:(SSNetProgress)progress
                           success:(SSNetSuccess)success
                           failure:(SSNetFailure)failure
                          finished:(SSNetFinishe)finished;

/**
 Creates and runs batch requests

 @param setup The config block to setup batch requests context info for the new created SSHelpNetworkBatchRequest object.
 @param finished Finished callback block for the new created SSHelpNetworkBatchRequest object.
 @return Unique identifier for the new running SSHelpNetworkBatchRequest object,`nil` for fail.
 */
- (nullable NSString *)sendBatchRequest:(SSNetBatchRequestSetup)setup
                               finished:(SSNetArrayFinished)finished;

/**
 Creates and runs chain requests

 @param setup The config block to setup chain requests context info for the new created SSHelpNetworkBatchRequest object.
 @param finished Finished callback block for the new created SSHelpNetworkChainRequest object.
 @return Unique identifier for the new running SSHelpNetworkChainRequest object,`nil` for fail.
 */
- (nullable NSString *)sendChainRequest:(SSNetChainRequestSetup)setup
                               finished:(SSNetArrayFinished)finished;

///------------------------------------------
/// @name Instance Method to Operate Requests
///------------------------------------------

#pragma mark -

/**
 Method to cancel a runnig request by identifier.
 
 @param identifier The unique identifier of a running request.
 */
- (void)cancelRequest:(NSString *)identifier;

/**
 Method to cancel a runnig request by identifier with a cancel block.
 
 NOTE: The cancel block is called on current thread who invoked the method, not the `callbackQueue` of SSHelpNetworkCenter.
 
 @param identifier The unique identifier of a running request.
 @param cancelBlock The callback block to be executed after the running request is canceled. The canceled request object (if exist) will be passed in argument to the cancel block.
 */
- (void)cancelRequest:(NSString *)identifier cancel:(SSNetCancel)cancelBlock;

/**
 Method to get a runnig request object matching to identifier.
 
 @param identifier The unique identifier of a running request.
 @return return The runing SSHelpNetworkRequest/SSHelpNetworkBatchRequest/SSHelpNetworkChainRequest object (if exist) matching to identifier.
 */
- (nullable id)getRequest:(NSString *)identifier;

/**
 Method to get current network reachablity status.
 
 @return The network is reachable or not.
 */
- (BOOL)isNetworkReachable;

/**
 Method to get current network connection type.
 
 @return The network connection type, see `SSNetConnectionType` for details.
 */
- (SSNetConnectionType)networkConnectionType;

@end

///-----------------------------------------------
/// @name Properties to Assign Values for SSHelpNetworkCenter
///-----------------------------------------------

@interface SSHelpNetworkConfig : NSObject

/**
The general server address to assign for SSHelpNetworkCenter.
*/
@property (nonatomic, copy, nullable) NSString *generalServer;

/**
 The general parameters to assign for SSHelpNetworkCenter.
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, id> *generalParameters;

/**
 The general headers to assign for SSHelpNetworkCenter.
 */
@property (nonatomic, strong, nullable) NSDictionary<NSString *, NSString *> *generalHeaders;

/**
 The general user info to assign for SSHelpNetworkCenter.
 */
@property (nonatomic, strong, nullable) NSDictionary *generalUserInfo;

/**
 The dispatch callback queue to assign for SSHelpNetworkCenter.
 */
@property (nonatomic, strong, nullable) dispatch_queue_t callbackQueue;

/**
 The global requests engine to assign for SSHelpNetworkCenter.
 */
@property (nonatomic, strong, nullable) SSHelpNetworkEngine *engine;

/**
 The console log BOOL value to assign for SSHelpNetworkCenter.
 */
@property (nonatomic, assign) BOOL consoleLog;

@end

NS_ASSUME_NONNULL_END
