//
//  SSHelpNetworkCenter.m
//  SSHelpTools
//
//  Modification by 宋直兵 on 2021/9/13.
//

#import "SSHelpNetworkCenter.h"
#import "SSHelpNetworkEngine.h"

///-----------------------------------------------------------------------------
/// @name SSHelpNetworkConfig
///-----------------------------------------------------------------------------

@implementation SSHelpNetworkConfig

@end

///-----------------------------------------------------------------------------
/// @name SSHelpNetworkCenter
///-----------------------------------------------------------------------------

static NSInteger kSSHelpRequestIndex = 0;

@interface SSHelpNetworkCenter ()
@property(nonatomic, strong, readwrite) NSLock *lock;
@property(nonatomic, strong) NSMutableDictionary<NSString *, id> *runningBatchAndChainPool;
@property(nonatomic, strong, readwrite) NSMutableDictionary<NSString *, id> *generalParameters;
@property(nonatomic, strong, readwrite) NSMutableDictionary<NSString *, NSString *> *generalHeaders;

@property(nonatomic, copy) SSNetCenterRequestProcess  requestProcessHandler;
@property(nonatomic, copy) SSNetCenterResponseProcess responseProcessHandler;
@property(nonatomic, copy) SSNetCenterErrorProcess    errorProcessHandler;

@end

@implementation SSHelpNetworkCenter

- (void)dealloc
{
    if (_consoleLog){
        #ifdef DEBUG
        NSLog(@"[SSNET LOG] %@ dealloc......",self);
        #endif
    }
}

+ (instancetype)defaultCenter
{
    static id sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [self center];
    });
    return sharedInstance;
}

+ (instancetype)center
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _consoleLog = NO;
        _lock = [[NSLock alloc] init];
        _runningBatchAndChainPool = [NSMutableDictionary dictionary];
        _generalParameters = [NSMutableDictionary dictionary];
        _generalHeaders = [NSMutableDictionary dictionary];
        
        _engine = [SSHelpNetworkEngine engine];
        _callbackQueue = dispatch_get_main_queue();
    }
    return self;
}

#pragma mark - Public Instance Methods for SSHelpNetworkCenter

- (void)setupConfig:(void(^_Nonnull)(SSHelpNetworkConfig *_Nonnull config))block
{
    __block SSHelpNetworkConfig *config = [[SSHelpNetworkConfig alloc] init];
    
    block(config);
        
    if (config.generalServer) {
        self.generalServer = config.generalServer;
    }
    if (config.generalParameters.count > 0) {
        [self.generalParameters addEntriesFromDictionary:config.generalParameters];
    }
    if (config.generalHeaders.count > 0) {
        [self.generalHeaders addEntriesFromDictionary:config.generalHeaders];
    }
    if (config.callbackQueue) {
        self.callbackQueue = config.callbackQueue;
    }
    if (config.generalUserInfo) {
        self.generalUserInfo = config.generalUserInfo;
    }
    if (config.engine) {
        self.engine = config.engine;
    }
    self.consoleLog = config.consoleLog;
}

- (void)setRequestProcessBlock:(SSNetCenterRequestProcess)block
{
    self.requestProcessHandler = block;
}

- (void)setResponseProcessBlock:(SSNetCenterResponseProcess)block
{
    self.responseProcessHandler = block;
}

- (void)setErrorProcessBlock:(SSNetCenterErrorProcess)block
{
    self.errorProcessHandler = block;
}

- (void)setGeneralHeaderValue:(NSString *)value forField:(NSString *)field
{
    if (value) {
        [self.generalHeaders setValue:value forKey:field];
    } else {
        if ([self.generalHeaders.allKeys containsObject:field]) {
            [self.generalHeaders removeObjectForKey:field];
        }
    }
}

- (void)setGeneralParameterValue:(id)value forKey:(NSString *)key
{
    if (value) {
        [self.generalParameters setValue:value forKey:key];
    } else {
        if ([self.generalParameters.allKeys containsObject:key]) {
            [self.generalParameters removeObjectForKey:key];
        }
    }
}

