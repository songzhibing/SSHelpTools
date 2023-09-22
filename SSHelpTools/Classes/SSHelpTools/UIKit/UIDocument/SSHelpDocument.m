//
//  SSHelpDocument.m
//  Pods
//
//  Created by 宋直兵 on 2023/8/11.
//

#import "SSHelpDocument.h"

@interface SSHelpDocumentManager ()
@property(nonatomic, strong) NSMutableDictionary <NSString *, SSHelpDocument *> *documentItems;
@property(nonatomic, strong) NSLock *lock;
- (SSHelpDocument *)documentItemForKey:(NSString *)key;
@end


@implementation SSHelpDocumentManager

+ (instancetype)shared
{
    static SSHelpDocumentManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[SSHelpDocumentManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.ubiquityContainerIdentifier = NSBundle.mainBundle.bundleIdentifier;
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"SSHelpTools.SSHelpDocumentManager.Lock";
    }
    return self;
}

- (NSMutableDictionary<NSString *,SSHelpDocument *> *)documentItems
{
    if (!_documentItems) {
        _documentItems = [NSMutableDictionary dictionaryWithCapacity:1];
    }
    return _documentItems;
}

- (NSURL *)documentsURL
{
    if (!_documentsURL) {
        NSURL *containerURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:self.ubiquityContainerIdentifier];
        if (containerURL) {
            _documentsURL = [containerURL URLByAppendingPathComponent:@"Documents"];
        }
        //SSLog(@"获取容器主目录：%@",_documentURL.path);
    }
    return _documentsURL;
}

- (SSHelpDocument *)documentItemForKey:(NSString *)key
{
    SSHelpDocument *document = nil;
    [self.lock lock];
    document = self.documentItems[key];
    [self.lock unlock];
    return document;
}

- (void)addDocumentItem:(SSHelpDocument *)document forKey:(NSString *)key
{
    [self.lock lock];
    self.documentItems[key] = document;
    [self.lock unlock];
}

- (void)removeDocumentItemForKey:(NSString *)key
{
    [self.lock lock];
    [self.documentItems removeObjectForKey:key];
    [self.lock unlock];
}

#pragma mark -
#pragma mark - Public Method

- (void)saveFileURL:(NSURL *)fileURL callback:(SSBlockCallback)callback
{
    if (fileURL) {
        if (self.documentsURL) {
            NSURL *toURL = [self.documentsURL URLByAppendingPathComponent:fileURL.lastPathComponent];
            [self saveFileURL:fileURL toURL:toURL progress:nil callback:callback];
        } else {
            if (callback) {
                callback(@(NO),[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获取到文件容器"}]);
            }
        }
    } else {
        if (callback) {
            callback(@(NO),[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"地址参数为空"}]);
        }
    }
}

- (void)saveFileURL:(NSURL *)fileURL toURL:(NSURL *)toURL progress:(SSBlockId)progress callback:(SSBlockCallback)callback
{
    @Tweakify(self);

    if (fileURL && toURL) {
        // 测试发现，UIDocument:saveToRUL 调用完成后，会删除原文件
        // 因此这里先拷贝原文件到临时目录
        
        NSString *tmpPath = [_kTempPath stringByAppendingPathComponent:fileURL.lastPathComponent];
        NSURL *tmpURL = [NSURL fileURLWithPath:tmpPath];
        
        if ([NSFileManager.defaultManager fileExistsAtPath:tmpPath]) {
            [NSFileManager.defaultManager removeItemAtPath:tmpPath error:NULL];
        }
        NSError *error;
        BOOL copy = [NSFileManager.defaultManager copyItemAtPath:fileURL.path toPath:tmpURL.path error:&error];
        if (copy) {
            NSString *key = fileURL.path;
            SSHelpDocument *document = [[SSHelpDocument alloc] initWithFileURL:tmpURL];
            [self addDocumentItem:document forKey:key];
            [document saveToURL:toURL forSaveOperation:UIDocumentSaveForOverwriting completionHandler:^(BOOL success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (callback) {
                        callback(@(success),nil);
                    }
                    [self_weak_ removeDocumentItemForKey:key];
                });
            }];
        } else {
            if (callback) {
                callback(@(NO),error?:[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"备份文件发生异常"}]);
            }
        }
    } else {
        if (callback) {
            callback(@(NO),[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"地址参数为空"}]);
        }
    }
}

