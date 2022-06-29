//
//  SSHelpNavigationBar.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2021/9/3.
//  自定义顶部导航栏
//

#import "SSHelpNavigationBar.h"
#import "SSHelpView.h"

@interface SSHelpNavigationBar()

@property(nonatomic, assign) SSHelpNavigationBarStyle barStyle;

@property(nonatomic, strong) NSHashTable <SSHelpButton *> *dynamicLeftButtons;

@property(nonatomic, strong) NSHashTable <SSHelpButton *> *dynamicRightButtons;

@end

@implementation SSHelpNavigationBar

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
        make.left.mas_equalTo(self.safeAreaInsets.left?:8);
        make.right.mas_equalTo(-(self.safeAreaInsets.right?:8));
        make.height.mas_equalTo(_kNavBarHeight);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}

#pragma mark - Private Method

- (void)p_setupSubView
{
    @Tweakify(self);
    
    self.userInteractionEnabled = YES;
    self.backgroundColor = [SSHelpToolsConfig sharedConfig].tertiaryFillColor;
        
    _dynamicLeftButtons  = [NSHashTable weakObjectsHashTable];
    _dynamicRightButtons = [NSHashTable weakObjectsHashTable];

    _contentView = [[UIView alloc] init];
    _contentView.userInteractionEnabled = YES;
    _contentView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.f];
    [self addSubview:_contentView];
    [_contentView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(8);
        make.right.mas_equalTo(-8);
        make.height.mas_equalTo(_kNavBarHeight);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
    
    ///标题
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.textColor = SSHELPTOOLSCONFIG.labelColor;
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
        make.left.bottom.right.mas_equalTo(0);
        make.height.mas_equalTo(44);
    }];
    
    ///左侧返回按钮
    if (_barStyle & SSNavigationBarWithLeftBack)
    {
        _leftButton = [SSHelpButton buttonWithStyle:SSButtonStyleBack];
        [_contentView addSubview:_leftButton];
        [_leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [_leftButton setOnClick:^(SSHelpButton * _Nonnull sender) {
            [self_weak_ p_clickLeftButton:sender];
        }];
        [_dynamicLeftButtons addObject:_leftButton];
    }
    
    ///右侧按钮
    if (_barStyle & SSNavigationBarWithRightMenu)
    {
        _rightExitButton = [SSHelpButton buttonWithStyle:SSButtonStyleRightExit];
        [_contentView addSubview:_rightExitButton];
        [_rightExitButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [_rightExitButton setOnClick:^(SSHelpButton * _Nonnull sender) {
            [self_weak_ p_clickRightButton:sender];
        }];
        
        _rightMoreButton = [SSHelpButton buttonWithStyle:SSButtonStyleRightMore];
        [_contentView addSubview:_rightMoreButton];
        [_rightMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(_rightExitButton.mas_left);
            make.size.mas_equalTo(CGSizeMake(44, 44));
        }];
        [_rightMoreButton setOnClick:^(SSHelpButton * _Nonnull sender) {
            [self_weak_ p_clickRightButton:sender];
        }];
        
        [_dynamicRightButtons addObject:_rightExitButton];
        [_dynamicRightButtons addObject:_rightMoreButton];
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
    
    if (model.title) {
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
    
    if (!leftButtons) {
        return;
    }
    
    //添加新的动态按钮
    @Tweakify(self);
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
        [button setOnClick:^(SSHelpButton * _Nonnull sender) {
            [self_weak_ p_clickLeftButton:sender];
        }];
    }
}

- (void)resetRightButtons:(NSArray <SSHelpButtonModel *> * _Nullable)rightButtons
{
    //清除旧的动态按钮
    if (self.dynamicRightButtons.allObjects) {
        [self.dynamicRightButtons.allObjects makeObjectsPerformSelector:@selector(removeFromSuperview)];
    }
    
    if (!rightButtons) {
        return;
    }
    
    //添加新的动态按钮
    @Tweakify(self);
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
        [button setOnClick:^(SSHelpButton * _Nonnull sender) {
            [self_weak_ p_clickRightButton:sender];
        }];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
