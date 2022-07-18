//
//  SSHelpNetworkRequest.m
//  SSHelpTools
//
//  Modification by 宋直兵 on 2021/9/13.
//

#import "SSHelpNetworkRequest.h"

@interface SSHelpNetworkRequest ()

@end

@implementation SSHelpNetworkRequest

+ (instancetype)request
{
    return [[[self class] alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Set default value for SSHelpNetworkRequest instance
        _requestType = SSNetRequestNormal;
        _httpMethod = SSNetHTTPMethodPOST;
        _requestSerializerType = SSNetRequestSerializerRAW;
        _responseSerializerType = SSNetResponseSerializerJSON;
        _timeoutInterval = 60.0;
        
        _useGeneralServer = YES;
        _useGeneralHeaders = YES;
        _useGeneralParameters = YES;
        
        _retryCount = 0;
    }
    return self;
}

- (void)cleanCallbackBlocks
{
    _successBlock = nil;
    _failureBlock = nil;
    _finishedBlock = nil;
    _progressBlock = nil;
}

- (NSMutableArray <SSNetUploadFormData *> *)uploadFormDatas
{
    if (!_uploadFormDatas) {
        _uploadFormDatas = [NSMutableArray array];
    }
    return _uploadFormDatas;
}

- (void)addFormDataWithName:(NSString *)name
                   fileData:(NSData *)fileData
{
    SSNetUploadFormData *formData = [SSNetUploadFormData formDataWithName:name
                                                                 fileData:fileData];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                   fileData:(NSData *)fileData
{
    SSNetUploadFormData *formData = [SSNetUploadFormData formDataWithName:name
                                                                 fileName:fileName
                                                                 mimeType:mimeType
                                                                 fileData:fileData];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name
                    fileURL:(NSURL *)fileURL
{
    SSNetUploadFormData *formData = [SSNetUploadFormData formDataWithName:name
                                                                  fileURL:fileURL];
    [self.uploadFormDatas addObject:formData];
}

- (void)addFormDataWithName:(NSString *)name
                   fileName:(NSString *)fileName
                   mimeType:(NSString *)mimeType
                    fileURL:(NSURL *)fileURL
{
    SSNetUploadFormData *formData = [SSNetUploadFormData formDataWithName:name
                                                                 fileName:fileName
                                                                 mimeType:mimeType
                                                                  fileURL:fileURL];
    [self.uploadFormDatas addObject:formData];
}

@end

#pragma mark - SSHelpNetworkBatchRequest

@interface SSHelpNetworkBatchRequest()

@property (nonatomic, strong) NSLock *lock;

@property (nonatomic, assign) NSUInteger finishedCount;

@property (nonatomic, assign) BOOL failed;

@end

@implementation SSHelpNetworkBatchRequest

- (void)dealloc
{
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _anyRequestFailed = NO;
        _finishedCount = 0;
        _lock = [[NSLock alloc] init];
        _requestArray = [NSMutableArray array];
        _responseArray = [NSMutableArray array];
    }
    return self;
}

- (void)addRequest:(SSHelpNetworkRequest *)request
{
    [_lock lock];
    [_responseArray addObject:[NSNull null]];
    [_requestArray addObject:request];
    [_lock unlock];
}

- (BOOL)handleFinishedRequest:(SSHelpNetworkRequest *)request response:(nullable id)responseObject error:(nullable NSError *)error
{
    BOOL isFinished = NO;
    [_lock lock];
    NSUInteger index = [_requestArray indexOfObject:request];
    if (responseObject) {
        [_responseArray replaceObjectAtIndex:index withObject:responseObject];
    } else {
        _anyRequestFailed = YES;
        if (error) {
            [_responseArray replaceObjectAtIndex:index withObject:error];
        }
    }
    _finishedCount++;
    if (_finishedCount == _requestArray.count){
        isFinished = YES;
    }
    [_lock unlock];
    return isFinished;
}

- (void)cleanCallbackBlocks
{
    _batchFinishedBlock = nil;
}

@end

#pragma mark - SSHelpNetworkChainRequest

@interface SSHelpNetworkChainRequest ()

@property (nonatomic, assign) NSInteger chainIndex;

@property (nonatomic, strong) NSMutableArray <SSNetNextBlock> *nextBlockArray;

@property (nonatomic, strong) NSMutableArray *responseArray;

@end

@implementation SSHelpNetworkChainRequest : NSObject

- (void)dealloc
{
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chainIndex = 0;
        _responseArray = [NSMutableArray array];
        _nextBlockArray = [NSMutableArray array];
    }
    return self;
}

- (SSHelpNetworkChainRequest *)setupFirst:(SSNetRequestSetup)firstBlock
{
    _runningRequest = [SSHelpNetworkRequest request];
    firstBlock(_runningRequest);
    [_responseArray addObject:[NSNull null]];
    return self;
}

- (SSHelpNetworkChainRequest *)toNext:(SSNetNextBlock)nextBlock
{
    [_nextBlockArray addObject:nextBlock];
    [_responseArray addObject:[NSNull null]];
    return self;
}

- (BOOL)handleFinishedRequest:(SSHelpNetworkRequest *)request response:(nullable id)responseObject error:(NSError * _Nullable)error
{
    BOOL isFinished = NO;
    if (responseObject) {
        [_responseArray replaceObjectAtIndex:_chainIndex withObject:responseObject];
        if (_chainIndex < _nextBlockArray.count) {
            _runningRequest = [SSHelpNetworkRequest request];
            SSNetNextBlock nextBlock = _nextBlockArray[_chainIndex];
            __block BOOL sendNext = YES;
            nextBlock(_runningRequest, responseObject, &sendNext);
            
            //是否被调用者主动中断
            if (!sendNext) {
                if (_chainFinishedBlock) {
                    _chainFinishedBlock(_responseArray);
                }
                [self cleanCallbackBlocks];
                isFinished = YES;
            }
        } else {
            if (_chainFinishedBlock) {
                _chainFinishedBlock(_responseArray);
            }
            [self cleanCallbackBlocks];
            isFinished = YES;
        }
    } else {
        if (error) {
            [_responseArray replaceObjectAtIndex:_chainIndex withObject:error];
        }
        if (_chainFinishedBlock) {
            _chainFinishedBlock(_responseArray);
        }
        [self cleanCallbackBlocks];
        isFinished = YES;
    }
    _chainIndex++;
    return isFinished;
}

- (void)cleanCallbackBlocks
{
    _runningRequest = nil;
    _chainFinishedBlock = nil;
    [_nextBlockArray removeAllObjects];
}

@end

#pragma mark - SSNetUploadFormData

@implementation SSNetUploadFormData

- (void)dealloc
{
}

+ (instancetype)formDataWithName:(NSString *)name
                        fileData:(NSData *)fileData
{
    SSNetUploadFormData *formData = [[SSNetUploadFormData alloc] init];
    formData.name = name;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                        fileData:(NSData *)fileData
{
    SSNetUploadFormData *formData = [[SSNetUploadFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileData = fileData;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name
                         fileURL:(NSURL *)fileURL
{
    SSNetUploadFormData *formData = [[SSNetUploadFormData alloc] init];
    formData.name = name;
    formData.fileURL = fileURL;
    return formData;
}

+ (instancetype)formDataWithName:(NSString *)name
                        fileName:(NSString *)fileName
                        mimeType:(NSString *)mimeType
                         fileURL:(NSURL *)fileURL
{
    SSNetUploadFormData *formData = [[SSNetUploadFormData alloc] init];
    formData.name = name;
    formData.fileName = fileName;
    formData.mimeType = mimeType;
    formData.fileURL = fileURL;
    return formData;
}

@end
