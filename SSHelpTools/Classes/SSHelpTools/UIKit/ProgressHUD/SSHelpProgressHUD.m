//
//  SSHelpProgressHUD.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/13.
//

#import "SSHelpProgressHUD.h"
#import "SSHelpDefines.h"
#import "NSBundle+SSHelp.h"

#define kApplicationWindow [UIApplication sharedApplication].delegate.window

@interface SSProgressHUD()

@end

@implementation SSProgressHUD

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

@end



@interface SSHelpProgressHUD()
+ (instancetype)sharedInstance;
@property(nonatomic, assign) NSInteger hudRetainCount;
@property(nonatomic, strong) NSTimer *delayShowTimer;
@property(nonatomic, strong) NSTimer *delayDismissTimer;
@property(nonatomic, strong) NSLock *lock;
@property(nonatomic, assign) BOOL alreadyShow;
@property(nonatomic, strong) SSProgressHUD *sharedHUD;
@end

@implementation SSHelpProgressHUD

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wnonnull"

+ (void)showMessage:(NSString *)message
{
    [self showMessage:message toView:kApplicationWindow];
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:kApplicationWindow];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:kApplicationWindow];
}

+ (void)showWarning:(NSString *)Warning
{
    [self showWarning:Warning toView:kApplicationWindow];
}

+ (void)showMessageWithImage:(UIImage *_Nullable)image message:(NSString *)message;
{
    [self showMessageWithImage:image message:message toView:kApplicationWindow];
}


+ (void)showMessage:(NSString *)message toView:(UIView *)view
{
    [self showMessageWithImage:nil message:message toView:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    UIImage *image = [NSBundle ss_toolsBundleImage:@"SS_ProgressHUD_Success28x28"];
    if (@available(iOS 13.0, *)) {
        image = [image imageWithTintColor:UIColor.labelColor renderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [self showMessageWithImage:image message:success toView:view];
}

+ (void)showError:(NSString *)error toView:(UIView *)view
{
    UIImage *image = [NSBundle ss_toolsBundleImage:@"SS_ProgressHUD_Error28x28"];
    if (@available(iOS 13.0, *)) {
        image = [image imageWithTintColor:UIColor.labelColor renderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [self showMessageWithImage:image message:error toView:view];
}

+ (void)showWarning:(NSString *)warning toView:(UIView *)view
{
    UIImage *image = [NSBundle ss_toolsBundleImage:@"SS_ProgressHUD_Info28x28"];
    if (@available(iOS 13.0, *)) {
        image = [image imageWithTintColor:UIColor.labelColor renderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [self showMessageWithImage:image message:warning toView:view];
}

+ (void)showMessageWithImage:(UIImage *_Nullable)image message:(NSString *)message toView:(UIView *)view
{
    [self showMessage:message image:image toView:view duration:1.5];
}

+ (void)showMessage:(NSString *)message image:(UIImage *_Nullable)image toView:(UIView *)view duration:(NSTimeInterval)duration
{
    if (!view || !message) {
        return;
    }
    
    SSProgressHUD *hud = [SSProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = message;
    // 判断是否显示图片
    if (image) {
        //设置图片
        hud.customView = [[UIImageView alloc] initWithImage:image];
        // 再设置模式
        hud.mode = MBProgressHUDModeCustomView;
    } else {
        hud.mode = MBProgressHUDModeText;
    }
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // 指定时间之后再消失
    [hud hideAnimated:YES afterDelay:duration];
}

+ (MBProgressHUD *_Nullable)showActivityMessage:(NSString*)message
{
    return [self showActivityMessage:message toView:kApplicationWindow];
}

+ (SSProgressHUD *_Nullable)showActivityMessage:(NSString*)message toView:(UIView *)view
{
    if (!view || !message) {
        return nil;
    }
    
    // 快速显示一个提示信息
    SSProgressHUD *hud = [SSProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text  = message;
    // 细节文字
    //hud.detailsLabelText = @"请耐心等待";
    // 再设置模式
    hud.mode = MBProgressHUDModeIndeterminate;

    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;

    return hud;
}

+ (SSProgressHUD *_Nullable)showProgressBar
{
    return [self showProgressBarToView:kApplicationWindow];
}

+ (SSProgressHUD *_Nullable)showProgressBarToView:(UIView *)view
{
    if (!view) {
        return nil;
    }
    
    SSProgressHUD *hud = [SSProgressHUD showHUDAddedTo:view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.label.text  = @"加载中...";
    return hud;
}

+ (void)hideHUD
{
    [self hideHUDForView:kApplicationWindow];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view) {
        [MBProgressHUD hideHUDForView:view animated:YES];
    }
}

+ (void)ss_show
{
    [[SSHelpProgressHUD sharedInstance] _show];
}

+ (void)ss_dismiss
{
    [[SSHelpProgressHUD sharedInstance]  _dismiss];
}

+ (instancetype)sharedInstance
{
    static SSHelpProgressHUD *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SSHelpProgressHUD alloc] init];
    });
    return instance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.alreadyShow = NO;
        self.hudRetainCount = 0;
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"SSHelpProgressHUD.timer.lock";
    }
    return self;
}

- (void)_show
{
    [self.lock lock];
    self.hudRetainCount += 1;
    [self _handler];
    [self.lock unlock];
}

- (void)_dismiss
{
    [self.lock lock];
    if (self.hudRetainCount>0) {
        self.hudRetainCount -= 1;
        [self _handler];
    }
    [self.lock unlock];
}

- (void)_handler
{
    @Tweakify(self);
    if (self.hudRetainCount==0) {
        if (_delayShowTimer && [_delayShowTimer isValid]) {
            [_delayShowTimer invalidate];
            _delayShowTimer = nil;
        } else {
            if (!_alreadyShow) {
                return;
            }
            _delayDismissTimer = nil;
            _delayDismissTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f repeats:NO block:^(NSTimer * _Nonnull timer) {
                self_weak_.alreadyShow = NO;
                if (self_weak_.sharedHUD) {
                    [self_weak_.sharedHUD hideAnimated:YES];
                    self_weak_.sharedHUD = nil;
                }
            }];
        }
    } else if (self.hudRetainCount==1){
        if (_delayDismissTimer && [_delayDismissTimer isValid]) {
            [_delayDismissTimer invalidate];
            _delayDismissTimer = nil;
        } else {
            if (_alreadyShow) {
                return;
            }
            _delayShowTimer = nil;
            _delayShowTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f repeats:NO block:^(NSTimer * _Nonnull timer) {
                self_weak_.alreadyShow = YES;
                self_weak_.sharedHUD = [SSHelpProgressHUD showActivityMessage:@""];
            }];
        }
    }
}

//#pragma clang diagnostic pop

@end
