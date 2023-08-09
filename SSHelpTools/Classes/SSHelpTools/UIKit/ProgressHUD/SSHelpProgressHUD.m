//
//  SSHelpProgressHUD.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/13.
//

#import <Masonry/Masonry.h>
#import "SSHelpProgressHUD.h"
#import "SSHelpDefines.h"
#import "NSBundle+SSHelp.h"
#import "SSHelpButton.h"
#import "UIView+SSHelp.h"
#import "UIImage+SSHelp.h"

#define __kApplicationWindow [UIApplication sharedApplication].delegate.window

@protocol SSProgressHUDDelegate <NSObject>

- (void)progress:(SSProgressHUD *)hud clickCancelButton:(id)sender;

@end


@interface SSProgressHUD()

@property(nonatomic, weak) id <SSProgressHUDDelegate> hudDelegate;

@property(nonatomic, strong) SSHelpButton *cancelBtn;

@property (nonatomic, assign) BOOL useAnimation;

@end


@implementation SSProgressHUD

- (void)dealloc
{
    SSLifeCycleLog(@"%@ dealloc ... ",self);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        switch (SSHelpProgressHUD.sharedInstance.style) {
            case SSProgressHUDBackgroundStyleBlack:
            {
                self.bezelView.color = UIColor.blackColor;
                self.contentColor = UIColor.whiteColor;
                self.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
            }
                break;
            case SSProgressHUDBackgroundStyleLight:
            {
                self.bezelView.color = UIColor.whiteColor;
                self.contentColor = UIColor.blackColor;
                self.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
            }
                break;
            default:
                break;
        }
    }
    return self;
}

- (void)hideAnimated:(BOOL)animated
{
    if (self.cancelBtn) {
        [self.cancelBtn removeFromSuperview];
        self.cancelBtn = nil;
    }
    [super hideAnimated:animated];
}

- (void)addCancelButton
{
    if (SSHelpProgressHUD.sharedInstance.showCancelButton) {
        
        CGRect frame = CGRectMake((self.ss_width-60)/2.0f, self.ss_height-30-88, 60, 30);
        self.cancelBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
        self.cancelBtn.frame = frame;
        self.cancelBtn.textAlignment = NSTextAlignmentCenter;
        self.cancelBtn.normalTitle = @"取消";
        self.cancelBtn.normalTitleColor = self.contentColor;
        self.cancelBtn.textFont = [UIFont boldSystemFontOfSize:14.0];//MBDefaultLabelFontSize
        self.cancelBtn.ss_cornerRadius = 6;
        self.cancelBtn.layer.borderWidth = 0.5f;
        self.cancelBtn.layer.borderColor = self.contentColor.CGColor;
        [self addSubview:self.cancelBtn];
        
        // 设置
        [self.cancelBtn addTarget:self action:@selector(onClickCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        switch (SSHelpProgressHUD.sharedInstance.style) {
            case SSProgressHUDBackgroundStyleDefault:
                self.cancelBtn.normalBackImage = [UIImage ss_imageWithcolor:UIColor.systemBackgroundColor];
                break;
            default:
                self.cancelBtn.normalBackImage = [UIImage ss_imageWithcolor:self.bezelView.color];
                break;
        }
        
        // 动画
        self.cancelBtn.alpha = 0;
        if (self.useAnimation) {
            [UIView animateWithDuration:0.3 delay:0. usingSpringWithDamping:1.f initialSpringVelocity:0.f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.cancelBtn.alpha = 1;
            } completion:nil];
        } else {
            self.cancelBtn.alpha = 1;
        }
    }
}

- (void)onClickCancelButton:(SSHelpButton *)button
{
    if (_hudDelegate && [_hudDelegate respondsToSelector:@selector(progress:clickCancelButton:)]) {
        [_hudDelegate progress:self clickCancelButton:button];
    } else {
        [self hideAnimated:YES];
    }
}

@end



@interface SSHelpProgressHUD () <SSProgressHUDDelegate>
@property(nonatomic, assign) NSInteger hudRetainCount;
@property(nonatomic, strong) NSTimer *delayShowTimer;
@property(nonatomic, strong) NSLock *lock;
@property(nonatomic, strong) SSProgressHUD *sharedHUD;
@end


@implementation SSHelpProgressHUD

//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wnonnull"

+ (void)showMessage:(NSString *)message
{
    [self showMessage:message toView:__kApplicationWindow];
}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:__kApplicationWindow];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:__kApplicationWindow];
}

+ (void)showWarning:(NSString *)Warning
{
    [self showWarning:Warning toView:__kApplicationWindow];
}

+ (void)showMessageWithImage:(UIImage *_Nullable)image message:(NSString *)message;
{
    [self showMessageWithImage:image message:message toView:__kApplicationWindow];
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
    return [self showActivityMessage:message toView:__kApplicationWindow];
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

    // 添加一个取消按钮
    [hud addCancelButton];
    
    return hud;
}

+ (SSProgressHUD *_Nullable)showProgressBar
{
    return [self showProgressBarToView:__kApplicationWindow];
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
    [self hideHUDForView:__kApplicationWindow];
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
        self.style = SSProgressHUDBackgroundStyleDefault;
        self.showCancelButton = YES;
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
        if (self.delayShowTimer && [self.delayShowTimer isValid]) {
            [self.delayShowTimer invalidate];
        }
        self.delayShowTimer = nil;
        if (self.sharedHUD) {
            [self.sharedHUD hideAnimated:YES];
        }
        self.sharedHUD = nil;
    } else if (self.hudRetainCount>=1){
        if (!self.delayShowTimer && !self.sharedHUD) {
            self.delayShowTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f repeats:NO block:^(NSTimer * _Nonnull timer) {
                self_weak_.sharedHUD = [SSHelpProgressHUD showActivityMessage:@""];
                self_weak_.sharedHUD.hudDelegate = self_weak_;
                self_weak_.delayShowTimer = nil;
            }];
        }
    }
}

#pragma mark -
#pragma mark - SSProgressHUDDelegate Method

- (void)progress:(SSProgressHUD *)hud clickCancelButton:(id)sender
{
    [self.lock lock];
    self.hudRetainCount = 0;
    [self _handler];
    [self.lock unlock];
}

//#pragma clang diagnostic pop

@end
