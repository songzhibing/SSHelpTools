//
//  SSHelpTextView.h
//  Pods
//
//  Created by 宋直兵 on 2023/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^_Nullable SSTextViewInteraction)(UITextView *textView,
                                               NSURL * _Nullable URL,
                                               NSRange characterRange,
                                               UITextItemInteraction interaction);

typedef NS_OPTIONS(NSInteger, SSUnderlineStyle) {
    SSUnderlineStyleLetterPaper = 0x0500,  // 信纸纹理样式
};

@interface SSHelpTextView : UITextView

+ (instancetype)ss_new;

@property(nonatomic, strong) NSMutableDictionary <NSAttributedStringKey, id> *backgroundAttrs;

@property(nonatomic, strong) SSTextViewInteraction interaction;

- (void)appendImage:(UIImage *)image;

- (void)appendImage:(UIImage *)image linkURL:(NSURL* _Nullable)URL;

@end

NS_ASSUME_NONNULL_END
