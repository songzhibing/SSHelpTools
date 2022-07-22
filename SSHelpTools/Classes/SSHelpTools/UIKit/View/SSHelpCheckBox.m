//
//  SSHelpCheckBox.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/7/21.
//

#import "SSHelpCheckBox.h"
#import "SSHelpDefines.h"

@implementation SSHelpCheckBoxItem

+ (instancetype)itemWithTitle:(NSString *)title
{
    SSHelpCheckBoxItem *item = [[SSHelpCheckBoxItem alloc] init];
    item.title = title;
    return item;
}

+ (instancetype)itemWithTitle:(NSString *)title data:(id)data
{
    SSHelpCheckBoxItem *item = [[SSHelpCheckBoxItem alloc] init];
    item.title = title;
    item.data = data;
    return item;
}

@end

@interface SSHelpCheckBoxContainerView : SSHelpView
@property(nonatomic, weak) SSHelpCheckBox *checkbox;
@property(nonatomic, strong) CAShapeLayer *popLayer;
@end

@implementation SSHelpCheckBoxContainerView

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)layoutSubviews
{
    if (!_popLayer) {
        [self setupCustomLayer:self.bounds];
    }
}

- (void)setCheckbox:(SSHelpCheckBox *)checkbox
{
    _checkbox = checkbox;
}

