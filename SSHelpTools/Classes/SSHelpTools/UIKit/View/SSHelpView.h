//
//  SSHelpView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/1/4.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "UIView+SSHelp.h"
#import "SSHelpDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpView : UIView

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)init NS_UNAVAILABLE;

- (nullable instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