#pragma mark - 发送请求

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup
{
    return [self sendRequest:setup
                    progress:nil
                     success:nil
                     failure:nil
                    finished:nil];
}

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup success:(SSNetSuccess)success
{
    return [self sendRequest:setup
                    progress:nil
                     success:success
                     failure:nil
                    finished:nil];
}

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup failure:(SSNetFailure)failure
{
    return [self sendRequest:setup
                    progress:nil
                     success:nil
                     failure:failure
                    finished:nil];
}

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup finished:(SSNetFinishe)finished
{
    return [self sendRequest:setup
                    progress:nil
                     success:nil
                     failure:nil
                    finished:finished];
}

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup success:(SSNetSuccess)success failure:(SSNetFailure)failure
{
    return [self sendRequest:setup
                    progress:nil
                     success:success
                     failure:failure
                    finished:nil];
}

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup
                           success:(SSNetSuccess)success
                           failure:(SSNetFailure)failure
                          finished:(SSNetFinishe)finished
{
    return [self sendRequest:setup
                    progress:nil
                     success:success
                     failure:failure
                    finished:finished];
}

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup
                          progress:(SSNetProgress)progress
                           success:(SSNetSuccess)success
                           failure:(SSNetFailure)failure;
{
    return [self sendRequest:setup
                    progress:progress
                     success:success
                     failure:failure
                    finished:nil];
}

- (nullable NSString *)sendRequest:(SSNetRequestSetup)setup
                          progress:(SSNetProgress)progress
                           success:(SSNetSuccess)success
                           failure:(SSNetFailure)failure
                          finished:(SSNetFinishe)finished
{
    __block SSHelpNetworkRequest *request = [SSHelpNetworkRequest request];
    setup(request);
    [self toBuildRequest:request progress:progress success:success failure:failure finished:finished];
    [self toSendRequest:request];
    return request.identifier;
}


- (nullable NSString *)sendBatchRequest:(SSNetBatchRequestSetup)setup
                               finished:(SSNetArrayFinished)finished
{
    __block SSHelpNetworkBatchRequest *batchRequest = [[SSHelpNetworkBatchRequest alloc] init];
    setup(batchRequest);  //内部添加一组请求
    
    if (batchRequest.requestArray.count==0) {
        return nil; //没有请求直接返回nil
    }
    batchRequest.batchFinishedBlock = finished;

    [self.lock lock];
    batchRequest.identifier = [NSString stringWithFormat:@"BC%lu", kSSHelpRequestIndex++];
    self.runningBatchAndChainPool[batchRequest.identifier] = batchRequest;
    [self.lock unlock];

    for (NSInteger index=0; index<batchRequest.requestArray.count; index++) {
        SSHelpNetworkRequest *request = batchRequest.requestArray[index];
        [self sendBatchRequest:batchRequest request:request];
    }
    
    return batchRequest.identifier;
}

- (void)sendBatchRequest:(SSHelpNetworkBatchRequest *)batchRequest request:(SSHelpNetworkRequest *)request
{
    __weak __typeof(self) __weak_self = self;
    [self toBuildRequest:request progress:nil success:nil failure:nil finished:^(id responseObject, NSError *error) {
        __strong __typeof(__weak_self) __strong_self = __weak_self;
        BOOL allFinished = [batchRequest handleFinishedRequest:request response:responseObject error:error];
        if (allFinished) {
            if (batchRequest.batchFinishedBlock) {
                batchRequest.batchFinishedBlock(batchRequest.responseArray);
            }
            [batchRequest cleanCallbackBlocks];
            
            [__strong_self.lock lock];
            [__strong_self.runningBatchAndChainPool removeObjectForKey:batchRequest.identifier];
            [__strong_self.lock unlock];
        }
    }];
    [self toSendRequest:request];
}

- (NSString *)sendChainRequest:(SSNetChainRequestSetup)setupBlock
                      finished:(SSNetArrayFinished)finishedBlock
{
    __block SSHelpNetworkChainRequest *chainRequest = [[SSHelpNetworkChainRequest alloc] init];
    setupBlock(chainRequest);
    if (chainRequest.runningRequest)
    {
        chainRequest.chainFinishedBlock = finishedBlock;
        
        [self.lock lock];
        chainRequest.identifier = [NSString stringWithFormat:@"BC%lu", kSSHelpRequestIndex++];
        self.runningBatchAndChainPool[chainRequest.identifier] = chainRequest;
        [self.lock unlock];
        
        [self sendChainRequest:chainRequest];
                
        return chainRequest.identifier ;
    }
    return nil;
}

