//
//  SSHelpButton.m
//  SSHelpTools
//
//  Created by songzhibing on 2017/8/8.
//  Copyright © 2017年 songzhibing. All rights reserved.
//

#import "SSHelpButton.h"
#import <objc/runtime.h>

#import "SSHelpDefines.h"
#import "UIButton+SSHelp.h"
#import "NSObject+SSHelp.h"
#import "NSBundle+SSHelp.h"

@implementation SSHelpButtonModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    SSHelpButtonModel *_model = [[SSHelpButtonModel alloc] init];
    _model.title = SSEncodeStringFromDict(dict, @"title");
    _model.icon  = SSEncodeStringFromDict(dict, @"image");
    
    NSString *style = SSEncodeStringFromDict(dict, @"style");
    if ([style isEqualToString:@"back"])
    {
        _model.style =  SSButtonStyleBack;
    }
    else if ([style isEqualToString:@"reload"])
    {
        _model.style =  SSButtonStyleRefresh;
    }
    else if ([style isEqualToString:@"list"])
    {
        //列表按钮
        _model.style =  SSButtonStyleList;
        _model.childButtons = SSEncodeArrayFromDict(dict, @"list");
    }else{
        _model.style =  SSButtonStyleCustom;

    }
    return _model;
}

@end

//******************************************************************************
//******************************************************************************


@implementation SSHelpButton

@synthesize normalTitle = _normalTitle;
@synthesize normalTitleColor = _normalTitleColor;
@synthesize normalImage = _normalImage;
@synthesize highlightedImage = _highlightedImage;
@synthesize selectedImage = _selectedImage;

- (void)dealloc
{
    SSToolsLog(@"%@ dealloc ... ",self);
}

+ (instancetype)buttonWithStyle:(SSHelpButtonStyle)buttonStyle
{
    SSHelpButton *_button = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    _button.frame = CGRectMake(0, 0, 44, 44);
    if (buttonStyle == SSButtonStyleBack)
    {
        _button.normalImage = [NSBundle ss_navigationBackImage];
    }
    else if (buttonStyle == SSButtonStyleLocation)
    {
        _button.normalImage = [NSBundle ss_navigationBackImage];
    }
    else if (buttonStyle == SSButtonStyleFlashlight)
    {
        _button.normalImage = [NSBundle ss_flashlightOpenImg];
        _button.selectedImage = [NSBundle ss_flashlightCloseImg];
    }
    return _button;
}

+ (instancetype)buttonWithModel:(SSHelpButtonModel*)buttonModel
{
    SSHelpButton *_button = [SSHelpButton buttonWithStyle:buttonModel.style];
    _button.identifier = buttonModel.identifier;
    _button.childButtons = buttonModel.childButtons;
    
    if (buttonModel.block)
    {
        [_button ss_addBlockForControlEvents:UIControlEventTouchUpInside
                                       block:buttonModel.block];
    }
    
    if (buttonModel.icon)
    {
        if ([buttonModel.icon isKindOfClass:[UIImage class]])
        {
            _button.normalImage = buttonModel.icon;
        }
        else if([buttonModel.icon isKindOfClass:[NSString class]])
        {
            NSData *imageDta = nil;
            imageDta = [[NSData alloc] initWithBase64EncodedString:buttonModel.icon
                                                           options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if (imageDta)
            {
                _button.normalImage = [UIImage imageWithData:imageDta];
            }
        }
    }

    if(!_button.normalImage && [NSObject ss_isNotEmptySting:buttonModel.title]){
        _button.normalTitle = buttonModel.title;

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
    UIEdgeInsets outsideEdge = self.outsideEdge;
    CGRect boundsInsetOutsideEdge = CGRectMake(CGRectGetMinX(self.bounds) + outsideEdge.left, CGRectGetMinY(self.bounds) + outsideEdge.top, CGRectGetWidth(self.bounds) -(outsideEdge.left+outsideEdge.right), CGRectGetHeight(self.bounds) - (outsideEdge.top+outsideEdge.bottom));
    return CGRectContainsPoint(boundsInsetOutsideEdge, point);
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
    [self ss_addTouchUpInsideBlock:onClick];
}

@end
