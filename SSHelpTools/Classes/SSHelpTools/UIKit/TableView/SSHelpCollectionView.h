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

+ (instancetype)ss_new;

+ (__kindof SSHelpCollectionView *)creatWithFrame:(CGRect)frame;

@property(nonatomic, weak, nullable) id <UICollectionViewDelegate> viewDelegate;

@property(nonatomic, strong) NSMutableArray <SSCollectionViewSectionModel *> *data;

@end

NS_ASSUME_NONNULL_END
