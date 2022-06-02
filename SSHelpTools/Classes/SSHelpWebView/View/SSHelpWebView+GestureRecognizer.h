//
//  SSHelpWebView+GestureRecognizer.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/31.
//

#import "SSHelpWebView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpWebView (GestureRecognizer)

- (void)addLongPressGestureRecognizer:(WKWebView *)webview;

@end

NS_ASSUME_NONNULL_END
