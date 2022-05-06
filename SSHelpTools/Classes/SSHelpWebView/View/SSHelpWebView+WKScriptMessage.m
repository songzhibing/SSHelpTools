//
//  SSHelpWebView+WKScriptMessage.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/2/21.
//

#import "SSHelpWebView+WKScriptMessage.h"

@interface SSHelpWebView (WKScriptMessage)<WKScriptMessageHandler>

@end

@implementation SSHelpWebView (WKScriptMessage)

#pragma mark - WKScriptMessageHandler Method

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message
{
    if (self.webViewDelegate && [self.webViewDelegate respondsToSelector:@selector(webViewDidReceiveScriptMessage:)]) {
        [self.webViewDelegate webViewDidReceiveScriptMessage:message];
    }
}

@end
