//
//  SSHelpNetworkConfig.m
//  SSHelpTools
//
//  Modification by 宋直兵 on 2021/9/13.
//
#import "SSHelpNetworkEngine.h"
#import "SSHelpNetworkRequest.h"
#import <objc/runtime.h>

#ifdef DEBUG
    #import <ReactiveObjC/ReactiveObjC.h>
#endif

static OSStatus SSNetExtractIdentityAndTrustFromPKCS12(CFDataRef inPKCS12Data, CFStringRef keyPassword, SecIdentityRef *outIdentity, SecTrustRef *outTrust) {
    OSStatus securityError = errSecSuccess;
    
    const void *keys[] = { kSecImportExportPassphrase };
    const void *values[] = { keyPassword };
    CFDictionaryRef optionsDictionary = NULL;
    
    /* Create a dictionary containing the passphrase if one was specified. Otherwise, create an empty dictionary. */
    optionsDictionary = CFDictionaryCreate(NULL, keys, values, (keyPassword ? 1 : 0), NULL, NULL);
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inPKCS12Data, optionsDictionary, &items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex(items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemIdentity);
        CFRetain(tempIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        CFRetain(tempTrust);
        *outTrust = (SecTrustRef)tempTrust;
    }
    
    if (optionsDictionary) {
        CFRelease(optionsDictionary);
    }
    
    if (items) {
        CFRelease(items);
    }
    
    return securityError;
}

#pragma mark - SSHelpNetworkRequest Binding

@implementation NSURLSessionTask (SSHelpNetworkRequest)

- (SSHelpNetworkRequest *)bindedRequest
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setBindedRequest:(SSHelpNetworkRequest *)bindedRequest
{
    objc_setAssociatedObject(self, @selector(bindedRequest), bindedRequest, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

@end

#pragma mark - SSHelpNetworkConfig

@interface SSHelpNetworkEngine ()

@property(nonatomic, strong) AFNetworkReachabilityManager *reachablilityManager;
@property(nonatomic, strong) NSLock *lock;
@property(nonatomic, strong) AFURLSessionManager *sessionManager;
@property(nonatomic, strong) AFURLSessionManager *securitySessionManager;

@property(nonatomic, strong) AFHTTPRequestSerializer *afHTTPRequestSerializer;
@property(nonatomic, strong) AFJSONRequestSerializer *afJSONRequestSerializer;
@property(nonatomic, strong) AFPropertyListRequestSerializer *afPListRequestSerializer;

@property(nonatomic, strong) NSMutableArray *sslPinningHosts;

@end

@implementation SSHelpNetworkEngine

+ (instancetype)engine
{
    return [[[self class] alloc] init];
}

+ (instancetype)sharedEngine
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self engine];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _lock = [[NSLock alloc] init];
        _configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        _sslPinningHosts = [NSMutableArray array];
        _securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeCertificate];
        
        _reachablilityManager = [AFNetworkReachabilityManager manager];
        [_reachablilityManager startMonitoring];
    }
    return self;
}

- (void)dealloc
{
    [_reachablilityManager stopMonitoring];

    if (_sessionManager) {
        //[_sessionManager invalidateSessionCancelingTasks:YES resetSession:YES];
    }
    if (_securitySessionManager) {
        //[_securitySessionManager invalidateSessionCancelingTasks:YES resetSession:YES];
    } 
}

#pragma mark - Public Methods

/**
 Method to cancel a runnig request by identifier
 
 @param identifier The unique identifier of a running request.
 */
- (void)cancel:(NSString *)identifier completion:(SSNetCancel)completion
{
    if (identifier.length == 0)
    {
        if (completion) {
            completion(nil);
        }
        return;
    }
    
    [self.lock lock];
    
    NSArray *tasks = nil;
    if ([identifier hasPrefix:@"+"]) {
        tasks = self.sessionManager.tasks;
    } else if ([identifier hasPrefix:@"-"]) {
        tasks = self.securitySessionManager.tasks;
    }
    __block __kindof NSURLSessionTask *task = nil;
    if (tasks.count > 0) {
        [tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *obj, NSUInteger idx, BOOL *stop) {
            if ([obj.bindedRequest.identifier isEqualToString:identifier]) {
                task = obj;
                *stop = YES;
            }
        }];
    }
    [self.lock unlock];

    if (task && [task isKindOfClass:[NSURLSessionDownloadTask class]]) {
        [(NSURLSessionDownloadTask *)task cancelByProducingResumeData:^(NSData * _Nullable resumeData) {
            if (completion) {
                completion(resumeData);
            }
            task = nil;
        }];
    }else{
        if (task) {
            [task cancel];
        }
        if (completion) {
            completion(nil);
        }
    }
}

