//
//  SSHelpListReusableViewModel.h
//  Pods
//
//  Created by 宋直兵 on 2024/1/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

UIKIT_EXTERN NSString *const _kSSListCellEventsDidSelect;
UIKIT_EXTERN NSString *const _kSSListCellEventsDidDeselect;
UIKIT_EXTERN NSString *const _kSSListCellEventsWillDisplay;
UIKIT_EXTERN NSString *const _kSSListCellEventsDidEndDisplaying;


typedef void(^SSListCellEventHandler)(NSString *events);
typedef void(^_Nullable SSListCellCallBack)(id _Nullable data);


@interface SSHelpListReusableViewModel : NSObject

+ (instancetype)new NS_UNAVAILABLE;

- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

/// 初始化
- (instancetype)init;

/// 初始化
+ (instancetype)ss_new;

/// 标识符
@property(nonatomic, copy, readonly) NSString *identifier;

/// 位置索引 [内部处理]
@property(nonatomic, strong) NSIndexPath *indexPath;

/// 视图高度
@property(nonatomic, assign) CGFloat height;

/// 视图类名
@property(nonatomic, assign) Class viewClass;

/// 生命周期事件回调
@property(nonatomic, copy  ) SSListCellEventHandler eventHandler;

/// 自定义事件回调
@property(nonatomic, copy  ) SSListCellCallBack callback;

/// 推荐存储字典数据
@property(nonatomic, strong) __kindof NSDictionary *_Nullable dict;

/// 推荐存储模型数据
@property(nonatomic, strong) id _Nullable model;

@end

NS_ASSUME_NONNULL_END


