//
//  SSHelpSlidePageView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/10/22.
//

#import "SSHelpSlidePageView.h"
#import <Masonry/Masonry.h>

#define __UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

///*****************************************************************************
///标题Cell
///*****************************************************************************
@interface GCSlideCollectionViewCell:UICollectionViewCell

@property(nonatomic, strong) UILabel *titleLab;

@end

@implementation GCSlideCollectionViewCell

- (UILabel *)titleLab
{
    if (!_titleLab) {
        _titleLab = [[UILabel alloc] init];
        _titleLab.textColor = [UIColor blackColor];
        _titleLab.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLab];
        [_titleLab mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(0);
        }];
    }
    return _titleLab;
}

@end

///*****************************************************************************
///滑动视图
///*****************************************************************************
///
@interface SSHelpSlidePageView()<UICollectionViewDelegate,
UICollectionViewDataSource,
UIScrollViewDelegate>

/// 标题数据
@property(nonatomic, strong) NSArray <NSString *> *titles;

@property(nonatomic, strong) UIColor *normalTitleColor;

@property(nonatomic, strong) UIColor *selectedTitleColor;

@property(nonatomic, strong) UIColor *selectionIndicatorColor;

@property(nonatomic, strong) UIColor *selectionBackgroundColor;

@property(nonatomic, assign) CGSize titleItemMinSize;

/// 内容区域
@property(nonatomic, strong) UIView *contentView;

@property(nonatomic, strong) UICollectionViewFlowLayout *layout;

@property(nonatomic, strong) UICollectionView *titleCollectionView;

@property(nonatomic, strong) UIView *slideIndicatorView;

@property(nonatomic, strong) UIScrollView *scrollView;

@property(nonatomic, strong) NSMutableArray <UIView *> *subContentViews;

/// 当前选中索引
@property(nonatomic, assign) NSInteger currentSelectedIndex;

@end

@implementation SSHelpSlidePageView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self p_initial];
        [self p_setupSubView];
    }
    return self;
}

#pragma mark - Private Method

- (void)p_initial
{
    _selectionBackgroundColor = __UIColorFromRGB(0xf2f2f2);
    _normalTitleColor = __UIColorFromRGB(0x646464);
    _selectedTitleColor = __UIColorFromRGB(0x387bee);
    _selectionIndicatorColor = __UIColorFromRGB(0x387bee);
    
    self.backgroundColor = [UIColor whiteColor];
    self.userInteractionEnabled = YES;

    _currentSelectedIndex = NSNotFound;
    _titleItemMinSize = CGSizeMake(120, 44);
    _subContentViews = [[NSMutableArray alloc] initWithCapacity:1];
}

- (void)p_setupSubView
{
    _contentView = [[UIView alloc] initWithFrame:self.bounds];
    _contentView.userInteractionEnabled = YES;
    _contentView.backgroundColor = _selectionBackgroundColor;
    [self addSubview:_contentView];
    
    _layout = [[UICollectionViewFlowLayout alloc] init];
    _layout.itemSize = _titleItemMinSize;
    _layout.minimumLineSpacing = 0; // cell的横向间距
    _layout.minimumInteritemSpacing = 0;  // cell的纵向间距
    _layout.sectionInset = UIEdgeInsetsMake(0, 0 ,0, 0);//section之间的间距
    _layout.scrollDirection = UICollectionViewScrollDirectionHorizontal; // 设置滚动方向（默认垂直滚动）


    CGRect rect = CGRectMake(0, 0, _contentView.ss_width, _titleItemMinSize.height);
    _titleCollectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:_layout];
    _titleCollectionView.delegate = self;
    _titleCollectionView.dataSource = self;
    //_titleCollectionView.pagingEnabled = YES; // 开启分页
    _titleCollectionView.showsHorizontalScrollIndicator = NO;  // 隐藏水平滚动条
    _titleCollectionView.bounces = NO;  // 取消弹簧效果
    _titleCollectionView.backgroundColor = _selectionBackgroundColor;
    [_titleCollectionView registerClass:[GCSlideCollectionViewCell class] forCellWithReuseIdentifier:@"GCSlideCollectionViewCellId"];
    [_contentView addSubview:_titleCollectionView];


    _slideIndicatorView = [[UIView alloc] init];
    _slideIndicatorView.frame = CGRectMake(0, 42, 44, 2);
    _slideIndicatorView.backgroundColor = _selectionIndicatorColor;
    _slideIndicatorView.hidden = YES;
    [_titleCollectionView addSubview:_slideIndicatorView];

    rect = CGRectMake(0,_titleItemMinSize.height,
                      _contentView.ss_width,
                      _contentView.ss_height-_titleItemMinSize.height);
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.bounces = NO;  // 取消弹簧效果
    _scrollView.backgroundColor = [UIColor groupTableViewBackgroundColor];
    [_contentView addSubview:_scrollView];
}

