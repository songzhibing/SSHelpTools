//
//  SSHelpTextField.m
//  Pods
//
//  Created by 宋直兵 on 2023/2/3.
//

#import "SSHelpTextField.h"

@implementation SSHelpTextField

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

@end
