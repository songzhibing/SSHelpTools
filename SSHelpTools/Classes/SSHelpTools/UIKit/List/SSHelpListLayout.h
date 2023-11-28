//
//  SSHelpListLayout.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/11/15.
//

#import <UIKit/UIKit.h>
#import "SSHelpListViewModel.h"
#import "SSHelpListDecorationView.h"

@class SSHelpListLayout;

NS_ASSUME_NONNULL_BEGIN

@interface SSListLayoutDelegateReturn : NSObject
@property(nonatomic, assign) NSInteger    integeValue;
@property(nonatomic, assign) CGFloat      floatValue;
@property(nonatomic, assign) UIEdgeInsets insetsValue;
@property(nonatomic, assign) CGSize       sizeValue;
@property(nonatomic, strong) SSListDecorationViewApply decorationViewApply;
@end


/// 布局协议
@protocol SSListLayoutDelegate <NSObject>

@optional

- (SSListLayoutDelegateReturn *)layout:(SSHelpListLayout *)layout option:(SSListLayoutDelegateOptions)option indexPath:(NSIndexPath *)indexPath;

@end


/// 自定义布局
@interface SSHelpListLayout : UICollectionViewLayout

/// 初始化
- (instancetype)init;

/// 代理
@property(nonatomic, weak) id <SSListLayoutDelegate> delegate;

/// Section.Header 悬浮
@property(nonatomic, assign) BOOL sectionHeadersPinToVisibleBounds;

@end


NS_ASSUME_NONNULL_END
