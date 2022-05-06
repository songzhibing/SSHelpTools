//
//  SSHelpNavigationController.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/4/6.
//

#import "SSHelpNavigationController.h"

@interface SSHelpNavigationController ()

@end

@implementation SSHelpNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //侧滑返回手势
    if (!self.interactivePopGestureRecognizerDisable && [self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        __weak typeof(self) __weak_self = self;
        self.interactivePopGestureRecognizer.delegate = (id)__weak_self;
    }
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        //屏蔽调用rootViewController的滑动返回手势，避免右滑返回手势引起crash
        if (self.viewControllers.count < 2 || self.visibleViewController == [self.viewControllers objectAtIndex:0]) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - Autorotation support.

- (BOOL)shouldAutorotate
{
    return [self.visibleViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return [self.visibleViewController supportedInterfaceOrientations];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return [self.visibleViewController preferredInterfaceOrientationForPresentation];
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