- (nullable SSHelpNetworkRequest *)getRequest:(NSString *)identifier
{
    if (identifier.length == 0) return nil;
    
    [self.lock lock];

    NSArray *tasks = nil;
    if ([identifier hasPrefix:@"+"]) {
        tasks = self.sessionManager.tasks;
    } else if ([identifier hasPrefix:@"-"]) {
        tasks = self.securitySessionManager.tasks;
    }
    __block SSHelpNetworkRequest *request = nil;
    [tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL *stop) {
        if ([task.bindedRequest.identifier isEqualToString:identifier]) {
            request = task.bindedRequest;
            *stop = YES;
        }
    }];
    [self.lock unlock];
    return request;
}

- (NSInteger)reachabilityStatus
{
    return _reachablilityManager.networkReachabilityStatus;
}

/// 发送请求
- (void)sendRequest:(SSHelpNetworkRequest *)request completion:(SSNetFinishe)completionHandler
{
    NSString *httpMethod = @"POST";
    switch (request.httpMethod){
        case SSNetHTTPMethodGET:
            httpMethod = @"GET";
            break;
        case SSNetHTTPMethodPOST:
            httpMethod = @"POST";
            break;
        case SSNetHTTPMethodHEAD:
            httpMethod = @"HEAD";
            break;
        case SSNetHTTPMethodDELETE:
            httpMethod = @"DELETE";
            break;
        case SSNetHTTPMethodPUT:
            httpMethod = @"PUT";
            break;
        case SSNetHTTPMethodPATCH:
            httpMethod = @"PATCH";
            break;
        default:
            break;
    }
    
    //匹配请求Session
    AFURLSessionManager *sessionManager = [self p_getMatchedSessionManager:request];
    
    //匹配请求序列化
    AFHTTPRequestSerializer *requestSerializer = [self p_getMatchedRequestSerializer:request];
    
    __block NSError *serializationError = nil;
    NSMutableURLRequest *urlRequest = nil;
    
    //上传请求序列化
    if(SSNetRequestUpload == request.requestType){
        urlRequest = [requestSerializer multipartFormRequestWithMethod:httpMethod
                                                             URLString:request.url
                                                            parameters:request.parameters
                                             constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            [request.uploadFormDatas enumerateObjectsUsingBlock:^(SSNetUploadFormData *obj, NSUInteger idx, BOOL *stop) {
                if (obj.fileData) {
                    if (obj.fileName && obj.mimeType) {
                        [formData appendPartWithFileData:obj.fileData name:obj.name fileName:obj.fileName mimeType:obj.mimeType];
                    } else {
                        [formData appendPartWithFormData:obj.fileData name:obj.name];
                    }
                } else if (obj.fileURL) {
                    NSError *fileError = nil;
                    if (obj.fileName && obj.mimeType) {
                        [formData appendPartWithFileURL:obj.fileURL name:obj.name fileName:obj.fileName mimeType:obj.mimeType error:&fileError];
                    } else {
                        [formData appendPartWithFileURL:obj.fileURL name:obj.name error:&fileError];
                    }
                    if (fileError) {
                        serializationError = fileError;
                        *stop = YES;
                    }
                }
            }];
        } error:&serializationError];
    } else {
        //普通&&下载请求序列化
        urlRequest = [requestSerializer requestWithMethod:httpMethod
                                                URLString:request.url
                                               parameters:request.parameters
                                                    error:&serializationError];
    }
    
    //请求头部信息
    for (NSString *headerField in request.headers.keyEnumerator) {
        [urlRequest setValue:request.headers[headerField] forHTTPHeaderField:headerField];
    }
    
    //请求超时时间
    urlRequest.timeoutInterval = request.timeoutInterval;
    
    //请求序列化失败
    if (serializationError) {
        if (completionHandler) {
            completionHandler(nil, serializationError);
        }
        return;
    }
    
    __weak __typeof(self) __weak_self = self;
    __kindof NSURLSessionDataTask *dataTask = nil;
    
    //上传请求
    if(SSNetRequestUpload == request.requestType){
        dataTask = [sessionManager uploadTaskWithStreamedRequest:urlRequest progress:request.progressBlock  completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong typeof(__weak_self) __strong_self = __weak_self;
            [__strong_self p_didReceiveResponse:response
                                         object:responseObject
                                          error:error
                                        request:request
                              completionHandler:completionHandler];
        }];
    } else if(SSNetRequestDownload == request.requestType) {
        //下载请求
        NSURL *(^__destination)(NSURL *targetPath, NSURLResponse *response)  = ^NSURL *(NSURL *targetPath, NSURLResponse *response) {
            if (request.downloadSavePath && request.downloadSavePath.length) {
                //指定目录，并创建
                if(![[NSFileManager defaultManager] fileExistsAtPath:request.downloadSavePath]){
                    [[NSFileManager defaultManager] createDirectoryAtPath:request.downloadSavePath withIntermediateDirectories:YES attributes:nil error:NULL];
                }
            } else {
                //没有指定目录，则默认Cache目录
                request.downloadSavePath =  [NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask, YES) firstObject];
            }
            if (request.downloadFileName && request.downloadFileName.length) {
                //自定义文件名
            } else {
                //截取文件名
                request.downloadFileName = [response suggestedFilename];
            }
            return [NSURL fileURLWithPath:[NSString pathWithComponents:@[request.downloadSavePath, request.downloadFileName]] isDirectory:NO];
        };
        
        //断点下载
        if (request.resumeData) {
            dataTask = (__kindof NSURLSessionDataTask *)[sessionManager downloadTaskWithResumeData:request.resumeData progress:request.progressBlock destination:__destination completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (completionHandler) {
                    completionHandler(filePath, error);
                }
            }];
        //新下载
        } else {
            dataTask =  (__kindof NSURLSessionDataTask *)[sessionManager downloadTaskWithRequest:urlRequest progress:request.progressBlock destination:__destination completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (completionHandler) {
                    completionHandler(filePath, error);
                }
            }];
        }
    } else {
        //普通请求
        dataTask = [sessionManager dataTaskWithRequest:urlRequest uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
            __strong typeof(__weak_self) __strong_self = __weak_self;
            [__strong_self p_didReceiveResponse:response
                                         object:responseObject
                                          error:error
                                        request:request
                              completionHandler:completionHandler];
         }];
    }
    
    //标识Request
    [self p_setIdentifierForReqeust:request
                     taskIdentifier:dataTask.taskIdentifier
                     sessionManager:sessionManager];
    
    //绑定Request到DataTask
    [dataTask setBindedRequest:request];
    
    //最后,开始请求
    [dataTask resume];
    