- (void)safeAreaInsetsDidChange API_AVAILABLE(ios(11.0),tvos(11.0))
{
    [super safeAreaInsetsDidChange];
    
    //调整内容安全区域
    _contentView.frame = self.safeAreaLayoutGuide.layoutFrame;
    
    //调整标题栏
    CGFloat _titleItemWidth = _contentView.ss_width/(CGFloat)_titles.count;
    _titleItemWidth = MAX(_titleItemWidth, _titleItemMinSize.width);
    _layout.itemSize = CGSizeMake(_titleItemWidth, _titleItemMinSize.height);
    _titleCollectionView.frame = CGRectMake(0,0,_contentView.ss_width, _titleItemMinSize.height);
    [_titleCollectionView reloadData];

    //调整滑动区域
    _scrollView.frame = CGRectMake(0,
                                   _titleItemMinSize.height,
                                   _contentView.ss_width,
                                   _contentView.ss_height-_titleItemMinSize.height);
    
    _scrollView.contentSize = CGSizeMake(_titles.count*_scrollView.ss_width,
                                         _scrollView.ss_height);
    
//    [self.subContentViews.firstObject mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0);
//        make.left.mas_equalTo(0);
//        make.width.mas_equalTo(self.scrollView.gcFrameWidth);
//        make.height.mas_equalTo(self.scrollView.gcFrameHeight);
//    }];
    
    //同步移动内容区域，居中显示(横竖屏切换时，子视图位置有时需要调整一下...)
    if (_currentSelectedIndex != NSNotFound)
    {
        CGPoint move = CGPointMake(_currentSelectedIndex*_scrollView.ss_width,0);
        [_scrollView setContentOffset:move animated:NO];
    }
    
    [self p_asyncMoveTitleBottomLine];
}

#pragma mark - Public Method

/// 刷新
- (void)reload
{
    _titles = nil;  //整体刷新，删除原由数据，从新获取
    [self loadViewAtIndex:0];
}

