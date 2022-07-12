//
//  SSHelpNetworkRequest.h
//  SSHelpTools
//
//  Modification by 宋直兵 on 2021/9/13.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class SSHelpNetworkRequest,SSHelpNetworkBatchRequest, SSHelpNetworkChainRequest,SSNetUploadFormData;

/**
 Types enum for SSHelpNetworkRequest.
 */
typedef NS_ENUM(NSInteger, SSNetRequestType) {
    SSNetRequestNormal    = 0,    //!< Normal HTTP request type, such as GET, POST, ...
    SSNetRequestUpload    = 1,    //!< Upload request type
    SSNetRequestDownload  = 2,    //!< Download request type
};

/**
 HTTP methods enum for SSHelpNetworkRequest.
 */
typedef NS_ENUM(NSInteger, SSNetHTTPMethodType) {
    SSNetHTTPMethodGET    = 0,    //!< GET
    SSNetHTTPMethodPOST   = 1,    //!< POST
    SSNetHTTPMethodHEAD   = 2,    //!< HEAD
    SSNetHTTPMethodDELETE = 3,    //!< DELETE
    SSNetHTTPMethodPUT    = 4,    //!< PUT
    SSNetHTTPMethodPATCH  = 5,    //!< PATCH
};

/**
 Resquest parameter serialization type enum for SSHelpNetworkRequest, see `AFURLRequestSerialization.h` for details.
 */
typedef NS_ENUM(NSInteger, SSNetRequestSerializerType) {
    SSNetRequestSerializerRAW     = 0,    //!< Encodes parameters to a query string and put it into HTTP body, setting the `Content-Type` of the encoded request to default value `application/x-www-form-urlencoded`.
    SSNetRequestSerializerJSON    = 1,    //!< Encodes parameters as JSON using `NSJSONSerialization`, setting the `Content-Type` of the encoded request to `application/json`.
    SSNetRequestSerializerPlist   = 2,    //!< Encodes parameters as Property List using `NSPropertyListSerialization`, setting the `Content-Type` of the encoded request to `application/x-plist`.
};

/**
 Response data serialization type enum for SSHelpNetworkRequest, see `AFURLResponseSerialization.h` for details.
 */
typedef NS_ENUM(NSInteger, SSNetResponseSerializerType) {
    SSNetResponseSerializerRAW    = 0,    //!< Validates the response status code and content type, and returns the default response data.
    SSNetResponseSerializerJSON   = 1,    //!< Validates and decodes JSON responses using `NSJSONSerialization`, and returns a NSDictionary/NSArray/... JSON object.
    SSNetResponseSerializerPlist  = 2,    //!< Validates and decodes Property List responses using `NSPropertyListSerialization`, and returns a property list object.
    SSNetResponseSerializerXML    = 3,    //!< Validates and decodes XML responses as an `NSXMLParser` objects.
};

/**
 Network connection type enum
 */
typedef NS_ENUM(NSInteger, SSNetConnectionType) {
    SSNetworkConnectionTypeUnknown          = -1,
    SSNetworkConnectionTypeNotReachable     = 0,
    SSNetworkConnectionTypeViaWWAN          = 1,
    SSNetworkConnectionTypeViaWiFi          = 2,
};

///------------------------------
/// @name SSHelpNetworkRequest Config Blocks
///------------------------------

typedef void (^ _Nonnull SSNetRequestSetup)(SSHelpNetworkRequest * _Nonnull request);
typedef void (^ _Nonnull SSNetBatchRequestSetup)(SSHelpNetworkBatchRequest * _Nonnull batchRequest);
typedef void (^ _Nonnull SSNetChainRequestSetup)(SSHelpNetworkChainRequest *_Nonnull chainRequest);

///--------------------------------
/// @name SSHelpNetworkRequest Callback Blocks
///--------------------------------

