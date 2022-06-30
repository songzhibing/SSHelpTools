//
//  SSHelpWebViewSharedConfigurations.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/6/7.
//  WKWebView通用配置
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSUInteger, SSHelpWebViewCookiePolicy) {
    SSHelpWebViewCookieEnableSystem    = 1 << 0,
    SSHelpWebViewCookieEnableJs        = 1 << 1,
    SSHelpWebViewCookieEnablePHP       = 1 << 2,
    SSHelpWebViewCookieSyncCookieStore = 1 << 3
};

@interface SSHelpWebViewSharedConfigurations : NSObject

+ (WKWebsiteDataStore *)sharedWebsiteDataStore;

+ (WKProcessPool *)sharedProcessPool;

+ (WKPreferences *)sharedPreferences;

+ (WKWebpagePreferences *)sharedWebpagePreferences API_AVAILABLE(ios(13.0));

@end

NS_ASSUME_NONNULL_END
