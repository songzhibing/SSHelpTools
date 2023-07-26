//
//  SSHelpDropdownMenu.m
//


#import "SSHelpDropdownMenu.h"
#import "SSHelpCollectionView.h"
#import "SSHelpButton.h"
#import "NSBundle+SSHelp.h"

@interface SSDropdownMenuItem ()

@property(nonatomic, assign, readwrite) NSInteger index;

@end


@implementation SSDropdownMenuItem

+ (instancetype)itemWithTitle:(NSString *)title
{
    SSDropdownMenuItem *item = [[SSDropdownMenuItem alloc] init];
    item.title = title;
    return item;
}

@end


//******************************************************************************
//******************************************************************************


@interface SSHelpDropdownMenuCell : SSHelpCollectionViewCell

@property(nonatomic, strong) UIImageView *iconView;

@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, strong) SSHelpButton *selectBtn;

@property(nonatomic, strong) UIView *lineView;

@end


@implementation SSHelpDropdownMenuCell

- (void)refresh
{
    if (!self.titleLabel) {
        SSHelpDropdownMenu *dropdownMenu = self.cellModel.delegate;
        
        self.contentView.backgroundColor = dropdownMenu.optionBgColor;

        self.lineView = UIView.new;
        self.lineView.backgroundColor = dropdownMenu.optionLineColor;
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(dropdownMenu.optionLineHeight);
            make.left.bottom.right.mas_equalTo(0);
        }];
        
        self.titleLabel = UILabel.new;
        self.titleLabel.backgroundColor = UIColor.clearColor;
        self.titleLabel.textColor = dropdownMenu.optionTextColor;
        self.titleLabel.textAlignment = dropdownMenu.optionTextAlignment;
        [self.contentView addSubview:self.titleLabel];
        [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_offset(dropdownMenu.optionTextMarginLeft);
            make.right.mas_offset(-dropdownMenu.optionTextMarginLeft);
            make.bottom.mas_equalTo(self.lineView.mas_top);
        }];
    }
    
    SSDropdownMenuItem *item = self.cellModel.model;
    self.titleLabel.text = item.title;
}

@end


//******************************************************************************
//******************************************************************************


@interface SSHelpDropdownMenu()
@property(nonatomic, strong) SSHelpView *backView;
@property(nonatomic, strong) SSHelpView *contentView;
@property(nonatomic, strong) SSHelpCollectionView *collectionView;
@property(nonatomic, assign) NSInteger  optionOrientation;
@property(nonatomic, strong) SSCollectionViewSectionModel *sectionsData;
@end


@implementation SSHelpDropdownMenu

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _contentBgColor         = UIColor.systemGroupedBackgroundColor;
        _contentCornerRadius    = 6;

        _optionBgColor          = UIColor.secondarySystemGroupedBackgroundColor;
        _optionItemHeight       = 44;
        _optionFont             = [UIFont systemFontOfSize:13];
        _optionTextColor        = UIColor.labelColor;
        _optionTextAlignment    = NSTextAlignmentLeft;
        _optionTextMarginLeft   = 15;
        _optionNumberOfLines    = 0;
        
        _optionIconSize         = CGSizeMake(0, 0);
        _optionIconMarginRight  = 15;
        
        _optionLineColor        = UIColor.tertiarySystemGroupedBackgroundColor;
        _optionLineHeight       = 1.0f;

        _animateTime            = 0.25f;

        _optionsListLimitHeight = 0;
        
        _supportMutableSelect   = NO;
        
        [self setupUI];
    }
    return self;
}

#pragma mark -
#pragma mark - Private Method

- (void)setupUI
{
    [self addSubview:self.mainBtn];
}


- (void)showDropDownView
{
    self.backView = [[SSHelpView alloc] initWithFrame:self.window.bounds];
    self.backView.backgroundColor = UIColor.clearColor;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenDropDownView)];
    [self.backView addGestureRecognizer:tapGesture];
    [self.window addSubview:self.backView];
    
    
    CGRect rect = [self convertRect:self.bounds toView:self.window];
    
    NSInteger maxRow = 6;
    CGFloat topSpace = 4;
    CGFloat triangleHeight = 8;
    CGFloat totalHeight = self.optionItemHeight * MIN(maxRow, self.data.count);
    
    NSInteger orientation = 3;//bottom.
    CGRect vframe = CGRectZero;
    if (orientation==3) {
        //bottom
        vframe = CGRectMake(rect.origin.x, rect.origin.y+rect.size.height+topSpace, rect.size.width, totalHeight);
    }

    self.contentView = [[SSHelpView alloc] initWithFrame:vframe];
    self.contentView.layer.masksToBounds = YES;
    self.contentView.backgroundColor = UIColor.clearColor;
    [self.window addSubview:self.contentView];
    
    vframe = CGRectMake(0, triangleHeight, vframe.size.width, vframe.size.height-triangleHeight);
    SSHelpCollectionView *collectionView = [SSHelpCollectionView creatWithFrame:vframe];
    collectionView.showsVerticalScrollIndicator = self.showsVerticalScrollIndicator;
    collectionView.backgroundColor = self.contentBgColor;
    collectionView.layer.cornerRadius = self.contentCornerRadius;
    collectionView.data = @[self.sectionsData].mutableCopy;
    [self.contentView addSubview:collectionView];
    
    // 执行展开动画
    vframe = self.contentView.frame;
    self.contentView.frame = CGRectMake(vframe.origin.x, vframe.origin.y, vframe.size.width, 0);
    self.contentView.alpha = 0;
    [UIView animateWithDuration:self.animateTime animations:^{
        self.contentView.frame = vframe;
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
    }];
}

