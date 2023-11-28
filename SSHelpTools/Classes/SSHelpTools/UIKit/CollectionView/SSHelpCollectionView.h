//
//  SSHelpCollectionView.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/10/18.
//  2023.11.11 推荐使用SSHelpListView
//

#import <UIKit/UIKit.h>
#import "SSHelpCollectionViewModel.h"
#import "SSHelpCollectionViewCell.h"
#import "SSHelpCollectionViewHeader.h"
#import "SSHelpCollectionViewFooter.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SSHelpCollectionViewDelegate <UICollectionViewDelegate>

@end


@interface SSHelpCollectionView : UICollectionView

+ (instancetype)ss_new;

+ (instancetype)creatWithFrame:(CGRect)frame;

@property(nonatomic, weak, nullable) id <SSHelpCollectionViewDelegate> ss_delegate;

@property(nonatomic, strong) NSMutableArray <SSCollectionViewSectionModel *> *data;

@end

NS_ASSUME_NONNULL_END