- (void)sendChainRequest:(SSHelpNetworkChainRequest *)chainRequest
{
    __weak __typeof(self) __weak_self = self;
    SSHelpNetworkRequest *request = chainRequest.runningRequest;
    [self toBuildRequest:request progress:nil success:nil failure:nil finished:^(id responseObject, NSError *error) {
        __strong __typeof(__weak_self) __strong_self = __weak_self;
        BOOL allFinished = [chainRequest handleFinishedRequest:chainRequest.runningRequest response:responseObject error:error];
        //全部完成或者被调用者主动中断
        if (allFinished) {
            [__strong_self.lock lock];
            [__strong_self.runningBatchAndChainPool removeObjectForKey:chainRequest.identifier];
            [__strong_self.lock unlock];
        }else {
            if (chainRequest.runningRequest != nil) {
                [__strong_self sendChainRequest:chainRequest];
            }
        }
     }];
    
    [self toSendRequest:request];
}

#pragma mark - Private Methods

- (void)toBuildRequest:(SSHelpNetworkRequest *)request
              progress:(SSNetProgress)progressBlock
               success:(SSNetSuccess)successBlock
               failure:(SSNetFailure)failureBlock
              finished:(SSNetFinishe)finishedBlock
{
    // set callback blocks for the request object.
    if (successBlock) {
        request.successBlock  = successBlock;
    }
    if (failureBlock) {
        request.failureBlock  = failureBlock;
    }
    if (finishedBlock) {
        request.finishedBlock = finishedBlock;
    }
    if (progressBlock) {
        request.progressBlock = progressBlock;
    }
    
    // add general user info to the request object.
    if (!request.userInfo && self.generalUserInfo) {
        request.userInfo = self.generalUserInfo;
    }
    
    // add general parameters to the request object.
    if (request.useGeneralParameters && self.generalParameters.count > 0) {
        NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
        [parameters addEntriesFromDictionary:self.generalParameters];
        if (request.parameters.count > 0) {
            [parameters addEntriesFromDictionary:request.parameters];
        }
        request.parameters = parameters;
    }
    
    // add general headers to the request object.
    if (request.useGeneralHeaders && self.generalHeaders.count > 0) {
        NSMutableDictionary *headers = [NSMutableDictionary dictionary];
        [headers addEntriesFromDictionary:self.generalHeaders];
        if (request.headers) {
            [headers addEntriesFromDictionary:request.headers];
        }
        request.headers = headers;
    }
    
    // process url for the request object.
    if (request.url.length == 0) {
        if (request.server.length == 0 && request.useGeneralServer && self.generalServer.length > 0) {
            request.server = self.generalServer;
        }
        if (request.api.length > 0) {
            NSURL *baseURL = [NSURL URLWithString:request.server];
            // ensure terminal slash for baseURL path, so that NSURL +URLWithString:relativeToURL: works as expected.
            if ([[baseURL path] length] > 0 && ![[baseURL absoluteString] hasSuffix:@"/"]) {
                baseURL = [baseURL URLByAppendingPathComponent:@""];
            }
            request.url = [[NSURL URLWithString:request.api relativeToURL:baseURL] absoluteString];
        } else {
            request.url = request.server;
        }
    }
    
    //最后一步统一修改
    if (self.requestProcessHandler) {
        self.requestProcessHandler(request);
    }
    NSAssert(request.url.length > 0, @"The request url can't be null.");
}

- (void)toSendRequest:(SSHelpNetworkRequest *)request
{
    if (self.consoleLog){ //输出日志
        #ifdef DEBUG
        NSLog(@"\n============ [SSNET LOG] [SSHelpNetworkRequest Info] ============\nRequest URL: \b%@ \nRequest Headers: \n%@ \nRequest Parameters: \n%@ \nRequest UserInfo: \n%@ \n=================================================\n",
              request.url,
              request.headers,
              request.parameters,
              request.userInfo);
        #endif
    }
    
    /// send the request through SSHelpNetworkConfig.
    __weak typeof(self) __weak_self = self;
    [self.engine sendRequest:request completion:^(id responseObject, NSError *error) {
        __strong typeof(__weak_self) __strong_self = __weak_self;
        if (__strong_self.consoleLog) { //输出日志
            #ifdef DEBUG
            NSLog(@"\n============ [SSNET LOG] [SSHelpNetworkRequest Response] ===========\nRequest URL: \n%@ \nResponse Data: \n%@\nResponse Error: \n%@ \n=================================================\n", request.url,responseObject,error);
            #endif
        }
        
        // the completionHandler will be execured in a private concurrent dispatch queue.
        if (error) {
            [__strong_self request:request didRecivedError:error];
        } else {
            [__strong_self request:request didRecivedResponse:responseObject];
        }
    }];
}