/// 加载第几页
/// @param index 索引
- (void)loadViewAtIndex:(NSInteger)index
{
    if (!_titles.count) // 首次或者整体刷新，重新读取数据，创建子视图
    {
        // 获取标题
        if (_dataSource && [_dataSource respondsToSelector:@selector(titlesInSlidePageView:)]) {
            _titles = [_dataSource titlesInSlidePageView:self];
        }
        
        // 清除旧视图
        if (_scrollView.subviews) {
            [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        }
        if (_subContentViews) {
            [_subContentViews removeAllObjects];
        }

        // 根据标题数据，创建宿主子视图
        CGRect subViewRect = CGRectMake(0, 0,_scrollView.ss_width,_scrollView.ss_height);
        UIView *lastSubContentView = nil;
        for (NSInteger index=0; index<[_titles count]; index++)
        {
            subViewRect.origin.x = index*_scrollView.ss_width;
            UIView *subContentView = [[UIView alloc] initWithFrame:subViewRect];
            subContentView.userInteractionEnabled = YES;
            subContentView.backgroundColor = self.backgroundColor;
            
            /*
            UIView *testView = [[UIView alloc] init];
            testView.backgroundColor = [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
            [subContentView addSubview:testView];
            [testView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.edges.mas_equalTo(UIEdgeInsetsMake(10, 10, 10, 10));
            }];
             */
            
            [_scrollView addSubview:subContentView];
            [_subContentViews addObject:subContentView];
            
            if (index==0) {
                [subContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                    make.left.mas_equalTo(0);
                    make.width.mas_equalTo(_scrollView);
                    make.height.mas_equalTo(_scrollView);
                }];
            }else{
                [subContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(0);
                    make.left.mas_equalTo(lastSubContentView.mas_right);
                    make.width.mas_equalTo(_scrollView);
                    make.height.mas_equalTo(_scrollView);
                }];
            }
            lastSubContentView = subContentView;
        }
        
        _scrollView.contentSize = CGSizeMake(_titles.count*_contentView.ss_width,
                                            _contentView.ss_height-_titleItemMinSize.height);
    }
    
    if (_titles && _titles.count)
    {
        //提示离开页面
        if (_currentSelectedIndex != NSNotFound)
        {
            if (_currentSelectedIndex != index)
            {
                if (_delegate  && [_delegate respondsToSelector:@selector(slidePageView:didEndDisplayingView:atIndex:)])
                {
                    [_delegate slidePageView:self didEndDisplayingView:_subContentViews[_currentSelectedIndex] atIndex:_currentSelectedIndex];
                }
            }
        }
        
        //同步移动标题栏，居中显示
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        [_titleCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
        
        //同步移动内容区域，居中显示
         CGPoint move = CGPointMake(indexPath.item* _scrollView.ss_width, 0);
         [_scrollView setContentOffset:move animated:NO];
        
        //提示进入页面
        if (_currentSelectedIndex != index)
        {
            if (_delegate  && [_delegate respondsToSelector:@selector(slidePageView:displayView:atIndex:)]) {
                [_delegate slidePageView:self displayView:_subContentViews[index] atIndex:index];
            }
            _currentSelectedIndex = index;
        }
        
        [self p_asyncMoveTitleBottomLine];
    }
}

// 标题栏底部线条
- (void)p_asyncMoveTitleBottomLine
{
    if (_currentSelectedIndex!= NSNotFound)
    {
        CGFloat _titleItemWidth = _layout.itemSize.width;
        CGPoint movePoint = self.slideIndicatorView.center;
        movePoint.x = (_titleItemWidth/2.0f)*(_currentSelectedIndex*2+1);
        
        [UIView animateWithDuration:0.25f animations:^{
              self.slideIndicatorView.center = movePoint;
        } completion:^(BOOL finished) {
              self.slideIndicatorView.hidden = NO;
        }];
        
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_currentSelectedIndex inSection:0];
        GCSlideCollectionViewCell *cell = (GCSlideCollectionViewCell *)[_titleCollectionView cellForItemAtIndexPath:indexPath];
        __weak typeof(self) __weak_self = self;
        [_titleCollectionView.visibleCells enumerateObjectsUsingBlock:^(__kindof GCSlideCollectionViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.titleLab.textColor = __weak_self.normalTitleColor;
            if (obj == cell) {
                obj.titleLab.textColor = __weak_self.selectedTitleColor;
            }
        }];
    }
}

#pragma mark - UIScrollViewDelegate Method

/// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{

}
/// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (scrollView==_scrollView)
    {
        int newIndex = scrollView.contentOffset.x / scrollView.ss_width;
        if (_currentSelectedIndex!=newIndex) //移动了
        {
            [self loadViewAtIndex:newIndex];
        }
    }
}

#pragma mark - UICollectionViewDataSource Method

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _titles.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GCSlideCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GCSlideCollectionViewCellId" forIndexPath:indexPath];
    cell.titleLab.text = _titles[indexPath.item];
    cell.titleLab.textColor = _normalTitleColor;
    if (indexPath.row == _currentSelectedIndex) {
        cell.titleLab.textColor = _selectedTitleColor;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(GCSlideCollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0))
{
    if (indexPath.item==_currentSelectedIndex)
    {
        //同步移动标题栏，居中显示
        [collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
    }
}

#pragma mark -  UICollectionViewDelegate Mehtod

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_currentSelectedIndex!=indexPath.item) //移动了
    {
        [self loadViewAtIndex:indexPath.item];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{

}

@end