typedef void (^ _Nullable SSNetProgress)(NSProgress * _Nullable progress);
typedef void (^ _Nullable SSNetSuccess) (id _Nullable responseObject);
typedef void (^ _Nullable SSNetFailure) (NSError * _Nullable error);
typedef void (^ _Nullable SSNetFinishe) (id _Nullable responseObject, NSError * _Nullable error);
typedef void (^ _Nullable SSNetCancel)  (NSData * _Nullable resumeData); // The `request` might be a SSHelpNetworkRequest/SSHelpNetworkBatchRequest/SSHelpNetworkChainRequest object.
/* Cancel the download (and calls the superclass -cancel).  If
* conditions will allow for resuming the download in the future, the
* callback will be called with an opaque data blob, which may be used
* with -downloadTaskWithResumeData: to attempt to resume the download.
* If resume data cannot be created, the completion handler will be
* called with nil resumeData.
*/

///-------------------------------------------------
/// @name Callback Blocks for Batch or Chain Request
///-------------------------------------------------

typedef void (^ _Nullable SSNetArrayFinished)(NSArray * _Nullable responseObjects);

typedef void (^ _Nonnull SSNetNextBlock)(SSHelpNetworkRequest * _Nonnull request, id _Nullable responseObject, BOOL * _Nullable sendNext);

///------------------------------
/// @name SSHelpNetworkCenter Process Blocks
///------------------------------

/**
 The custom request pre-process block for all SSHelpNetworkRequest invoked by SSHelpNetworkCenter.
 
 @param request The current SSHelpNetworkRequest object.
 */
typedef void (^ _Nullable SSNetCenterRequestProcess)(SSHelpNetworkRequest *_Nullable request);

/**
 The custom response process block for all SSHelpNetworkRequest invoked by SSHelpNetworkCenter.

 @param request The current SSHelpNetworkRequest object.
 @param responseObject The response data return from server.
 @param error The error that occurred while the response data don't conforms to your own business logic.
 */
typedef id _Nullable (^ _Nullable SSNetCenterResponseProcess)(SSHelpNetworkRequest * _Nullable request, id _Nullable responseObject, NSError * _Nullable __autoreleasing * _Nullable error);

/**
 The custom error process block for all SSHelpNetworkRequest invoked by SSHelpNetworkCenter.
 
 @param request The current SSHelpNetworkRequest object.
 @param error The error that occurred while the response data don't conforms to your own business logic.
 */
typedef void (^ _Nullable SSNetCenterErrorProcess)(SSHelpNetworkRequest * _Nullable request, NSError *__autoreleasing  _Nullable * _Nullable error);

#pragma mark -

/**
 `SSHelpNetworkRequest` is the base class for all network requests invoked by SSHelpNetworkCenter.
 */
@interface SSHelpNetworkRequest : NSObject

/**
 Creates and returns a new `SSHelpNetworkRequest` object.
 */
+ (instancetype)request;

/**
 The unique identifier for a SSHelpNetworkRequest object, the value is assigned by SSHelpNetworkCenter when the request is sent.
 */
@property (nonatomic, copy) NSString *identifier;

/**
 The server address for request, eg. "http://example.com/v1/", if `nil` (default) and the `useGeneralServer` property is `YES` (default), the `generalServer` of SSHelpNetworkCenter is used.
 */
@property (nonatomic, copy, nullable) NSString *server;

/**
 The API interface path for request, eg. "foo/bar", `nil` by default.
 */
@property (nonatomic, copy, nullable) NSString *api;

/**
 The final URL of request, which is combined by `server` and `api` properties, eg. "http://example.com/v1/foo/bar", `nil` by default.
 NOTE: when you manually set the value for `url`, the `server` and `api` properties will be ignored.
 */
@property (nonatomic, copy, nullable) NSString *url;

/**
 The parameters for request, if `useGeneralParameters` property is `YES` (default), the `generalParameters` of SSHelpNetworkCenter will be appended to the `parameters`.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *, id> *parameters;

/**
 The HTTP headers for request, if `useGeneralHeaders` property is `YES` (default), the `generalHeaders` of SSHelpNetworkCenter will be appended to the `headers`.
 */