#ifdef DEBUG
    [[dataTask rac_willDeallocSignal] subscribeNext:^(id  _Nullable x) {
        NSLog(@"%@ dealloc...",x);
    }];
#endif
}

/// 处理请求结果
- (void)p_didReceiveResponse:(NSURLResponse *)response
                      object:(id)responseObject
                       error:(NSError *)error
                     request:(SSHelpNetworkRequest *)request
           completionHandler:(SSNetFinishe)completionHandler
{
    NSError *serializationError = nil;
    if (request.responseSerializerType != SSNetResponseSerializerRAW){
        AFHTTPResponseSerializer *responseSerializer = [self p_getMatchedResponseSerializer:request];
        responseObject = [responseSerializer responseObjectForResponse:response
                                                                  data:responseObject
                                                                 error:&serializationError];
    }
    
    if (completionHandler) {
        if (serializationError) {
            completionHandler(nil, serializationError);
        } else {
            completionHandler(responseObject, error);
        }
    }
}

/// 构建自定义SSHelpNetworkRequest的identifier
- (void)p_setIdentifierForReqeust:(SSHelpNetworkRequest *)request
                    taskIdentifier:(NSUInteger)taskIdentifier
                    sessionManager:(AFURLSessionManager *)sessionManager
{
    NSString *identifier = nil;
    if (sessionManager == self.sessionManager)
    {
        identifier = [NSString stringWithFormat:@"+%lu", (unsigned long)taskIdentifier];
    }
    else if (sessionManager == self.securitySessionManager)
    {
        identifier = [NSString stringWithFormat:@"-%lu", (unsigned long)taskIdentifier];
    }
    request.identifier = identifier;
}

///----------------------------
/// @name SSL Pinning for HTTPS
///----------------------------

#pragma mark - SSL Pinning for HTTPS