- (void)readFile:(NSString *)fileName callback:(SSBlockCallback)callback
{
    if (self.documentsURL) {
        NSURL *fileURL = [self.documentsURL URLByAppendingPathComponent:fileName];
        if ([NSFileManager.defaultManager fileExistsAtPath:fileURL.path]) {
            [self readFileURL:fileURL callback:callback];
        } else {
            if (callback) {
                callback(@(NO),[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"未找到目标文件"}]);
            }
        }
    } else {
        if (callback) {
            callback(@(NO),[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"未获取到文件容器"}]);
        }
    }
}

- (void)readFileURL:(NSURL *)fileURL callback:(SSBlockCallback)callback
{
    @Tweakify(self);
    if (fileURL) {
        NSString *key = fileURL.path;
        SSHelpDocument *document = [[SSHelpDocument alloc] initWithFileURL:fileURL];
        [self addDocumentItem:document forKey:key];
        [document openWithCompletionHandler:^(BOOL success) {
            dispatch_async(dispatch_get_main_queue(), ^{
                SSHelpDocument *doc = [self_weak_ documentItemForKey:key];
                if (callback) {
                    callback(doc.response,nil);
                }
                [self_weak_ removeDocumentItemForKey:key];
            });
        }];
    } else {
        if (callback) {
            callback(@(NO),[NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"文件地址参数为空"}]);
        }
    }
}

@end


//******************************************************************************
//******************************************************************************


// /* 文档更改类型 <枚举> */
// typedef NS_ENUM(NSInteger, UIDocumentChangeKind) {
//     UIDocumentChangeDone,   /// 已经更改
//     UIDocumentChangeUndone, /// 已撤销更改
//     UIDocumentChangeRedone, /// 撤消更改已重做
//     UIDocumentChangeCleared /// 已清除未完成的更改
// } __TVOS_PROHIBITED;
//
// /* 文档保存操作类型 <枚举> */
// typedef NS_ENUM(NSInteger, UIDocumentSaveOperation) {
//     UIDocumentSaveForCreating,      /// 首次保存
//     UIDocumentSaveForOverwriting    /// 覆盖先前版本的保存
// } __TVOS_PROHIBITED;
//
// /* 文档状态 <枚举> */
// typedef NS_OPTIONS(NSUInteger, UIDocumentState) {
//     UIDocumentStateNormal            = 0,       /// 文档已打开,已启用编辑,并且没有与之关联的冲突或错误
//     UIDocumentStateClosed            = 1 << 0,  /// 读取文档时出错(文档未打开或已关闭;文档属性可能无效)
//     UIDocumentStateInConflict        = 1 << 1,  /// 文档fileURL存在冲突(可以通过NSFileVersion类的otherVersionsOfItemAtURL:方法来访问这些冲突文档的各个版本)
//     UIDocumentStateSavingError       = 1 << 2,  /// 保存或还原文档时出错
//     UIDocumentStateEditingDisabled   = 1 << 3,  /// 文档被占用,目前用户编辑不安全(UIDocument调用- disableEditing方法之前 或 一些错误阻止文档还原时 是此状态)
//     UIDocumentStateProgressAvailable = 1 << 4   /// 文档处于上传/下载状态
// } __TVOS_PROHIBITED;
//
//
//
// // 文档状态改变通知
// UIKIT_EXTERN NSNotificationName const UIDocumentStateChangedNotification NS_AVAILABLE_IOS(5_0) __TVOS_PROHIBITED;
//
//
//
//
//
// #pragma mark - 文档 Class
// #pragma mark -
// /*
//  概述
//  - 抽象类,需要子类继承实现
//  - 异步读/写队列中的数据
//  - 协调读/写云端自动集成的文档文件
//  - 支持发现文档的不同版本之间的冲突(如果有)
//  - 先将数据写入临时文件然后替换当前文档文件来安全地保存文档数据
//  - 在适当的时刻自动保存文档数据(支持处理暂停功能)
//  */
// NS_CLASS_AVAILABLE_IOS(5_0) __TVOS_PROHIBITED @interface UIDocument : NSObject <NSFilePresenter, NSProgressReporting>

