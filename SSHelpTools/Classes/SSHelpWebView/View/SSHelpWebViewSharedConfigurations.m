//
//  SSHelpWebViewSharedConfigurations.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/6/7.
//

#import "SSHelpWebViewSharedConfigurations.h"

@implementation SSHelpWebViewSharedConfigurations

/**
 与WebView关联的WKWebsiteDataStore对象
 网站的各种类型的数据，数据类型包括:cookies, disk and memory caches, and persistent data such as WebSQL, IndexedDB databases, and local storage。
 如果一个WebView关联了一个非持久化的WKWebsiteDataStore，将不会有数据被写入到文件系统
 该特性可以用来实现隐私浏览。
 */
+ (WKWebsiteDataStore *)sharedWebsiteDataStore
{
    static WKWebsiteDataStore *websiteDataStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        websiteDataStore = [WKWebsiteDataStore defaultDataStore];
    });
    return websiteDataStore;
}

/// 清空数据
+ (void)cleanSharedWebsiteDataStore:(void (^)(void))completionHandler
{
    WKWebsiteDataStore *dataStore = [SSHelpWebViewSharedConfigurations sharedWebsiteDataStore];
    if (dataStore.isPersistent) {
        NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        [dataStore removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:completionHandler];
    } else {
        if (completionHandler) {
            completionHandler();
        }
    }
}

/**
 一个WKProcessPool对象代表Web Content的进程池。

 与WebView的进程池关联的进程池通过其configuration来配置。每个WebView都有自己的Web Content进程，最终由一个有具体实现的进程来限制;在此之后，具有相同进程池的WebView最终共享Web Content进程。

 WKProcessPool对象只是一个简单的不透明token，本身没有属性或者方法。
 */
+ (WKProcessPool *)sharedProcessPool
{
    static WKProcessPool *processPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        processPool = [[WKProcessPool alloc] init];
    });
    return processPool;
}

+ (WKPreferences *)sharedPreferences
{
    static WKPreferences *preferences;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preferences = [[WKPreferences alloc] init];
        preferences.javaScriptCanOpenWindowsAutomatically = YES; //允许使用js自动打开Window，默认不允许，js在调用window.open方法的时候，必须将改值设置为YES，才能从WKUIDelegate的代理方法中获取到.类似打开一个新的标签
    });
    return preferences;
}

+ (WKWebpagePreferences *)sharedWebpagePreferences API_AVAILABLE(ios(13.0))
{
    static WKWebpagePreferences *webpagePreferences;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        webpagePreferences = [[WKWebpagePreferences alloc] init];
        if (@available(iOS 14.0, *)) {
            webpagePreferences.allowsContentJavaScript = YES;
        }
        webpagePreferences.preferredContentMode = WKContentModeMobile;
    });
    return webpagePreferences;
}

@end
