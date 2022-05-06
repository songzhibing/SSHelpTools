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

@property(nonatomic, strong) NSMutableURLRequest *indexRequest;

@end

NS_ASSUME_NONNULL_END