@property (nonatomic, strong, nullable) NSDictionary <NSString *, NSString *> *headers;

/**
 Whether or not to use `generalServer` of SSHelpNetworkCenter when request `server` is `nil`, `YES` by default.
 */
@property (nonatomic, assign) BOOL useGeneralServer;

/**
 Whether or not to append `generalHeaders` of SSHelpNetworkCenter to request `headers`, `YES` by default.
 */
@property (nonatomic, assign) BOOL useGeneralHeaders;

/**
 Whether or not to append `generalParameters` of SSHelpNetworkCenter to request `parameters`, `YES` by default.
 */
@property (nonatomic, assign) BOOL useGeneralParameters;

/**
 Type for request: Normal, Upload or Download, `SSNetRequestNormal` by default.
 */
@property (nonatomic, assign) SSNetRequestType requestType;

/**
 HTTP method for request, `SSNetHTTPMethodPOST` by default, see `SSNetHTTPMethodType` enum for details.
 */
@property (nonatomic, assign) SSNetHTTPMethodType httpMethod;

/**
 Parameter serialization type for request, `SSNetRequestSerializerRAW` by default, see `SSNetRequestSerializerType` enum for details.
 */
@property (nonatomic, assign) SSNetRequestSerializerType requestSerializerType;

/**
 Response data serialization type for request, `SSNetResponseSerializerJSON` by default, see `SSNetResponseSerializerType` enum for details.
 */
@property (nonatomic, assign) SSNetResponseSerializerType responseSerializerType;

/**
 Timeout interval for request, `60` seconds by default.
 */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;

/**
 The retry count for current request when error occurred, `0` by default.
 */
@property (nonatomic, assign) NSUInteger retryCount;

/**
 User info for current request, which could be used to distinguish requests with same context, if `nil` (default), the `generalUserInfo` of SSHelpNetworkCenter is used.
 */
@property (nonatomic, strong, nullable) NSDictionary *userInfo;

/**
 Success block for request, called when current request completed successful, the block will execute in `callbackQueue` of SSHelpNetworkCenter.
 */
@property (nonatomic, copy, nullable) SSNetSuccess successBlock;

/**
 Failure block for request, called when error occurred, the block will execute in `callbackQueue` of SSHelpNetworkCenter.
 */
@property (nonatomic, copy, nullable) SSNetFailure failureBlock;

/**
 Finished block for request, called when current request is finished, the block will execute in `callbackQueue` of SSHelpNetworkCenter.
 */
@property (nonatomic, copy, nullable) SSNetFinishe finishedBlock;

/**
 Progress block for upload/download request, called when the upload/download progress is updated,
 NOTE: This block is called on the session queue, not the `callbackQueue` of SSHelpNetworkCenter !!!
 */
@property (nonatomic, copy, nullable) SSNetProgress progressBlock;

/**
 Nil out all callback blocks when a request is finished to break the potential retain cycle.
 */
- (void)cleanCallbackBlocks;

/**
 Upload files form data for upload request, `nil` by default, see `SSNetUploadFormData` class and `AFMultipartFormData` protocol for details.
 NOTE: This property is effective only when `requestType` is assigned to `SSNetRequestUpload`.
 */
@property (nonatomic, strong, nullable) NSMutableArray <SSNetUploadFormData *> *uploadFormDatas;

/**
 Local save path for downloaded file, `/Library/Caches/` by default.
 NOTE: This property is effective only when `requestType` is assigned to `SSNetRequestDownload`.
 */
@property (nonatomic, copy, nullable) NSString *downloadSavePath;

@property (nonatomic, copy, nullable) NSString *downloadFileName;

/**
 A download task with the resume data. This parameter contains information about where to continue downloading files. In other words, when you download 10 megabytes of file data, pause. So the next time you download it, you start at 10M, not at the beginning of the file. So to store this information, we define this property of the NSData type: resumeData. This data only contains the URL and how much data has been downloaded. It is not very large, so there is no need to worry about the memory problem.
 */
