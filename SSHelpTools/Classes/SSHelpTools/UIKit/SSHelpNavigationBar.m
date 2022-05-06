//
//  SSHelpNavigationBar.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/9/3.
//  自定义顶部导航栏
//

#import "SSHelpNavigationBar.h"
#import <Masonry/Masonry.h>

#import "NSObject+SSHelp.h"
#import "SSHelpToolsConfig.h"
#import "SSHelpDefines.h"

@implementation SSHelpNavigationBarModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    SSHelpNavigationBarModel *_model = [[SSHelpNavigationBarModel alloc] init];
    _model.title = SSEncodeStringFromDict(dict, @"title");
    _model.titleImage = SSEncodeStringFromDict(dict,@"image");
    //左侧动态按钮
    NSArray *leftBtnArray = SSEncodeArrayFromDict(dict, @"left");
    if (leftBtnArray && leftBtnArray.count) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:leftBtnArray.count];
        for (NSInteger index=0; index<leftBtnArray.count; index++) {
            SSHelpButtonModel *item =[SSHelpButtonModel modelWithDictionary:leftBtnArray[index]];
            [array addObject:item];
        }
        _model.leftButtons = array;
    }
    //右侧动态按钮
    NSArray *rightBtnArray = SSEncodeArrayFromDict(dict, @"right");
    if (rightBtnArray && rightBtnArray.count) {
        NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:rightBtnArray.count];
        for (NSInteger index=0; index<rightBtnArray.count; index++) {
            SSHelpButtonModel *item =[SSHelpButtonModel modelWithDictionary:rightBtnArray[index]];
            [array addObject:item];
        }
        _model.rightButtons = array;
    }
    return _model;
}

@end

//******************************************************************************
//******************************************************************************


@interface SSHelpNavigationBar()

@property(nonatomic, assign) SSHelpNavigationBarStyle barStyle;

@property(nonatomic, strong) NSHashTable <SSHelpButton *> *dynamicLeftButtons;

@property(nonatomic, strong) NSHashTable <SSHelpButton *> *dynamicRightButtons;

@end

@implementation SSHelpNavigationBar

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _barStyle = SSNavigationBarDefault;
        [self p_setupSubView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _barStyle = SSNavigationBarDefault;
        [self p_setupSubView];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame style:(SSHelpNavigationBarStyle )barStyle
{
    self = [super initWithFrame:frame];
    if (self) {
        _barStyle = barStyle;
        [self p_setupSubView];
    }
    return self;
}

- (void)safeAreaInsetsDidChange API_AVAILABLE(ios(11.0),tvos(11.0))
{
    [super safeAreaInsetsDidChange];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.safeAreaInsets.left);
        make.right.mas_equalTo(-self.safeAreaInsets.right);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}

#pragma mark - Private Method

- (void)p_setupSubView
{
    @weakify(self);
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [SSHelpToolsConfig sharedConfig].navigationBarBackgroundColor;
        
    _contentView = [[UIView alloc] init];
    _contentView.userInteractionEnabled = YES;
    _contentView.backgroundColor = [UIColor clearColor];
    [self addSubview:_contentView];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(-8);
        make.height.mas_equalTo(44);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    ///标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_titleLabel];
    [_titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    ///图片
    _titleImage = [[UIImageView alloc] init];
    _titleImage.contentMode = UIViewContentModeCenter;
    _titleImage.backgroundColor = [UIColor clearColor];
    [_contentView addSubview:_titleImage];
    [_titleImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        //左右留出各一个button间距
        make.left.mas_equalTo(44);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(-44);
        make.height.mas_equalTo(44);
    }];
    
    ///左侧返回按钮
    if (_barStyle & SSNavigationBarWithLeftBack)
    {
        _leftButton = [SSHelpButton buttonWithType:UIButtonTypeCustom];
        _leftButton.normalImage = [SSHelpToolsConfig sharedConfig].navigationBarLeftBackImg;
        _leftButton.contentImageRect = CGRectMake(8, (44-18)/2.0f, 10.5, 18.0f);
        _leftButton.style = SSButtonStyleBack;
        [_contentView addSubview:_leftButton];
        [_leftButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.bottom.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        _leftButton.onClick = ^(SSHelpButton * _Nonnull sender) {
            [self_weak_ p_clickLeftButton:sender];
        };
    }
    
    ///右侧空内容按钮
    if (_barStyle & SSNavigationBarWithLeftBackAndCustomRight)
    {
        SSHelpButtonModel *rightBtnModel = [[SSHelpButtonModel alloc] init];
        _rightButton = [SSHelpButton buttonWithModel:rightBtnModel];
        [_contentView addSubview:_rightButton];
        [_rightButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.bottom.mas_equalTo(-8);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        _rightButton.onClick = ^(SSHelpButton * _Nonnull sender) {
            [self_weak_ p_clickRightButton:sender];
        };
    }
}

- (void)p_clickLeftButton:(SSHelpButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(navigationBar:didLeftButton:)]) {
        [_delegate navigationBar:self didLeftButton:button];
    }
}

