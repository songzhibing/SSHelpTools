//
//  SSHelpWebBaseModule.m
//  SSHelpWebView
//
//  Created by 宋直兵 on 2022/1/10.
//

#import "SSHelpWebBaseModule.h"

@implementation SSHelpWebBaseModule

- (void)dealloc
{
    _bridge = nil;
    _webView = nil;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSString *className = NSStringFromClass([self class]);
        _identifier = className;
    }
    return self;
}

- (void)basePushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    dispatch_main_async_safe(^{
        if (self.webView.ss_viewController && self.webView.ss_viewController.navigationController) {
            [self.webView.ss_viewController.navigationController pushViewController:viewController animated:animated];
        }
    });
}

- (void)basePresentViewController:(UIViewController *)viewControllerToPresent animated: (BOOL)flag completion:(void (^ __nullable)(void))completion
{
    dispatch_main_async_safe(^{
        if (self.webView.ss_viewController) {
            [self.webView.ss_viewController presentViewController:viewControllerToPresent animated:flag completion:completion];
        }
    });
}

@end
