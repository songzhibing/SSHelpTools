//
//  SSHelpTableViewFooterView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/12.
//

#import <UIKit/UIKit.h>
@class SSHelpTabViewFooterModel;

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpTableViewFooterView : UICollectionReusableView

@property(nonatomic, strong) NSIndexPath *currentIndexPath;

@property(nonatomic, strong) SSHelpTabViewFooterModel*currentModel;

/// 刷新
- (void)refresh;

@end

NS_ASSUME_NONNULL_END