@implementation SSHelpDocument

// /**
//  实例化
//
//  @param url 文件URL(不能为空)
//  @return UIDocument
//  */
// - (instancetype)initWithFileURL:(NSURL *)url NS_DESIGNATED_INITIALIZER __TVOS_PROHIBITED;

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

// // UIKit可以在子线程调用这些方法,子类需要考虑线程安全
// // 要在 打开/保存/恢复 操作完成之前访问这些属性并等待任何挂起的文件操作应在-performAsynchronousFileAccessUsingBlock:回调中设置
//
// /// 文档URL路径
// @property (readonly) NSURL *fileURL __TVOS_PROHIBITED;
// /// 文档的本地化名称(默认从URL中自动生成;子类可以覆盖设置自定义名称)
// @property (readonly, copy) NSString *localizedName __TVOS_PROHIBITED;
// /// 文档的类型(默认从URL中自动生成)
// @property (readonly, copy, nullable) NSString *fileType __TVOS_PROHIBITED;
// /// 最后一次修改文档的日期(openWithCompletionHandler: / revertToContentsOfURL: / saveToURL: 由这三个方法更新此属性,如果都没有则返回nil)
// @property (copy, nullable) NSDate *fileModificationDate __TVOS_PROHIBITED;
// /// 文档状态
// @property (readonly) UIDocumentState documentState __TVOS_PROHIBITED;
// /// 文档上传/下载进度(文档状态为UIDocumentStateProgressAvailable时有效)
// @property (readonly, nullable) NSProgress *progress NS_AVAILABLE_IOS(9_0) __TVOS_PROHIBITED;
//
// #pragma mark |文档的 打开/关闭 操作|
// // 异步打开文档(子类需要super)
// - (void)openWithCompletionHandler:(void (^ __nullable)(BOOL success))completionHandler __TVOS_PROHIBITED;
// // 异步关闭文档并保存
// - (void)closeWithCompletionHandler:(void (^ __nullable)(BOOL success))completionHandler __TVOS_PROHIBITED;

 #pragma mark |文档的简单 读/写 操作|

/// 保存文档到App的数据模型中(单一文件返回NSData类型数据;文件包返回NSFileWrapper类型数据)
- (BOOL)loadFromContents:(id)contents ofType:(nullable NSString *)typeName error:(NSError **)outError __TVOS_PROHIBITED
{
    self.response = contents;
    return true;
}

/// 返回要保存的文档数据
- (nullable id)contentsForType:(NSString *)typeName error:(NSError **)outError __TVOS_PROHIBITED
{
    if (self.fileURL) {
        NSData *data = [NSData dataWithContentsOfURL:self.fileURL];
        return data;
    }
    return nil;
}

#pragma mark |打开/禁用 编辑功能|

// // 禁用编辑
// - (void)disableEditing __TVOS_PROHIBITED;
// // 打开编辑
// - (void)enableEditing __TVOS_PROHIBITED;

#pragma mark |撤销管理器|

// // 撤销管理器
// @property (strong, null_resettable) NSUndoManager *undoManager __TVOS_PROHIBITED;
// /* 返回文档是否有任何未保存的更改 */
// #if UIKIT_DEFINE_AS_PROPERTIES
// @property(nonatomic, readonly) BOOL hasUnsavedChanges __TVOS_PROHIBITED;
// #else
// - (BOOL)hasUnsavedChanges __TVOS_PROHIBITED;
// #endif
// // 设置文档更改类型(如果设置了撤销管理器,子类不需要调用它)
// - (void)updateChangeCount:(UIDocumentChangeKind)change __TVOS_PROHIBITED;
// // 设置保存操作类型并生成CountToken
// - (id)changeCountTokenForSaveOperation:(UIDocumentSaveOperation)saveOperation __TVOS_PROHIBITED;
// // 修改指定保存操作类型的CountToken
// - (void)updateChangeCountWithToken:(id)changeCountToken forSaveOperation:(UIDocumentSaveOperation)saveOperation __TVOS_PROHIBITED;

