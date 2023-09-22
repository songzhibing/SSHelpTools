//
//  SSHelpTextField.m
//  Pods
//
//  Created by 宋直兵 on 2023/2/3.
//

#import "SSHelpTextField.h"

@interface SSHelpTextField () <UITextFieldDelegate>

@end



@implementation SSHelpTextField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.delegate = self;
    }
    return self;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    if (CGRectIsEmpty(self.ss_leftViewRect)) {
        return [super leftViewRectForBounds:bounds];
    } else {
        return self.ss_leftViewRect;
    }
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    if (CGRectIsEmpty(self.ss_rightViewRect)) {
        return [super rightViewRectForBounds:bounds];
    } else {
        return self.ss_rightViewRect;
    }
}

#pragma mark -
#pragma mark - UITextFieldDelegate Method

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.returnKeyType == UIReturnKeyDone) {
        [textField resignFirstResponder];
    }
    return YES;
}

@end