- (void)setupCustomLayer:(CGRect)frame
{
    _popLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_popLayer];
    
    float apexOfTriangleX = self.ss_width*0.3f;
    
    CGFloat borderRadius = 0;//_style.containerCornerRadius;
    
    // Triangle must between left corner and right corner
    if (apexOfTriangleX > frame.size.width - borderRadius) {
        apexOfTriangleX = frame.size.width - borderRadius - 0.5 * 10;// self.checkbox.triangleWidth;
    }else if (apexOfTriangleX < borderRadius) {
        apexOfTriangleX = borderRadius + 0.5 * _checkbox.triangleWidth;
    }
    
    
    //默认小三角在上
    CGPoint point0 = CGPointMake(apexOfTriangleX, 0);
    CGPoint point1 = CGPointMake(apexOfTriangleX - 0.5 * self.checkbox.triangleWidth, self.checkbox.triangleHeight);
    CGPoint point2 = CGPointMake(borderRadius, self.checkbox.triangleHeight);
    CGPoint point2_center = CGPointMake(borderRadius, self.checkbox.triangleHeight + borderRadius);
    
    CGPoint point3 = CGPointMake(0, frame.size.height - self.checkbox.containerCornerRadius);
    CGPoint point3_center = CGPointMake(borderRadius, frame.size.height - borderRadius);
    
    CGPoint point4 = CGPointMake(frame.size.width - borderRadius, frame.size.height);
    CGPoint point4_center = CGPointMake(frame.size.width - borderRadius, frame.size.height - borderRadius);
    
    CGPoint point5 = CGPointMake(frame.size.width, self.checkbox.triangleHeight + borderRadius);
    CGPoint point5_center = CGPointMake(frame.size.width - borderRadius, self.checkbox.triangleHeight + borderRadius);
    
    CGPoint point6 = CGPointMake(apexOfTriangleX + 0.5 * self.checkbox.triangleWidth, self.checkbox.triangleHeight);
    
    if (SSHelpCheckBoxPositionAlwaysUp == self.checkbox.position) {
        //三角形在下
        CGFloat maxY = CGRectGetHeight(frame);

        point0 = CGPointMake(apexOfTriangleX, maxY);
        point1 = CGPointMake(apexOfTriangleX - 0.5 * self.checkbox.triangleWidth, maxY - self.checkbox.triangleHeight);

        point2 = CGPointMake(borderRadius, maxY - self.checkbox.triangleHeight);
        point2_center = CGPointMake(borderRadius, maxY - (self.checkbox.triangleHeight + borderRadius));

        point3 = CGPointMake(0, maxY - (frame.size.height - borderRadius));
        point3_center = CGPointMake(borderRadius, maxY - (frame.size.height - borderRadius));

        point4 = CGPointMake(frame.size.width - borderRadius, maxY - frame.size.height);
        point4_center = CGPointMake(frame.size.width - borderRadius, maxY - (frame.size.height - borderRadius));

        point5 = CGPointMake(frame.size.width, maxY - (self.checkbox.triangleHeight + borderRadius));
        point5_center = CGPointMake(frame.size.width - borderRadius, maxY - (self.checkbox.triangleHeight + borderRadius));

        point6 = CGPointMake(apexOfTriangleX + 0.5 * self.checkbox.triangleWidth, maxY - self.checkbox.triangleHeight);
    }
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:point0];
    [path addLineToPoint:point1];
    [path addLineToPoint:point2];

    BOOL isPositionDown = SSHelpCheckBoxPositionAlwaysUp == self.checkbox.position;
    if (isPositionDown) {
        [path addArcWithCenter:point2_center radius:borderRadius startAngle:3*M_PI_2 endAngle:M_PI clockwise:NO];
    } else {
        [path addArcWithCenter:point2_center radius:borderRadius startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    }
    [path addLineToPoint:point3];
    if (isPositionDown) {
        [path addArcWithCenter:point3_center radius:borderRadius startAngle:M_PI endAngle:M_PI_2 clockwise:NO];
    } else {
        [path addArcWithCenter:point3_center radius:borderRadius startAngle:M_PI endAngle:3*M_PI_2 clockwise:YES];
    }

    [path addLineToPoint:point4];
    if (isPositionDown) {
        [path addArcWithCenter:point4_center radius:borderRadius startAngle:M_PI_2 endAngle:0 clockwise:NO];
    } else {
        [path addArcWithCenter:point4_center radius:borderRadius startAngle:3*M_PI_2 endAngle:0 clockwise:YES];
    }

    [path addLineToPoint:point5];
    if (isPositionDown) {
        [path addArcWithCenter:point5_center radius:borderRadius startAngle:0 endAngle:3*M_PI_2 clockwise:NO];
    } else {
        [path addArcWithCenter:point5_center radius:borderRadius startAngle:0 endAngle:M_PI_2 clockwise:YES];
    }

    [path addLineToPoint:point6];
    [path closePath];
        
    self.popLayer.path = path.CGPath;
    self.popLayer.fillColor = self.checkbox.containerBackgroudColor.CGColor;
        
    if (self.checkbox.containerBorderWidth > 0.4) {
        self.popLayer.lineWidth = self.checkbox.containerBorderWidth;
        self.popLayer.strokeColor = self.checkbox.containerBorderColor.CGColor;
    } else {
        self.popLayer.borderWidth = 0;
    }
    
    //阴影
    if (self.checkbox.shadowColor) {
        self.popLayer.shadowPath = path.CGPath;
        self.popLayer.shadowOffset = CGSizeMake(0, 3);
        self.popLayer.shadowOpacity = 0.75;
        self.popLayer.shadowColor = self.checkbox.shadowColor.CGColor;
    }
}

@end



@interface SSHelpCheckBox()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong) SSHelpView *floatView;
@property(nonatomic, strong) SSHelpButton *titleButton;
@property(nonatomic, strong) UIImageView *arrowMark;    // 尖头图标
@property(nonatomic, strong) SSHelpButton *backView;
@property(nonatomic, strong) SSHelpCheckBoxContainerView *containerView;
@property(nonatomic, strong) UITableView *optionsTable;  // 下拉列表
@end

@implementation SSHelpCheckBox

- (void)dealloc
{
    
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initProperties];
        [self initContentViews];
    }
    return self;
}