- (void)request:(SSHelpNetworkRequest *)request didRecivedResponse:(id)responseObject
{
    NSError *processError = nil;
    id changedResponseObject = nil;
    if (_responseProcessHandler) {
        changedResponseObject = _responseProcessHandler(request,responseObject,&processError);
        if (changedResponseObject) {
            responseObject = changedResponseObject;
        }
    }
    
    if (processError) {
        [self request:request didRecivedError:processError];
    } else {
        void (^completion)(void) = ^(void){
            if (request.successBlock) {
                request.successBlock(responseObject);
            }
            if (request.finishedBlock) {
                request.finishedBlock(responseObject, nil);
            }
            [request cleanCallbackBlocks];
        };
        if (_callbackQueue) {
            dispatch_async(_callbackQueue, completion);
        } else {
            completion();
        }
    }
}

- (void)request:(SSHelpNetworkRequest *)request didRecivedError:(NSError *)error
{
    if (_errorProcessHandler) {
        _errorProcessHandler(request,&error);
    }
    if (request.retryCount>0) {
        request.retryCount--;
        ///retry current request after 1 seconds.
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self toSendRequest:request];
        });
    } else {
        void (^completion)(void) = ^(void){
            if (request.failureBlock) {
                request.failureBlock(error);
            }
            
            if (request.finishedBlock) {
                request.finishedBlock(nil, error);
            }
            [request cleanCallbackBlocks];
        };
        if (_callbackQueue) {
            dispatch_async(_callbackQueue, completion);
        }else{
            completion();
        }
    }
}

- (void)cancelRequest:(NSString *)identifier
{
    [self cancelRequest:identifier cancel:nil];
}

- (void)cancelRequest:(NSString *)identifier cancel:(SSNetCancel)cancelBlock
{
    if (!identifier) {
        if (cancelBlock) {
            cancelBlock(nil);
        }
        return;
    }
    
    if ([identifier hasPrefix:@"BC"]){
        [self.lock lock];
        id request = [self.runningBatchAndChainPool objectForKey:identifier];
        [self.runningBatchAndChainPool removeObjectForKey:identifier];
        [self.lock unlock];
        
        if ([request isKindOfClass:[SSHelpNetworkBatchRequest class]]){
            SSHelpNetworkBatchRequest *batchRequest = request;
            if (batchRequest.requestArray.count > 0) {
                for (SSHelpNetworkRequest *rq in batchRequest.requestArray) {
                    [self.engine cancel:rq.identifier completion:nil];
                }
            }
        }
        else if ([request isKindOfClass:[SSHelpNetworkChainRequest class]]){
            SSHelpNetworkChainRequest *chainRequest = request;
            if (chainRequest.runningRequest) {
                [self.engine cancel:chainRequest.runningRequest.identifier completion:nil];
            }
        }
        if (cancelBlock) {
            cancelBlock(nil);
        }
    } else {
        [self.engine cancel:identifier completion:cancelBlock];
    }
}

- (nullable id)getRequest:(NSString *)identifier;
{
    if (!identifier) {
        return nil;
    }
    
    if ([identifier hasPrefix:@"BC"]) {
        [self.lock lock];
        id request = [self.runningBatchAndChainPool objectForKey:identifier];
        [self.lock unlock];
        return request;
    } else {
        return [self.engine getRequest:identifier];
    }
}

- (BOOL)isNetworkReachable
{
    return self.engine.reachabilityStatus > AFNetworkReachabilityStatusNotReachable;
}

- (SSNetConnectionType)networkConnectionType
{
    return self.engine.reachabilityStatus;
}

@end
