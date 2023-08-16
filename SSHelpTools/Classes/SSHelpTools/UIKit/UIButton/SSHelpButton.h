//
//  SSHelpButton.h
//  SSHelpTools
//
//  Created by songzhibing on 2017/8/8.
//  Copyright © 2017年 songzhibing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SSHelpButtonModel.h"
#import "UIButton+SSHelp.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpButton : UIButton

+ (instancetype)buttonWithStyle:(SSHelpButtonStyle)buttonStyle;

+ (instancetype)buttonWithModel:(SSHelpButtonModel*)buttonModel;

@property(nonatomic, assign) SSHelpButtonStyle style;

@property(nonatomic, copy  ) void (^onClick)(SSHelpButton *sender);

@property(nonatomic, copy  ) NSString *identifier;

@property(nonatomic, strong) UIFont *textFont;

@property(nonatomic, assign) NSTextAlignment textAlignment;

@property(nonatomic, copy  ) NSString *normalTitle;

@property(nonatomic, strong) UIColor *normalTitleColor;

@property(nonatomic, copy  ) NSString *selectedTitle;

@property(nonatomic, strong) UIColor *selectedTitleColor;

@property(nonatomic, strong) UIImage *normalImage;

@property(nonatomic, strong) UIImage *selectedImage;

@property(nonatomic, strong) UIImage *normalBackImage;

@property(nonatomic, strong) UIImage *selectedBackImage;

@property(nonatomic, assign) CGRect backgroundRect;

@property(nonatomic, assign) CGRect contentRect;

@property(nonatomic, assign) CGRect imageRect;

@property(nonatomic, assign) CGSize imageSizeAtCenter;

@property(nonatomic, assign) CGRect titleRect;

@property(nonatomic, assign) UIEdgeInsets outsideEdge;

@property(nonatomic, strong) NSArray <NSDictionary *> *_Nullable childButtons;

@end

NS_ASSUME_NONNULL_END