- (void)initProperties
{
    _position               = SSHelpCheckBoxPositionAlwaysDown;
    _title                  = @"Please Select";
    _titleBgColor           = [UIColor whiteColor];
    _titleFont              = [UIFont boldSystemFontOfSize:15];
    _titleColor             = [UIColor blackColor];
    _titleAlignment         = NSTextAlignmentCenter;
    _titleEdgeInsets        = UIEdgeInsetsMake(0, 10, 0, 10);

    _triangleHeight = 8.0;
    _triangleWidth = 10.0;
    _roundMargin = 10.0;
    _showSpace = 5.f;
    _containerBorderWidth = 0.5f;
    _containerBorderColor = _kColorFromHexRGB(@"#666666");
    _shadowColor = _kColorFromHexRGB(@"#666666");
    _containerBackgroudColor = _kColorFromHexRGB(@"#eeeeee");
    _containerCornerRadius = 5.0;

    
    _rotateIcon             = nil;
    _rotateIconSize         = CGSizeMake(15, 15);
    _rotateIconMarginRight  = 7.5;
    _rotateIconTint         = [UIColor blackColor];

    _optionItemHeight       = 44;
    _optionBgColor          = [UIColor colorWithRed:64/255.f green:151/255.f blue:255/255.f alpha:0.5];
    _optionFont             = [UIFont systemFontOfSize:13];
    _optionTextColor        = [UIColor blackColor];
    _optionTextAlignment    = NSTextAlignmentCenter;
    _optionTextMarginLeft   = 15;
    _optionNumberOfLines    = 0;
    _optionIconSize         = CGSizeMake(0, 0);
    _optionIconMarginRight  = 15;
    _optionLineColor        = [UIColor whiteColor];
    _optionLineHeight       = 0.5f;
    _optionMaxRow           = 5;
    _animateTime            = 0.25f;

    _optionsListLimitHeight = 0;
}

- (void)initContentViews
{
    self.floatView = [[SSHelpView alloc] initWithFrame:self.bounds];
    self.floatView.userInteractionEnabled = YES;
    self.floatView.backgroundColor = _kRandomColor;
    [self addSubview:self.floatView];
    
    // 主按钮 显示在界面上的点击按钮
    self.titleButton = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    self.titleButton.frame = self.floatView.bounds;
    self.titleButton.normalTitle = self.title;
    self.titleButton.normalTitleColor = self.titleColor;
    self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    self.titleButton.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.titleButton  addTarget:self action:@selector(showOptionBox) forControlEvents:UIControlEventTouchUpInside];
    [self.floatView addSubview:self.titleButton];
    
    // 旋转箭头
    self.arrowMark = [[UIImageView alloc] init];
    [self.arrowMark setTintColor:self.rotateIconTint];
    [self.floatView addSubview:self.arrowMark];
}