- (void)hiddenDropDownView
{
    CGRect vframe = self.contentView.frame;
    vframe.size.height = 0;
    [UIView animateWithDuration:self.animateTime animations:^{
        self.contentView.frame =  vframe;
        self.contentView.alpha = 0;
        self.backView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backView removeFromSuperview];
        [self.contentView removeFromSuperview];
        // 回调
        if (self.didSelect) {
            NSMutableArray *response = NSMutableArray.array;
            [self.data enumerateObjectsUsingBlock:^(SSDropdownMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (obj.isSelected) {
                    [response addObject:obj];
                }
            }];
            self.didSelect(response);
        }
    }];
}

#pragma mark -
#pragma mark - Getter Method

- (SSHelpButton *)mainBtn
{
    if (!_mainBtn) {
        _mainBtn = [SSHelpButton buttonWithType:UIButtonTypeCustom];
        _mainBtn.normalTitleColor = UIColor.labelColor;
        _mainBtn.normalTitle = @"";
        _mainBtn.titleLabel.textAlignment = NSTextAlignmentCenter;
        _mainBtn.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _mainBtn.normalImage = [NSBundle ss_toolsBundleImage:@"SSNav_Back_Dark12x24"];
        [_mainBtn addTarget:self action:@selector(showDropDownView) forControlEvents:UIControlEventTouchUpInside];
        
        CGRect  _vframe            = self.bounds;
        CGFloat _width             = self.frame.size.width;
        CGFloat _height            = self.frame.size.height;
        CGSize  _arrowSize         = CGSizeMake(15, 15);
        CGFloat _arrowMarginRight  = 7.5;
        
        _mainBtn.frame = _vframe;
        
        _vframe = CGRectMake(_width -_arrowMarginRight -_arrowSize.width, (_height -_arrowSize.height)/2, _arrowSize.width, _arrowSize.height);
        _mainBtn.imageRect = _vframe;
        
        _vframe = CGRectMake(0, 0, _width -_arrowMarginRight*2 -_arrowSize.width,_height);
        _mainBtn.titleRect = _vframe;
    }
    return _mainBtn;
}

- (SSCollectionViewSectionModel *)sectionsData
{
    if (!_sectionsData) {
        @Tweakify(self);
        _sectionsData = SSCollectionViewSectionModel.ss_new;
        _sectionsData.cellModels = [[NSMutableArray alloc] initWithCapacity:self.data.count];
        for (NSInteger index=0; index<self.data.count; index++) {
            
            //数据模型操作
            __block SSDropdownMenuItem *item = self.data[index];
            item.index = index;
            
            //Cell视图操作
            SSCollectionViewCellModel *cell = SSCollectionViewCellModel.ss_new;
            cell.cellClass = [SSHelpDropdownMenuCell class];
            cell.model = item;
            cell.delegate = self;
            cell.didSelect = ^{
                if (self_weak_.supportMutableSelect) {
                    // 支持多选
                    item.isSelected = !item.isSelected;
                    // 更新UI
                    __block NSString *newTitle = @"";
                    [self_weak_.data enumerateObjectsUsingBlock:^(SSDropdownMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (obj.isSelected) {
                            newTitle = [NSString stringWithFormat:@"%@%@%@",newTitle,newTitle.length?@",":@"",obj.title];
                        }
                    }];
                    self_weak_.mainBtn.normalTitle = newTitle;
                    // 多选不立即收起列表视图
                    //[self_weak_ hiddenDropDownView];
                } else {
                    // 单选
                    __block SSDropdownMenuItem *selectedItem = nil;
                    [self_weak_.data enumerateObjectsUsingBlock:^(SSDropdownMenuItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if ([obj.title isEqualToString:item.title]) {
                            obj.isSelected = !obj.isSelected;
                            selectedItem = obj;
                        } else {
                            obj.isSelected = NO;
                        }
                    }];
                    // 更新UI
                    self_weak_.mainBtn.normalTitle = selectedItem.title;
                    [self_weak_ hiddenDropDownView];
                }
            };
            [_sectionsData.cellModels addObject:cell];
        }
    }
    return _sectionsData;
}

@end




