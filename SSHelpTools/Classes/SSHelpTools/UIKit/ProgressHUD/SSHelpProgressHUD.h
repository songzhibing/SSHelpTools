//
//  SSHelpProgressHUD.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/13.
//
//  对SVProgressHUD库进行二次优化封装
//

#import <Foundation/Foundation.h>
#import <SVProgressHUD/SVProgressHUD.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpProgressHUD : NSObject

@property(nonatomic, assign) SVProgressHUDStyle progressHUDStyle;

@property(nonatomic, assign) SVProgressHUDMaskType progressHUDMaskType;

+ (void)ss_show;

+ (void)ss_dismiss;


+ (void)show;

+ (void)showWithStatus:(nullable NSString*)status;


+ (void)showProgress:(float)progress;

+ (void)showProgress:(float)progress status:(nullable NSString*)status;


+ (void)dismiss;

+ (void)dismissWithCompletion:(void (^_Nullable)(void))completion;


+ (void)showToast:(NSString*)message;

+ (void)showToast:(NSString*)message duration:(NSTimeInterval)duration completion:(void (^_Nullable)(void))completion;


@end

NS_ASSUME_NONNULL_END
