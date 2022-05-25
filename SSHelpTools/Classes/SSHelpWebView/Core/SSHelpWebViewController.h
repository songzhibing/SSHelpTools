//
//  SSHelpWebViewController.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#if __has_include(<SSHelpTools/SSHelpTools.h>)
#import <SSHelpTools/SSHelpTools.h>
#else
#import "SSHelpTools.h"
#endif

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpWebViewController : SSHelpViewController

/// 加载地址 （与下二选一）
@property(nonatomic, copy) NSString *indexString;

/// 加载地址请求 （与上二选一）
@property(nonatomic, strong) NSMutableURLRequest *indexRequest;

@end

NS_ASSUME_NONNULL_END