- (void)addSSLPinningURL:(NSString *)url
{
    NSParameterAssert(url);
    if ([url hasPrefix:@"https"]) {
        NSString *newHost = [self p_getHostFromURLString:url];
        if (newHost && ![self.sslPinningHosts containsObject:newHost]) {
            [self.sslPinningHosts addObject:newHost];
        }
    }
}

- (void)addSSLPinningCert:(NSData *)cert
{
    NSParameterAssert(cert);
    
    NSMutableSet *certSet;
    if (self.securitySessionManager.securityPolicy.pinnedCertificates.count > 0) {
        certSet = [NSMutableSet setWithSet:self.securitySessionManager.securityPolicy.pinnedCertificates];
    } else {
        certSet = [NSMutableSet set];
    }
    [certSet addObject:cert];
    [self.securitySessionManager.securityPolicy setPinnedCertificates:certSet];
}

- (void)addTwowayAuthenticationPKCS12:(NSData *)p12 keyPassword:(NSString *)password
{
    NSParameterAssert(p12);
    NSParameterAssert(password);
    
    __weak __typeof(self) __weak_self = self;
    [self.securitySessionManager setSessionDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
        __strong __typeof(__weak_self) __strong_self = __weak_self;
        NSURLSessionAuthChallengeDisposition disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            // Server Trust (SSL Pinning)
            if ([__strong_self.securitySessionManager.securityPolicy evaluateServerTrust:challenge.protectionSpace.serverTrust forDomain:challenge.protectionSpace.host]) {
                *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
                if (*credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
            } else {
                disposition = NSURLSessionAuthChallengeCancelAuthenticationChallenge;
            }
        } else if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodClientCertificate]) {
            // Client Certificate (Two-way Authentication)
            SecIdentityRef identity = NULL;
            SecTrustRef trust = NULL;
            
            if (SSNetExtractIdentityAndTrustFromPKCS12((__bridge CFDataRef)p12, (__bridge CFStringRef)password, &identity, &trust) == 0) {
                SecCertificateRef certificate = NULL;
                SecIdentityCopyCertificate(identity, &certificate);
                
                const void *certs[] = { certificate };
                CFArrayRef certArray = CFArrayCreate(kCFAllocatorDefault, certs, 1, NULL);
                *credential = [NSURLCredential credentialWithIdentity:identity certificates:(__bridge NSArray *)certArray persistence:NSURLCredentialPersistencePermanent];
                if (*credential) {
                    disposition = NSURLSessionAuthChallengeUseCredential;
                } else {
                    disposition = NSURLSessionAuthChallengePerformDefaultHandling;
                }
                
                if (certificate) {
                    CFRelease(certificate);
                }
                if (certArray) {
                    CFRelease(certArray);
                }
            }
            
            if (identity) {
                CFRelease(identity);
            }
            if (trust) {
                CFRelease(trust);
            }
        } else {
            disposition = NSURLSessionAuthChallengePerformDefaultHandling;
        }
        
        return disposition;
    }];
}

/// 解析出主域名
- (NSString *)p_getHostFromURLString:(NSString *)urlString
{
    NSString *host = [[NSURL URLWithString:urlString] host];
    /**
    // Separate the host into its constituent components, e.g. [@"secure", @"twitter", @"com"]
    NSArray * hostComponents = [host componentsSeparatedByString:@"."];
    if ([hostComponents count] >= 2) {
        // Create a string out of the last two components in the host name, e.g. @"twitter" and @"com"
        host = [NSString stringWithFormat:@"%@.%@", [hostComponents objectAtIndex:(hostComponents.count - 2)], [hostComponents objectAtIndex:(hostComponents.count - 1)]];
    }
    */
    return host;
}


- (BOOL)p_matchedSSLPinningWithURL:(NSString *)urlString
{
    if (urlString && [urlString hasPrefix:@"https"]){
        NSString *host = [self p_getHostFromURLString:urlString];
        if ([self.sslPinningHosts containsObject:host]){
            return YES;
        }
    }
    return NO;
}

/// 选择响应的Session
- (AFURLSessionManager *)p_getMatchedSessionManager:(SSHelpNetworkRequest *)request
{
    if ([self p_matchedSSLPinningWithURL:request.url])
    {
        return self.securitySessionManager;
    }
    else
    {
        return self.sessionManager;
    }
}

