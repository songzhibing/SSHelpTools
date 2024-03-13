//
//  SSHelpWebViewController.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import <SSHelpTools/SSHelpViewController.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpWebViewController : SSHelpViewController

/// 加载方式：字符串地址加载
@property(nonatomic, copy) NSString *indexString;

/// 加载方式：URL加载
@property(nonatomic, strong) NSMutableURLRequest *indexRequest;

/// 加载方式：file文件URL加载
///
/// @fileURL URL The file URL to which to navigate.
/// @readAccessURL The URL to allow read access to.  @discussion If readAccessURL references a single file, only that file may be loaded by WebKit.If readAccessURL references a directory, files inside that file may be loaded by WebKit.
@property(nonatomic, strong) NSURL *fileURL;
@property(nonatomic, strong) NSURL *readAccessURL;

@end

NS_ASSUME_NONNULL_END
