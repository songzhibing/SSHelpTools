//
//  SSHelpTextView.m
//  Pods
//
//  Created by 宋直兵 on 2023/8/22.
//

#import "SSHelpTextView.h"
#import "UIView+SSHelp.h"
#import "SSHelpDefines.h"
#import <Masonry/Masonry.h>

@interface SSHelpTextView () <UITextViewDelegate, NSTextStorageDelegate, NSLayoutManagerDelegate>
@property(nonatomic, strong) UIView *backgroundView;
@property(nonatomic, assign) NSInteger underlineStyle;
@end


@implementation SSHelpTextView

#pragma mark -
#pragma mark - Public Method

+ (instancetype)ss_new
{
    SSHelpTextView *textView = [[[self class] alloc] init];
    textView.delegate = textView;
    textView.textStorage.delegate = textView;
    textView.layoutManager.delegate = textView;
    return textView;
}

- (void)appendImage:(UIImage *)image
{
    [self appendImage:image linkURL:nil];
}

- (void)appendImage:(UIImage *)image linkURL:(NSURL* _Nullable)URL
{
    //NSData *imageData = UIImageJPEGRepresentation(image, 0.8f);
    NSTextAttachment *att = [[NSTextAttachment alloc] init];
    att.bounds = CGRectMake(0, 0, 200, 200);
    att.image = image;
    NSMutableAttributedString *string = [NSAttributedString attributedStringWithAttachment:att].mutableCopy;
    if (URL) {
        [string addAttributes:@{NSLinkAttributeName:URL} range:NSMakeRange(0, string.length)];
    }
    [self.textStorage appendAttributedString:string];
}

#pragma mark -
#pragma mark - System Method

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self refreshBackgroundView];
}

#pragma mark -
#pragma mark - Private Method

- (void)refreshBackgroundView
{
    if (SSUnderlineStyleLetterPaper == self.underlineStyle) {
        if (!self.backgroundView) {
            self.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            [self insertSubview:self.backgroundView atIndex:0];
        }
        self.backgroundView.hidden = NO;
        
        CGFloat maxHeight = MAX(self.ss_height, self.contentSize.height);
        CGFloat originX = self.textContainerInset.left + self.textContainer.lineFragmentPadding;
        CGFloat originY = self.textContainerInset.top;
        CGFloat width = self.ss_width - originX - (self.textContainerInset.right + self.textContainer.lineFragmentPadding);
        CGRect newRect = CGRectMake(originX, originY, width, maxHeight);
        if (!CGRectEqualToRect(newRect, self.backgroundView.frame)) {
            self.backgroundView.frame = CGRectMake(originX, originY, width, maxHeight);
            // 1.生成一张以后用于平铺的小图片
            NSMutableParagraphStyle *style = self.backgroundAttrs[NSParagraphStyleAttributeName];
            CGFloat rowHeight = style.minimumLineHeight+style.lineSpacing;
            CGSize size = CGSizeMake(self.ss_width, rowHeight);
            UIGraphicsBeginImageContextWithOptions(size , NO, 0);
            // 2.画矩形
            CGContextRef ctx = UIGraphicsGetCurrentContext();
            //CGContextAddRect(ctx, CGRectMake(0, 0, rect.size.width, 28));
            //[UIColor.redColor set];
            //CGContextFillPath(ctx);
            // 3.画线条
            CGFloat lineHeight = 1;
            CGFloat lineY = rowHeight - lineHeight;
            CGFloat lineX = 0;
            // 设置虚线的宽度
            CGContextSetLineWidth(ctx, 2.0);
            // 设置虚线的样式
            CGFloat dash[] = {2, 2};
            CGContextSetLineDash(ctx, 0, dash, 2);
            CGContextMoveToPoint(ctx, lineX, lineY);
            CGContextAddLineToPoint(ctx, self.ss_width, lineY);
            [[UIColor systemGrayColor] set];
            CGContextStrokePath(ctx);
            UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:image];
        }
    } else {
        if (self.backgroundView) {
            self.backgroundView.hidden = YES;
        }
    }
}