/// 选择相应的请求序列化
- (AFHTTPRequestSerializer *)p_getMatchedRequestSerializer:(SSHelpNetworkRequest *)request
{
    if (request.requestSerializerType == SSNetRequestSerializerRAW)
    {
        return self.afHTTPRequestSerializer;
    }
    else if(request.requestSerializerType == SSNetRequestSerializerJSON)
    {
        return self.afJSONRequestSerializer;
    }
    else if (request.requestSerializerType == SSNetRequestSerializerPlist)
    {
        return self.afPListRequestSerializer;
    }
    else
    {
        NSAssert(NO, @"Unknown request serializer type.");
        return nil;
    }
}

/// 选择相应的响应报文序列化
- (AFHTTPResponseSerializer *)p_getMatchedResponseSerializer:(SSHelpNetworkRequest *)request
{
    if (request.responseSerializerType == SSNetResponseSerializerRAW)
    {
        return self.afHTTPResponseSerializer;
    }
    else if (request.responseSerializerType == SSNetResponseSerializerJSON)
    {
        return self.afJSONResponseSerializer;
    }
    else if (request.responseSerializerType == SSNetResponseSerializerPlist)
    {
        return self.afPListResponseSerializer;
    }
    else if (request.responseSerializerType == SSNetResponseSerializerXML)
    {
        return self.afXMLResponseSerializer;
    }
    else
    {
        NSAssert(NO, @"Unknown response serializer type.");
        return nil;
    }
}

#pragma mark - AF SessionManager

- (AFURLSessionManager *)sessionManager
{
    if (!_sessionManager) {
        _sessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:self.configuration];
        _sessionManager.responseSerializer = self.afHTTPResponseSerializer;
        _sessionManager.securityPolicy = [AFSecurityPolicy defaultPolicy];
        _sessionManager.securityPolicy.allowInvalidCertificates = YES; //使用允许无效或过期的证书，默认是不允许。
        _sessionManager.securityPolicy.validatesDomainName = NO; //是否验证证书中的域名domain
    }
    return _sessionManager;
}

- (AFURLSessionManager *)securitySessionManager
{
    if (!_securitySessionManager) {
        _securitySessionManager = [[AFURLSessionManager alloc] initWithSessionConfiguration:self.configuration];
        _securitySessionManager.responseSerializer = self.afHTTPResponseSerializer;
        _securitySessionManager.securityPolicy = self.securityPolicy;
    }
    return _securitySessionManager;
}

#pragma mark - AF RequestSerializer

- (AFHTTPRequestSerializer *)afHTTPRequestSerializer
{
    if (!_afHTTPRequestSerializer) {
        _afHTTPRequestSerializer = [AFHTTPRequestSerializer serializer];
    }
    return _afHTTPRequestSerializer;
}

- (AFJSONRequestSerializer *)afJSONRequestSerializer
{
    if (!_afJSONRequestSerializer) {
        _afJSONRequestSerializer = [AFJSONRequestSerializer serializer];
        
    }
    return _afJSONRequestSerializer;
}

- (AFPropertyListRequestSerializer *)afPListRequestSerializer
{
    if (!_afPListRequestSerializer) {
        _afPListRequestSerializer = [AFPropertyListRequestSerializer serializer];
    }
    return _afPListRequestSerializer;
}

#pragma mark - AF ResponseSerializer

- (AFHTTPResponseSerializer *)afHTTPResponseSerializer
{
    static AFHTTPResponseSerializer *afHTTPResponseSerializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afHTTPResponseSerializer = [AFHTTPResponseSerializer serializer];
    });
    return afHTTPResponseSerializer;
}

- (AFJSONResponseSerializer *)afJSONResponseSerializer
{
    static AFJSONResponseSerializer *afJSONResponseSerializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afJSONResponseSerializer = [AFJSONResponseSerializer serializer];
        afJSONResponseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", @"text/plain", nil];

    });
    return afJSONResponseSerializer;
}

- (AFXMLParserResponseSerializer *)afXMLResponseSerializer
{
    static AFXMLParserResponseSerializer *afXMLResponseSerializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afXMLResponseSerializer = [AFXMLParserResponseSerializer serializer];
    });
    return afXMLResponseSerializer;
}

- (AFPropertyListResponseSerializer *)afPListResponseSerializer
{
    static AFPropertyListResponseSerializer *afPListResponseSerializer;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        afPListResponseSerializer = [AFPropertyListResponseSerializer serializer];
    });
    return afPListResponseSerializer;
}

@end
