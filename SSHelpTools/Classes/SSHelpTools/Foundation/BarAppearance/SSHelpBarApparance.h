//
//  SSHelpBarApparance.h
//  Pods
//
//  Created by 宋直兵 on 2022/5/11.
//  自定义外观配置, 兼容iOS10~
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpBarApparance : NSObject

/// A specific blur effect to use for the bar background. This effect is composited first when constructing the bar's background.
@property (nonatomic, readwrite, copy, nullable) UIBlurEffect *backgroundEffect;

/// A color to use for the bar background. This color is composited over backgroundEffects.
@property (nonatomic, readwrite, copy, nullable) UIColor *backgroundColor;

/// An image to use for the bar background. This image is composited over the backgroundColor, and resized per the backgroundImageContentMode.
@property (nonatomic, readwrite, strong, nullable) UIImage *backgroundImage;

/// A color to use for the shadow. Its specific behavior depends on the value of shadowImage. If shadowImage is nil, then the shadowColor is used to color the bar's default shadow; a nil or clearColor shadowColor will result in no shadow. If shadowImage is a template image, then the shadowColor is used to tint the image; a nil or clearColor shadowColor will also result in no shadow. If the shadowImage is not a template image, then it will be rendered regardless of the value of shadowColor.
@property (nonatomic, readwrite, copy, nullable) UIColor *shadowColor;

/// Use an image for the shadow. See shadowColor for how they interact.
@property (nonatomic, readwrite, strong, nullable) UIImage *shadowImage;

@end

NS_ASSUME_NONNULL_END