#pragma mark -
#pragma mark - UITextViewDelegate Method

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{

}

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0))
{
    if (self.interaction) {
        self.interaction(textView, URL, characterRange, interaction);
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)textView:(UITextView *)textView shouldInteractWithTextAttachment:(NSTextAttachment *)textAttachment inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction API_AVAILABLE(ios(10.0))
{
    if (self.interaction) {
        /*
        [textView.attributedText enumerateAttributesInRange:NSMakeRange(0, 10) options:0 usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
            //
        }];
         */
        NSDictionary *attributed = [textView.attributedText attributesAtIndex:characterRange.location longestEffectiveRange:nil inRange:characterRange];
        NSURL *URL = attributed[NSLinkAttributeName];
        self.interaction(textView, URL, characterRange, interaction);
        return YES;
    } else {
        return NO;
    }
}


#pragma mark -
#pragma mark - NSTextStorageDelegate Method

// Sent inside -processEditing right before fixing attributes.  Delegates can change the characters or attributes.
- (void)textStorage:(NSTextStorage *)textStorage willProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta API_AVAILABLE(macos(10.11), ios(7.0))
{
//     SSLifeCycleLog(@"textStorage:willProcessEditing:range(%ld,%ld):changeInLength(%ld) ... ",editedRange.location,editedRange.length,delta);
}

// Sent inside -processEditing right before notifying layout managers.  Delegates can change the attributes.
- (void)textStorage:(NSTextStorage *)textStorage didProcessEditing:(NSTextStorageEditActions)editedMask range:(NSRange)editedRange changeInLength:(NSInteger)delta API_AVAILABLE(macos(10.11), ios(7.0))
{
    // SSLifeCycleLog(@"textStorage:didProcessEditing:range(%ld,%ld):changeInLength(%ld) ... textStorage.length(%ld) ... ",editedRange.location,editedRange.length,delta,textStorage.length);
    // SSLifeCycleLog(@"textStorage:didProcessEditing ... ");
    
    @Tweakify(self);
    [textStorage enumerateAttributesInRange:NSMakeRange(0, textStorage.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary<NSAttributedStringKey,id> * _Nonnull attrs, NSRange range, BOOL * _Nonnull stop) {
        NSTextAttachment *attachment = attrs[NSAttachmentAttributeName];
        if (attachment && [attachment isKindOfClass:NSTextAttachment.class]) {
            SSLog(@"加载附件:%@",attachment.image);
            // 是附件
            // NSAttributedString *string = [NSAttributedString attributedStringWithAttachment:attachment];
            // 同一位置重新格式化显示
            // [textStorage replaceCharactersInRange:range withAttributedString:string];
        } else {
            SSLog(@"加载字符:%@",[textStorage attributedSubstringFromRange:range]);
            // 是字符串
            if (SSUnderlineStyleLetterPaper == self_weak_.underlineStyle) {
                // 如果背景线条是’信封‘样式，则所有文字统一格式
                NSAttributedString *string = [textStorage attributedSubstringFromRange:range];
                if (string) {
                    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithAttributedString:string];
                    // 使用统一格式
                    [attributedString setAttributes:self_weak_.backgroundAttrs
                                              range:NSMakeRange(0, string.length)];
                    [textStorage replaceCharactersInRange:range withAttributedString:attributedString];
                    // 上述替换后，在iOS13.3上，发现并不会立即生效
                    // [textStorage invalidateAttributesInRange:range];
                }
            }
        }
    }];
}

#pragma mark -
#pragma mark - NSLayoutManagerDelegate Method

// This is sent whenever layout or glyphs become invalidated in a layout manager which previously had all layout complete.
- (void)layoutManagerDidInvalidateLayout:(NSLayoutManager *)sender API_AVAILABLE(macos(10.0), ios(7.0))
{
    
}

// This is sent whenever a container has been filled.  This method can be useful for paginating.  The textContainer might be nil if we have completed all layout and not all of it fit into the existing containers.  The atEnd flag indicates whether all layout is complete.
- (void)layoutManager:(NSLayoutManager *)layoutManager didCompleteLayoutForTextContainer:(nullable NSTextContainer *)textContainer atEnd:(BOOL)layoutFinishedFlag API_AVAILABLE(macos(10.0), ios(7.0))
{
    
}

// This is sent right before layoutManager invalidates the layout due to textContainer changing geometry.  The receiver of this method can react to the geometry change and perform adjustments such as recreating the exclusion path.
- (void)layoutManager:(NSLayoutManager *)layoutManager textContainer:(NSTextContainer *)textContainer didChangeGeometryFromSize:(CGSize)oldSize API_AVAILABLE(macos(10.11), ios(7.0))
{
    
}


#pragma mark
#pragma mark - Lazy load Method

- (NSInteger)underlineStyle
{
    NSNumber *style = self.backgroundAttrs[NSUnderlineStyleAttributeName];
    if (style) {
        return style.integerValue;
    }
    return NSNotFound;
}

- (NSMutableDictionary <NSAttributedStringKey,id> *)backgroundAttrs
{
    if (!_backgroundAttrs) {
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.minimumLineHeight = 26; // 设置最小行高
        style.maximumLineHeight = 26; // 设置最大行高
        _backgroundAttrs = @{
            NSFontAttributeName:[UIFont systemFontOfSize:17.0f],
            NSForegroundColorAttributeName:UIColor.labelColor,
            //NSUnderlineStyleAttributeName: @(SSUnderlineStyleLetterPaper),//@(NSUnderlineStyleNone),
            NSUnderlineColorAttributeName:UIColor.tertiaryLabelColor,
            NSParagraphStyleAttributeName:style
        }.mutableCopy;
    }
    return _backgroundAttrs;
}

@end
