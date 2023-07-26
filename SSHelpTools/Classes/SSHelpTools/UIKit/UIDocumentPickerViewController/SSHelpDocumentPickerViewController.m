//
//  SSHelpDocumentPickerViewController.m
//  Pods
//
//  Created by 宋直兵 on 2023/7/20.
//

#import "SSHelpDocumentPickerViewController.h"
//#import <MobileCoreServices/UTType.h>
//#import <MobileCoreServices/MobileCoreServices.h>
//#import <CoreServices/CoreServices.h>

@interface SSHelpDocumentPickerViewController ()<UIDocumentPickerDelegate>

/* Configure the behavior of adjustedContentInset.
 Default is UIScrollViewContentInsetAdjustmentAutomatic.
 */
@property(nonatomic) UIScrollViewContentInsetAdjustmentBehavior contentInsetAdjustmentBehavior API_AVAILABLE(ios(11.0),tvos(11.0));

@end

@implementation SSHelpDocumentPickerViewController

+ (instancetype)ss_new
{
    /*
        public.data：任何类型的数据文件，例如 JSON、XML、HTML 等。
        public.image：图像文件，例如 JPEG、PNG、GIF 等。
        public.audio：音频文件，例如 MP3、WAV、AIFF 等。
        public.video：视频文件，例如 MP4、AVI、MOV 等。
        public.pdf：PDF 文件。
        com.apple.truetype-font：TrueType 字体文件。
        public.font：字体文件，可以是 TrueType 字体或 OpenType 字体。
        public.item：项目文件，例如 Keynote、Pages、Numbers 等。
        public.presentation：演示文稿文件，例如 Keynote、PowerPoint 等。
        public.spreadsheet：电子表格文件，例如 Pages、Numbers 等。


        UIDocumentPickerModeImport：导入模式，允许用户选择要导入的文档文件，并将其复制到应用程序的沙箱中。
        UIDocumentPickerModeExport：导出模式，允许用户选择要导出的文档文件，并将其从应用程序的沙箱中复制到其他位置。
        UIDocumentPickerModeMoveToTrash：移动到垃圾箱模式，允许用户选择要删除的文档文件，并将其移动到系统的垃圾箱中。
    */
    
    /*
        官方参考地址
        https://developer.apple.com/library/archive/documentation/Miscellaneous/Reference/UTIRef/Articles/System-DeclaredUniformTypeIdentifiers.html#//apple_ref/doc/uid/TP40009259
    */
    NSArray *types = @[
        @"public.data",
        @"public.image",
        @"public.audio",
        @"public.video",
        @"public.pdf",
        @"com.apple.truetype-font",
        @"public.font",
        @"public.item",
        @"public.presentation",
        @"public.spreadsheet"
    ];
    SSHelpDocumentPickerViewController *vc = [[[self class] alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
    vc.delegate = vc;
    return  vc;
    /*
    if (@available(iOS 14.0, *)) {
        NSArray *contentTypes = @[(NSString *)kUTTypeText, (NSString *)kUTTypePNG];
        UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initForOpeningContentTypes:contentTypes asCopy:YES];

        return documentPicker;
    } else {
        SSHelpDocumentPickerViewController *vc = [[SSHelpDocumentPickerViewController alloc] initWithDocumentTypes:types inMode:UIDocumentPickerModeImport];
        vc.delegate = vc;
        return  vc;
    }
    */
}

- (void)dealloc
{
    _callback = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //调试发现，如果UICollectionView布局不设置成自动调整内边距，是UIScrollViewContentInsetAdjustmentNever时，会存在顶部重叠问题
    self.contentInsetAdjustmentBehavior = UICollectionView.appearance.contentInsetAdjustmentBehavior;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UICollectionView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentAutomatic];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UICollectionView appearance] setContentInsetAdjustmentBehavior:self.contentInsetAdjustmentBehavior];
}

#pragma mark -
#pragma mark - UIDocumentPickerDelegate Method

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentsAtURLs:(NSArray <NSURL *>*)urls API_AVAILABLE(ios(11.0))
{
    @Tweakify(self);
    NSMutableArray *response = NSMutableArray.array;
    [urls enumerateObjectsUsingBlock:^(NSURL * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj startAccessingSecurityScopedResource]) {
            //通过文件协调工具来得到新的文件地址，以此得到文件保护功能
            NSError *error;
            NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
            [fileCoordinator coordinateReadingItemAtURL:obj options:NSFileCoordinatorReadingWithoutChanges error:&error byAccessor:^(NSURL *newURL) {
                if (newURL) {
                    [response addObject:newURL];
                }
            }];
            if (error) {
            }
            [obj stopAccessingSecurityScopedResource];
        } else {
            //提权失败，尝试直接复制文件到沙盒缓存目录里进行操作
            NSString *toPath = [_kTempPath stringByAppendingPathComponent:obj.lastPathComponent];
            NSURL *toURL = [NSURL fileURLWithPath:toPath];
            if ([NSFileManager.defaultManager fileExistsAtPath:toPath]) {
                [NSFileManager.defaultManager removeItemAtPath:toPath error:nil];
            }
            NSError *error = nil;
            BOOL success = [NSFileManager.defaultManager copyItemAtURL:obj toURL:toURL error:&error];
            if (error) {
                SSLog(@"拷贝文件失败：%@",error);
            }
            if (success) {
                [response addObject:toURL];
            }
        }
    }];
    
    [self dismissViewControllerAnimated:YES completion:^{
        @Tstrongify(self);
        if (self.callback) {
            self.callback(response);
        }
    }];
}

// called if the user dismisses the document picker without selecting a document (using the Cancel button)
- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    @Tweakify(self);
    [self dismissViewControllerAnimated:YES completion:^{
        @Tstrongify(self);
        if (self.callback) {
            self.callback(nil);
        }
    }];
}

@end


