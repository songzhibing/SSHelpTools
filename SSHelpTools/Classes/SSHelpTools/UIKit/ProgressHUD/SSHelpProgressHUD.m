//
//  SSHelpProgressHUD.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/13.
//

#import "SSHelpProgressHUD.h"

@interface SSHelpProgressHUD()
+ (instancetype)sharedInstance;
@property(nonatomic, assign) NSInteger hudRetainCount;
@property(nonatomic, strong) NSTimer *delayShowTimer;
@property(nonatomic, strong) NSTimer *delayDismissTimer;
@property(nonatomic, strong) NSLock *lock;
@end

@implementation SSHelpProgressHUD

#pragma mark -
#pragma mark - Public Class Method

+ (void)ss_show
{
    [[SSHelpProgressHUD sharedInstance] _show];
}


+ (void)ss_dismiss
{
    [[SSHelpProgressHUD sharedInstance]  _dismiss];
}

//******************************************************************************

// 显示一直旋转的进度条
+ (void)show
{
    [SSHelpProgressHUD sharedInstance];
    [SVProgressHUD show];
}

+ (void)showWithStatus:(nullable NSString*)status
{
    [SSHelpProgressHUD sharedInstance];
    [SVProgressHUD showWithStatus:status];
}


// 显示进度条，progress为 0~1
+ (void)showProgress:(float)progress
{
    [SSHelpProgressHUD sharedInstance];
    [SVProgressHUD showProgress:progress];
}

// 显示进度条和状态
+ (void)showProgress:(float)progress status:(nullable NSString*)status
{
    [SSHelpProgressHUD sharedInstance];
    [SVProgressHUD setMinimumSize:CGSizeMake(200, 100)];
    [SVProgressHUD showProgress:progress status:status];
}


+ (void)dismiss
{
    [SVProgressHUD dismiss];
}

+ (void)dismissWithCompletion:(void (^_Nullable)(void))completion
{
    [SVProgressHUD dismissWithCompletion:completion];
}


+ (void)showToast:(NSString*)message
{
    [SSHelpProgressHUD showToast:message duration:1 completion:nil];
}

+ (void)showToast:(NSString*)message duration:(NSTimeInterval)duration completion:(void(^ _Nullable)(void))completion
{
    [SVProgressHUD dismiss];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setImageViewSize:CGSizeMake(0, -1)];
    [SVProgressHUD showImage:[UIImage new] status:message];
    [SVProgressHUD dismissWithDelay:duration completion:^{
        SSHelpProgressHUD *instance = [SSHelpProgressHUD sharedInstance];
        [SVProgressHUD setDefaultStyle:instance.progressHUDStyle];
        [SVProgressHUD setImageViewSize:CGSizeMake(28, 28)];
        [SVProgressHUD setDefaultMaskType:instance.progressHUDMaskType];
        if (completion) completion();
    }];
}

#pragma mark -
#pragma mark - Private Method

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
        self.lock = [[NSLock alloc] init];
        self.lock.name = @"SSHelpProgressHUD.timer.lock";
        self.progressHUDStyle = SVProgressHUDStyleLight;
        self.progressHUDMaskType = SVProgressHUDMaskTypeBlack;
        [SVProgressHUD setDefaultStyle:self.progressHUDStyle];
        [SVProgressHUD setDefaultMaskType:self.progressHUDMaskType];
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
    if (self.hudRetainCount==0) {
        if (_delayShowTimer && [_delayShowTimer isValid]) {
            [_delayShowTimer invalidate];
            _delayShowTimer = nil;
        } else {
            _delayDismissTimer = nil;
            _delayDismissTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f repeats:NO block:^(NSTimer * _Nonnull timer) {
                [SVProgressHUD dismiss];
            }];
        }
    } else if (self.hudRetainCount==1){
        if (_delayDismissTimer && [_delayDismissTimer isValid]) {
            [_delayDismissTimer invalidate];
            _delayDismissTimer = nil;
        } else {
            _delayShowTimer = [NSTimer scheduledTimerWithTimeInterval:0.25f repeats:NO block:^(NSTimer * _Nonnull timer) {
                [SVProgressHUD show];
            }];
        }
    }
}

@end
