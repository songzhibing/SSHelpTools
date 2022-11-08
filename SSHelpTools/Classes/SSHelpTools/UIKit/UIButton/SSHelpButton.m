//
//  SSHelpButton.m
//  SSHelpTools
//
//  Created by songzhibing on 2017/8/8.
//  Copyright © 2017年 songzhibing. All rights reserved.
//

#import <objc/runtime.h>

#import "SSHelpButton.h"
#import "SSHelpDefines.h"
#import "NSBundle+SSHelp.h"

@implementation SSHelpButton

@synthesize normalTitle = _normalTitle;
@synthesize normalTitleColor = _normalTitleColor;
@synthesize normalImage = _normalImage;
@synthesize highlightedImage = _highlightedImage;
@synthesize selectedImage = _selectedImage;

- (void)dealloc
{
    //SSLifeCycleLog(@"%@ dealloc ... ",self);
}

+ (instancetype)buttonWithStyle:(SSHelpButtonStyle)buttonStyle
{
    SSHelpButton *_button = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    _button.style = buttonStyle;
    _button.frame = CGRectMake(0, 0, 44, 44);
    switch (buttonStyle) {
        case SSButtonStyleBack:
        {
            _button.normalImage = [NSBundle ss_toolsBundleImage:@"SSNav_Back_Dark12x24"];
            _button.contentImageRect = CGRectMake(8, (44-24)/2.0f, 12, 24);
        }
            break;
        case SSButtonStyleLocation:
            break;
        case SSButtonStyleRefresh:
            break;
        case SSButtonStyleList:
            break;
        case SSButtonStyleRightMore:
        {
            _button.normalImage = [NSBundle ss_toolsBundleImage:@"SSNav_Menu_More_Dark_Small43x28"];
            _button.contentImageRect = CGRectMake(44-43, (44-28)/2.0f, 43, 28);
        }
            break;
        case SSButtonStyleRightExit:
        {
            _button.normalImage = [NSBundle ss_toolsBundleImage:@"SSNav_Menu_Exit_Dark_Small43x28"];
            _button.contentImageRect = CGRectMake(0, (44-28)/2.0f, 43, 28);
        }
            break;
        default:
            break;
    }
    return _button;
}

+ (instancetype)buttonWithModel:(SSHelpButtonModel*)model
{
    SSHelpButton *_button = [SSHelpButton buttonWithStyle:model.style];
    _button.identifier = model.identifier;
    _button.childButtons = model.childButtons;
    
    if (model.block) {
        [_button ss_addControlEvents:UIControlEventTouchUpInside block:model.block];
    }
    
    if (model.icon) {
        if ([model.icon isKindOfClass:[UIImage class]]) {
            _button.normalImage = model.icon;
        } else if([model.icon isKindOfClass:[NSString class]]) {
            NSData *imageDta = nil;
            imageDta = [[NSData alloc] initWithBase64EncodedString:model.icon
                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if (imageDta) {
                _button.normalImage = [UIImage imageWithData:imageDta];
            }
        }
    }

    if (!_button.normalImage && model.title) {
        _button.normalTitle = model.title;
    }
    return _button;
}


- (void)setNormalTitle:(NSString *)normalTtile
{
    _normalTitle = normalTtile;
    [self setTitle:normalTtile forState:UIControlStateNormal];
}

- (NSString *)normalTitle
{
    return [self titleForState:UIControlStateNormal];
}

- (void)setNormalTitleColor:(UIColor *)normalTitleColor
{
    _normalTitleColor = normalTitleColor;
    [self setTitleColor:normalTitleColor forState:UIControlStateNormal];
}

- (UIColor *)normalTitleColor
{
    return [self titleColorForState:UIControlStateNormal];
}

- (void)setNormalImage:(UIImage *)normalImage
{
    _normalImage = normalImage;
    [self setImage:normalImage forState:UIControlStateNormal];
}

- (UIImage *)normalImage
{
    return [self imageForState:UIControlStateNormal];
}

- (void)setHighlightedImage:(UIImage *)highlightedImage
{
    _highlightedImage = highlightedImage;
    [self setImage:highlightedImage forState:UIControlStateHighlighted];
}

- (UIImage *)highlightedImage
{
    return [self imageForState:UIControlStateHighlighted];
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    _selectedImage = selectedImage;
    [self setImage:selectedImage forState:UIControlStateSelected];
}

- (UIImage *)selectedImage
{
    return [self imageForState:UIControlStateSelected];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event
{
    CGRect bounds = CGRectMake(CGRectGetMinX(self.bounds) + _outsideEdge.left,
                               CGRectGetMinY(self.bounds) + _outsideEdge.top,
                               CGRectGetWidth(self.bounds) - (_outsideEdge.left+_outsideEdge.right),
                               CGRectGetHeight(self.bounds) - (_outsideEdge.top+_outsideEdge.bottom));
    return CGRectContainsPoint(bounds, point);
}

#pragma mark - Rect

- (CGRect)backgroundRectForBounds:(CGRect)bounds
{
    if (CGRectIsEmpty(_backgroundRect)) {
        return bounds;
    }
    return _backgroundRect;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    if (CGRectIsEmpty(_contentRect)) {
        return bounds;
    }
    return _contentRect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    if (CGRectIsEmpty(_titleContentRect)){
        return contentRect;
    }
    return _titleContentRect;
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    if (CGRectIsEmpty(_contentImageRect)){
        return contentRect;
    }
    return _contentImageRect;
}

#pragma mark - Action

- (void)setOnClick:(void (^)(SSHelpButton *))onClick
{
    [self ss_addControlEvents:UIControlEventTouchUpInside block:onClick];
}

@end
