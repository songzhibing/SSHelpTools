//
//  SSHelpListDecorationView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const _kSSListDecorationViewKind;

@interface SSListDecorationViewLayoutAttributes : UICollectionViewLayoutAttributes

@property(nonatomic, strong) void (^applyCallback) (UIView *backgroundView);

@end


/// 装饰图(Section背景视图)
@interface SSHelpListDecorationView : UICollectionReusableView

@property(nonatomic, strong) UIView *backgroundView;

@end

NS_ASSUME_NONNULL_END
