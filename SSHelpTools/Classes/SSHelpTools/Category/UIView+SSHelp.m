//
//  UIView+SSHelp.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/12/20.
//

#import "UIView+SSHelp.h"

@implementation UIView (SSHelp)

- (CGFloat)ss_originX
{
    return CGRectGetMinX(self.frame);
}

- (void)setSs_originX:(CGFloat)ss_originX
{
    CGRect rect = self.frame;
    rect.origin.x = ss_originX;
    self.frame = rect;
}

- (CGFloat)ss_originY
{
    return CGRectGetMinY(self.frame);
}

- (void)setSs_originY:(CGFloat)ss_originY
{
    CGRect rect = self.frame;
    rect.origin.y = ss_originY;
    self.frame = rect;
}

- (CGFloat)ss_width
{
    return CGRectGetWidth(self.frame);
}

- (CGFloat)ss_height
{
    return CGRectGetHeight(self.frame);
}

- (CGFloat)ss_frameBottom
{
    return self.ss_originY+self.ss_height;
}

- (CGFloat)ss_frameRight
{
    return self.ss_originX+self.ss_width;
}

@end