- (void)p_clickRightButton:(SSHelpButton *)button
{
    if (_delegate && [_delegate respondsToSelector:@selector(navigationBar:didRightButton:)]) {
        [_delegate navigationBar:self didRightButton:button];
    }
}

#pragma mark - Public Mehod

- (void)resetNavigationBar:(SSHelpNavigationBarModel *)model
{
    //先隐藏所有的旧视图
    [_contentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    
    if ([NSObject ss_isNotEmptySting:model.title]) {
        self.titleLabel.hidden = NO;
        self.titleLabel.text = model.title;
    }

    if (model.titleImage) {
        if ([model.titleImage isKindOfClass:[UIImage class]]) {
            self.titleLabel.hidden = YES;
            self.titleImage.hidden = NO;
            self.titleImage.image = model.titleImage;
        }else if ([model.titleImage isKindOfClass:[NSString class]]){
            NSData *imageDta = [[NSData alloc] initWithBase64EncodedString:model.titleImage
                                                                   options:NSDataBase64DecodingIgnoreUnknownCharacters];
            if (imageDta) {
                self.titleLabel.hidden = YES;
                self.titleImage.hidden = NO;
                self.titleImage.image = [UIImage imageWithData:imageDta];
            }
        }
    }
    [self resetLeftButtons:model.leftButtons];
    [self resetRightButtons:model.rightButtons];
}

- (void)resetLeftButtons:(NSArray <SSHelpButtonModel *> * _Nullable)leftButtons
{
    //清除旧的动态按钮
    if (self.dynamicLeftButtons.allObjects) {
        [self.dynamicLeftButtons.allObjects makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    //添加新的动态按钮
    if ([NSObject ss_isNotEmptyArray:leftButtons])
    {
        for (NSInteger index=0; index<leftButtons.count && index<2; index++)
        {
            SSHelpButtonModel *btnModel = leftButtons[index];
            SSHelpButton *button = [SSHelpButton buttonWithModel:btnModel];
            [_contentView addSubview:button];
            [self.dynamicLeftButtons addObject:button];
            
            CGFloat leftMargin = (index==0)?(0):(0+44+8);
            [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(leftMargin);
                make.width.mas_equalTo(44);
                make.height.mas_equalTo(44);
                make.bottom.mas_equalTo(0);
            }];
        }
    }
}

- (void)resetRightButtons:(NSArray <SSHelpButtonModel *> * _Nullable)rightButtons
{
    //清除旧的动态按钮
    if (self.dynamicRightButtons.allObjects) {
        [self.dynamicRightButtons.allObjects makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    //添加新的动态按钮
    if ([NSObject ss_isNotEmptyArray:rightButtons])
    {
        for (NSInteger index=0; index<rightButtons.count && index<2; index++)
        {
            SSHelpButtonModel *btnModel = rightButtons[index];
            SSHelpButton *button = [SSHelpButton buttonWithModel:btnModel];
            [_contentView addSubview:button];
            [self.dynamicRightButtons addObject:button];
            
            CGFloat rightMargin = (index==0)?(0):(-44-8);
            [button mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.right.mas_equalTo(rightMargin);
                make.width.mas_equalTo(44);
                make.height.mas_equalTo(44);
                make.bottom.mas_equalTo(0);
            }];
        }
    }
}

#pragma mark - Lazyload Method


- (NSHashTable<SSHelpButton *> *)dynamicLeftButtons
{
    if (!_dynamicLeftButtons) {
        _dynamicLeftButtons = [NSHashTable weakObjectsHashTable];
    }
    return _dynamicLeftButtons;
}

- (NSHashTable<SSHelpButton *> *)dynamicRightButtons
{
    if (!_dynamicRightButtons) {
        _dynamicRightButtons = [NSHashTable weakObjectsHashTable];
    }
    return _dynamicRightButtons;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
