//
//  SSTestDocViewController.m
//  SSHelpTools_Example
//
//  Created by 宋直兵 on 2023/7/20.
//  Copyright © 2023 宋直兵. All rights reserved.
//

#import "SSTestDocViewController.h"
#import <SSHelpTools/SSHelpDocumentPickerViewController.h>

@interface SSTestDocViewController ()

@end

@implementation SSTestDocViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    @Tweakify(self);
    
    SSHelpButton *btn = SSHelpButton.new;
    btn.normalTitle = @"附件";
    btn.ss_cornerRadius = 3;
    btn.layer.borderColor = UIColor.labelColor.CGColor;
    btn.normalTitleColor = UIColor.labelColor;
    [self.containerView addSubview:btn];
    [btn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(20);
    }];
    
    [btn setOnClick:^(SSHelpButton * _Nonnull sender) {
        SSHelpDocumentPickerViewController *vc = SSHelpDocumentPickerViewController.ss_new;
        vc.callback = ^(__kindof NSArray * _Nullable array) {
            if (array.firstObject) {
                SSHelpQLPreviewController *preVC = SSHelpQLPreviewController.ss_new;
                preVC.fileURL = array.firstObject;
                [self_weak_ presentViewController:preVC animated:YES completion:nil];
            }
        };
        [self_weak_ presentViewController:vc animated:YES completion:nil];
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