- (void)showOptionBox
{
    CGRect bounds = self.window.bounds;
    
    CGFloat containerHeight = self.showSpace+self.triangleHeight+MIN(self.optionMaxRow, self.dataSouce.count)*self.optionItemHeight;
    CGFloat containerWidth = self.ss_width;
    
    CGPoint topCenterPoint = [self convertPoint:CGPointMake(self.ss_width/2.0f, 0)  toView:self.window];
    CGPoint bottomCenterPoint = [self convertPoint:CGPointMake(self.ss_width/2.0f, self.ss_height) toView:self.window];

    //默认优先居下展示
    CGRect computeFrame = CGRectMake(bottomCenterPoint.x-containerWidth/2.0f,
                                     bottomCenterPoint.y, containerWidth, containerHeight);
    if (computeFrame.origin.x<10) {
        //左边超了（最少空10）
        computeFrame.origin.x = 10;//最少空10
        self.triangleStyle = SSHelpCheckBoxTriangleStyleLeft; //手动重置三角居左
    }
    if (computeFrame.origin.x+computeFrame.size.width+10>bounds.size.width) {
        //右边超了
        computeFrame.origin.x = bounds.size.width-containerWidth-10; //最少空10
        self.triangleStyle = SSHelpCheckBoxTriangleStyleRight; //手动重置三角居右
    }
    //左右超出调整好后，若还超出，则尺寸不规范。
    
    if (computeFrame.origin.y+computeFrame.size.height>bounds.size.height) {
        //底部超了
        computeFrame.origin.y = topCenterPoint.y-containerHeight; //居上
        self.position = SSHelpCheckBoxPositionAlwaysUp; //手动重置
    }
    
    if (SSHelpCheckBoxPositionAlwaysUp == self.position ) {
        //居上展示
        computeFrame = CGRectMake(bottomCenterPoint.x-containerWidth/2.0f,
                                  topCenterPoint.y-containerHeight, containerWidth, containerHeight);
    
        if (computeFrame.origin.y+computeFrame.size.height>bounds.size.height) {
            //顶部超了
            computeFrame.origin.y = bottomCenterPoint.y; //居下
            self.position = SSHelpCheckBoxPositionAlwaysDown; //手动重置
        }
        //上下超出调整好后，若还超出，则尺寸不规范。
    }
    
    self.optionsTable = [[UITableView alloc] initWithFrame:computeFrame];
    self.optionsTable.delegate       = self;
    self.optionsTable.dataSource     = self;
    self.optionsTable.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.optionsTable.scrollEnabled  = NO;
    self.optionsTable.backgroundColor = [UIColor orangeColor];
    
    self.containerView = [[SSHelpCheckBoxContainerView alloc] initWithFrame:computeFrame];
    self.containerView.userInteractionEnabled = YES;
    self.containerView.checkbox = self;
//    self.containerView.backgroundColor = [UIColor clearColor];
    
    [self.containerView setNeedsLayout];
    [self.containerView layoutIfNeeded];

    [self.containerView addSubview:self.optionsTable];

    self.backView = [SSHelpButton buttonWithType:UIButtonTypeCustom];
    self.backView.frame = bounds;
    self.backView.backgroundColor = [UIColor grayColor];
    [self.window addSubview:self.backView];
    @Tweakify(self);
    [self.backView ss_addTouchUpInsideBlock:^(id  _Nonnull sender) {
        [self_weak_.containerView removeFromSuperview];
        [self_weak_.backView removeFromSuperview];
    }];
    
    
    [self.window addSubview:self.containerView];
    
    if (SSHelpCheckBoxPositionAlwaysUp == self.position) {
        
    } else {
        [self.optionsTable mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(UIEdgeInsetsMake(_triangleHeight+5,
                                                    _containerBorderWidth+5,
                                                    _containerBorderWidth+5,
                                                    _containerBorderWidth+5));
        }];
    }

}

- (void)hideDropDown
{
    
}

#pragma mark -
#pragma mark - Setter Method

- (void)setTitle:(NSString *)title
{
    _title = title;
    self.titleButton.normalTitle = title;
}

- (void)setTitleBgColor:(UIColor *)titleBgColor
{
    _titleBgColor = titleBgColor;
    self.titleButton.backgroundColor  = titleBgColor;
}

- (void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    self.titleButton.titleLabel.font = titleFont;
}

- (void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    self.titleButton.normalTitleColor = titleColor;
}

- (void)setTitleAlignment:(NSTextAlignment)titleAlignment
{
    _titleAlignment = titleAlignment;
    if (titleAlignment == NSTextAlignmentLeft) {
        self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    } else if (titleAlignment == NSTextAlignmentCenter) {
        self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    } else if (titleAlignment == NSTextAlignmentRight) {
        self.titleButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
}

- (void)setTitleEdgeInsets:(UIEdgeInsets)titleEdgeInsets
{
    _titleEdgeInsets = titleEdgeInsets;
    self.titleButton.titleEdgeInsets = titleEdgeInsets;
}

#pragma mark
#pragma mark - <UITableViewDelegate, UITableViewDataSource>

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSouce.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"SSHelpCheckBoxTableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    cell.contentView.backgroundColor = _kRandomColor;
//    NSString *text;
//    NSString *icon;
//    if (self.titleMenus.count) {
//        text = self.titleMenus[indexPath.row];
//    }
//
//    if (self.titleInfoes.count) {
//        NSDictionary *dic = self.titleInfoes[indexPath.row];
//        text = dic[@"name"];
//        icon = dic[@"icon"];
//    }
//
//    cell.textLabel.text = text;
//    cell.textLabel.textColor = self.style.textColor;
//    cell.textLabel.font = self.style.font;
//    cell.textLabel.textAlignment = self.style.textAlignment;
//    if (icon.length) {
//        cell.imageView.image = [UIImage imageNamed:icon];
//    }
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
