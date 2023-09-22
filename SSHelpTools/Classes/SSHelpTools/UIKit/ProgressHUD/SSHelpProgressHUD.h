//
//  SSHelpProgressHUD.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/13.
//
//  对MBProgressHUD库进行二次优化封装
//

#import <Foundation/Foundation.h>
#import <MBProgressHUD/MBProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_OPTIONS(NSInteger, SSProgressHUDBackgroundStyle ) {
    SSProgressHUDBackgroundStyleDefault = 0, //默认
    SSProgressHUDBackgroundStyleBlack,       //深色
    SSProgressHUDBackgroundStyleLight,       //浅色
};


@interface SSProgressHUD : MBProgressHUD
@end


@interface SSHelpProgressHUD : NSObject

+ (instancetype)sharedInstance;

/// 设置视图背景风格
@property(nonatomic, assign) SSProgressHUDBackgroundStyle style;

/// 是否添加一个'取消'按钮，可强制销毁视图
@property(nonatomic, assign) BOOL showCancelButton;

#pragma mark 推荐，针对短时间内多次调用进行优化。

+ (void)ss_show;
+ (void)ss_dismiss;

#pragma mark 在指定的view上显示hud

+ (void)showMessage:(NSString *)message toView:(UIView *)view;
+ (void)showSuccess:(NSString *)success toView:(UIView *)view;
+ (void)showError:(NSString *)error toView:(UIView *)view;
+ (void)showWarning:(NSString *)Warning toView:(UIView *)view;
+ (void)showMessageWithImage:(UIImage *_Nullable)image message:(NSString *)message toView:(UIView *)view;
+ (void)showMessage:(NSString *)message image:(UIImage *_Nullable)image toView:(UIView *)view duration:(NSTimeInterval)duration;

+ (SSProgressHUD *_Nullable)showActivityMessage:(NSString *)message toView:(UIView *)view;
+ (SSProgressHUD *_Nullable)showProgressBarToView:(UIView *)view;

#pragma mark 在[UIApplication sharedApplication].delegate.window上显示hud

+ (void)showMessage:(NSString *)message;
+ (void)showSuccess:(NSString *)success;
+ (void)showError:(NSString *)error;
+ (void)showWarning:(NSString *)warning;
+ (void)showMessageWithImage:(UIImage *_Nullable)image message:(NSString *)message;
+ (SSProgressHUD *_Nullable)showActivityMessage:(NSString *)message;
+ (SSProgressHUD *_Nullable)showProgressBar;

#pragma mark 移除hud

+ (void)hideHUDForView:(UIView *)view;
+ (void)hideHUD;

@end

NS_ASSUME_NONNULL_END