@property (nonatomic, strong, nullable) NSData *resumeData;

///----------------------------------------------------
/// @name Quickly Methods For Add Upload File Form Data
///----------------------------------------------------

- (void)addFormDataWithName:(NSString *)name
                   fileData:(NSData *)fileData;

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                   fileData:(NSData *)fileData;

- (void)addFormDataWithName:(NSString *)name
                    fileURL:(NSURL *)fileURL;

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                    fileURL:(NSURL *)fileURL;

@end

#pragma mark - SSHelpNetworkBatchRequest

///------------------------------------------------------
/// @name SSHelpNetworkBatchRequest Class for sending batch requests
///------------------------------------------------------

@interface SSHelpNetworkBatchRequest : NSObject

@property (nonatomic, copy  ) NSString *identifier;
@property (nonatomic, assign, readonly ) BOOL anyRequestFailed;
@property (nonatomic, strong, readonly) NSMutableArray *requestArray;
@property (nonatomic, strong, readonly) NSMutableArray *responseArray;
@property (nonatomic, strong) SSNetArrayFinished batchFinishedBlock;

- (void)addRequest:(SSHelpNetworkRequest *)request;

- (BOOL)handleFinishedRequest:(SSHelpNetworkRequest *)request
                     response:(nullable id)responseObject
                        error:(NSError * _Nullable)error;

- (void)cleanCallbackBlocks;

@end

#pragma mark - SSHelpNetworkChainRequest

///------------------------------------------------------
/// @name SSHelpNetworkChainRequest Class for sending chain requests
///------------------------------------------------------

@interface SSHelpNetworkChainRequest : NSObject

@property (nonatomic, copy  ) NSString *identifier;
@property (nonatomic, strong) SSHelpNetworkRequest *runningRequest;
@property (nonatomic, strong) SSNetArrayFinished chainFinishedBlock;

- (SSHelpNetworkChainRequest *)setupFirst:(SSNetRequestSetup)firstBlock;

- (SSHelpNetworkChainRequest *)toNext:(SSNetNextBlock)nextBlock;

- (BOOL)handleFinishedRequest:(SSHelpNetworkRequest *)request
                     response:(nullable id)responseObject
                        error:(NSError * _Nullable)error;

@end

#pragma mark - SSNetUploadFormData

/**
 `SSNetUploadFormData` is the class for describing and carring the upload file data, see `AFMultipartFormData` protocol for details.
 */
@interface SSNetUploadFormData : NSObject

/**
 The name to be associated with the specified data. This property must not be `nil`.
 */
@property (nonatomic, copy) NSString *name;

/**
 The file name to be used in the `Content-Disposition` header. This property is not recommended be `nil`.
 */
@property (nonatomic, copy, nullable) NSString *fileName;

/**
 The declared MIME type of the file data. This property is not recommended be `nil`.
 */
@property (nonatomic, copy, nullable) NSString *mimeType;

/**
 The data to be encoded and appended to the form data, and it is prior than `fileURL`.
 */
@property (nonatomic, strong, nullable) NSData *fileData;

/**
 The URL corresponding to the file whose content will be appended to the form, BUT, when the `fileData` is assigned，the `fileURL` will be ignored.
 */
@property (nonatomic, strong, nullable) NSURL *fileURL;

// NOTE: Either of the `fileData` and `fileURL` should not be `nil`, and the `fileName` and `mimeType` must both be `nil` or assigned at the same time,

///-----------------------------------------------------
/// @name Quickly Class Methods For Creates A New Object
///-----------------------------------------------------

+ (instancetype)formDataWithName:(NSString *)name
                        fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                        fileData:(NSData *)fileData;

+ (instancetype)formDataWithName:(NSString *)name
                         fileURL:(NSURL *)fileURL;

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                         fileURL:(NSURL *)fileURL;

@end

NS_ASSUME_NONNULL_END
