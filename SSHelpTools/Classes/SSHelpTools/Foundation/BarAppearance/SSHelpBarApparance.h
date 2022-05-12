//
//  SSHelpBarApparance.h
//  Pods
//
//  Created by 宋直兵 on 2022/5/11.
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

@end

NS_ASSUME_NONNULL_END
