//
//  SSHelpCycleCollectionView.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/4/25.
//

#import "SSHelpCycleCollectionView.h"
#import "SSHelpBlockTarget.h"

@interface SSHelpCycleCollectionView () <UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic, strong) NSMutableArray <__kindof SSHelpCycleItem *> *tmpItems;
@property(nonatomic, strong) NSTimer *timer;
@end


@implementation SSHelpCycleCollectionView

- (void)dealloc
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoDragTimeInterval = 3.0f;
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake(self.bounds.size.width, self.bounds.size.height);
    layout.minimumLineSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    self.collectionView.pagingEnabled = YES;
    self.collectionView.clipsToBounds  = YES;
    [self.collectionView registerClass:[SSHelpCycleCollectionViewCell class] forCellWithReuseIdentifier:@"__SSHelpCycleCollectionViewCell"];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self addSubview:self.collectionView];
    
    self.pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(10, self.ss_height-20, self.ss_width-20, 20)];
    [self addSubview:self.pageControl];
}

#pragma mark -
#pragma mark - Setter

- (void)setImagePaths:(NSArray<NSString *> *)imagePaths
{
    _imagePaths = imagePaths;
    NSMutableArray *data = [NSMutableArray arrayWithCapacity:imagePaths.count];
    [imagePaths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        SSHelpCycleItem *item = SSHelpCycleItem.new;
        item.path = obj;
        item.imageURL = [NSURL URLWithString:obj];
        [data addObject:item];
    }];
    self.items = data;
}

- (void)setItems:(NSMutableArray<__kindof SSHelpCycleItem *> *)items
{
    _items = items;
    @Tweakify(self);
    if (items.count<=1) {
        self.tmpItems = [NSMutableArray arrayWithArray:items];
    } else {
        self.tmpItems = [NSMutableArray arrayWithCapacity:items.count+2];
        [self.tmpItems addObject:items.lastObject];
        [items enumerateObjectsUsingBlock:^(__kindof SSHelpCycleItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self_weak_.tmpItems addObject:obj];
        }];
        [self.tmpItems addObject:items.firstObject];
        
        //多个才会自动滚动
        [self setAutoDragTimer];
    }
}

- (void)setAutoDragTimer
{
    self.pageControl.numberOfPages = self.tmpItems.count-2;
    CGPoint firstPoint = CGPointMake(self.collectionView.ss_width, 0);
    [self.collectionView setContentOffset:firstPoint animated:NO];
    
    @Tweakify(self);
    SSHelpBlockTarget *target = [[SSHelpBlockTarget alloc] initWithBlock:^(id  _Nonnull sender) {
        [self_weak_ toDisplayNext];
    }];
    self.timer = [NSTimer timerWithTimeInterval:self.autoDragTimeInterval target:target selector:@selector(invoke:) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

#pragma mark -
#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.tmpItems.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    SSHelpCycleCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"__SSHelpCycleCollectionViewCell" forIndexPath:indexPath];
    [cell refresh:self.tmpItems[indexPath.item]];
    return cell;
}

#pragma mark -
#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = indexPath.item-1;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectItemAtIndex:)]) {
        [self.delegate didSelectItemAtIndex:index];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0))
{
    //SSLog(@"%ld willDisplayCell ...",indexPath.item);
}

- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath API_AVAILABLE(ios(8.0))
{
    
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark -
#pragma mark - Timer Action

- (void)toDisplayNext
{
    //手势拖拽中，禁止自动滚动
    if (self.collectionView.isDecelerating) return;
    
    CGFloat nextOriginX = self.collectionView.contentOffset.x + self.collectionView.bounds.size.width;
    [self.collectionView setContentOffset:CGPointMake(nextOriginX, 0) animated:YES];
}

- (void)toDisplayCurrent
{
    if (self.tmpItems.count>1) {
        CGFloat pageWidth = self.collectionView.ss_width;
        NSInteger page = self.collectionView.contentOffset.x/pageWidth;
        if (page == 0) {
            //滚动到左边
            NSInteger toPage = self.tmpItems.count-2;
            CGPoint toPoint = CGPointMake(pageWidth*toPage, 0);
            [self.collectionView setContentOffset:toPoint animated:NO];
            self.pageControl.currentPage = toPage;
        } else if (page == self.tmpItems.count - 1) {
            //滚动到右边
            NSInteger toPage = 1;
            CGPoint toPoint = CGPointMake(pageWidth*toPage, 0);
            [self.collectionView setContentOffset:toPoint animated:NO];
            self.pageControl.currentPage = toPage-1;
        } else {
            self.pageControl.currentPage = page-1;
        }
    }
}

#pragma mark -
#pragma mark - UIScrollViewDelegate

// any offset changes
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
}

// called on start of dragging (may require some time and or distance to move)
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.timer) {
        self.timer.fireDate = NSDate.distantFuture;
    }
}

// called when scroll view grinds to a halt
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self toDisplayCurrent];
    if (self.timer) {
        self.timer.fireDate = [NSDate  dateWithTimeIntervalSinceNow:self.autoDragTimeInterval];
    }
}

// called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    [self toDisplayCurrent];
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end