#pragma mark |文档的高级 读/写 操作|

// // 保存文档到App的指定沙盒路径中
// - (void)saveToURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation completionHandler:(void (^ __nullable)(BOOL success))completionHandler __TVOS_PROHIBITED;
// // 自动保存文档
// - (void)autosaveWithCompletionHandler:(void (^ __nullable)(BOOL success))completionHandler __TVOS_PROHIBITED;
//
// /* 要保存文档的文件类型(子类可以修改设置新文件类型) */
// #if UIKIT_DEFINE_AS_PROPERTIES
// @property(nonatomic, readonly, nullable) NSString *savingFileType __TVOS_PROHIBITED;
// #else
// - (nullable NSString *)savingFileType __TVOS_PROHIBITED;
// #endif
//
// // 修改正在写入文档的扩展名
// - (NSString *)fileNameExtensionForType:(nullable NSString *)typeName saveOperation:(UIDocumentSaveOperation)saveOperation __TVOS_PROHIBITED;
//
// // 文档数据是否安全地写入App沙箱中的指定位置
// - (BOOL)writeContents:(id)contents andAttributes:(nullable NSDictionary *)additionalFileAttributes safelyToURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation error:(NSError **)outError __TVOS_PROHIBITED;
// // 文档数据是否安全的写入fileURL指示的沙盒位置
// - (BOOL)writeContents:(id)contents toURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation originalContentsURL:(nullable NSURL *)originalContentsURL error:(NSError **)outError __TVOS_PROHIBITED;
//
// // 保存/更新文档时返回文档属性
// - (nullable NSDictionary *)fileAttributesToWriteToURL:(NSURL *)url forSaveOperation:(UIDocumentSaveOperation)saveOperation error:(NSError **)outError __TVOS_PROHIBITED;
//
// // 读取指定位置的文档
// - (BOOL)readFromURL:(NSURL *)url error:(NSError **)outError __TVOS_PROHIBITED;
//
// #pragma mark |文件 读/写 序列化|
// - (void)performAsynchronousFileAccessUsingBlock:(void (^)(void))block __TVOS_PROHIBITED;

#pragma mark |解决 读/写 过程中的冲突和错误|

// /*
//  - 处理UIDocument中的错误的高级方法,一般无需调用
//  - 可以在文档类处于UIDocumentStateSavingError时通过UIDocumentStateChangedNotification来为用户提供正确的反馈
//  */
// // 获取文档操作期间发生的错误
// - (void)handleError:(NSError *)error userInteractionPermitted:(BOOL)userInteractionPermitted __TVOS_PROHIBITED;
// // 已经完成错误的处理
// - (void)finishedHandlingError:(NSError *)error recovered:(BOOL)recovered __TVOS_PROHIBITED;
// // 发生错误但没有得到处理
// - (void)userInteractionNoLongerPermittedForError:(NSError *)error __TVOS_PROHIBITED;
//

#pragma mark |恢复|

// // 把文档还原成最后一次储存在磁盘上的数据
// - (void)revertToContentsOfURL:(NSURL *)url completionHandler:(void (^ __nullable)(BOOL success))completionHandler __TVOS_PROHIBITED;

@end

// // 标识用户活动的文档密钥
// UIKIT_EXTERN NSString* const NSUserActivityDocumentURLKey NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
//
//
//
// #pragma mark - 文档的用户活动扩展 <分类>
// @interface UIDocument (ActivityContinuation) <UIUserActivityRestoring>
//
// /// 封装此文档支持的用户活动的对象
// @property (nonatomic, strong, nullable) NSUserActivity *userActivity NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
//
// // 更新用户活动对象的状态
// - (void)updateUserActivityState:(NSUserActivity *)userActivity NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
// // 恢复用户活动对象所需的状态
// - (void)restoreUserActivityState:(NSUserActivity *)userActivity NS_AVAILABLE_IOS(8_0) __TVOS_PROHIBITED;
//
// @end


