//
//  SSHelpCycleCollectionViewCell.h
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/4/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpCycleItem : NSObject
@property(nonatomic, copy  ) NSString *path;
@property(nonatomic, strong) NSURL    *imageURL;
@property(nonatomic, strong) UIImage  *placeholderImage;
@end


@interface SSHelpCycleCollectionViewCell : UICollectionViewCell

- (void)refresh:(__kindof SSHelpCycleItem *)item;

@end

NS_ASSUME_NONNULL_END
