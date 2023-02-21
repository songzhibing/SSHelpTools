//
//  SSHelpCollectionView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/18.
//

#import <UIKit/UIKit.h>
#import "SSHelpCollectionViewModel.h"
#import "SSHelpCollectionViewCell.h"
#import "SSHelpCollectionViewHeader.h"
#import "SSHelpCollectionViewFooter.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpCollectionView : UICollectionView

+ (__kindof SSHelpCollectionView *)creatWithFrame:(CGRect)frame;

@property(nonatomic, strong) NSMutableArray <SSCollectionViewSectionModel *> *data;

// 设置拖放策略
@property(nonatomic, strong, nullable) SSCollectionVieMoveRule *moveRule;

@end

NS_ASSUME_NONNULL_END
