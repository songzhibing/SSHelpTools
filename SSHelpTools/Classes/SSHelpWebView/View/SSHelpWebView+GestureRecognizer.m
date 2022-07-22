//
//  SSHelpWebView+GestureRecognizer.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/5/31.
//

#import "SSHelpWebView+GestureRecognizer.h"
#import <objc/runtime.h>
#import <SafariServices/SafariServices.h>
#import <SSHelpTools/SSHelpPhotoManager.h>

@interface SSHelpWebView (GestureRecognizer)<UIGestureRecognizerDelegate>

@property(nonatomic, weak) WKWebView *wkwebView;

@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;

@end

@implementation SSHelpWebView (GestureRecognizer)

- (WKWebView *)wkwebView
{
    return objc_getAssociatedObject(self,_cmd);
}

- (void)setWkwebView:(WKWebView *)wkwebView
{
    objc_setAssociatedObject(self,@selector(wkwebView),wkwebView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UILongPressGestureRecognizer *)longPressGesture
{
    return objc_getAssociatedObject(self, _cmd);;
}

- (void)setLongPressGesture:(UILongPressGestureRecognizer *)longPressGesture
{
    objc_setAssociatedObject(self,@selector(longPressGesture),longPressGesture, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (void)addLongPressGestureRecognizer:(WKWebView *)webview
{
    UILongPressGestureRecognizer *_longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureRecognizer:)];
    _longPressGesture.delegate = self;
    [webview addGestureRecognizer:_longPressGesture];
    self.longPressGesture = _longPressGesture;
    self.wkwebView  = webview;
}

#pragma mark - UIGestureRecognizerDelegate Method

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

#pragma mark - Private Method

- (void)handleLongPressGestureRecognizer:(UILongPressGestureRecognizer *)gesture
{
    if (gesture != self.longPressGesture) {
        return;
    }
    
    if (!self.wkwebView) {
        return;
    }
    
    if (!self.ss_viewController) {
        return;
    }
    
    if (gesture.state == UIGestureRecognizerStateBegan) {
        SSWebLog(@"0. 开始长按手势");
        CGPoint point = [gesture locationInView:self.wkwebView];
        if (point.x == NSNotFound || point.y == NSNotFound) {
            return;
        }

        __weak typeof(self) __weak_self = self;
        
        __block NSURL *qrcodeUrl = nil;
        __block NSString *imgSrc = nil;
        __block NSString *title = nil;
        __block NSString *href = nil;

        dispatch_queue_t queue = dispatch_get_main_queue();
        dispatch_group_t group = dispatch_group_create();
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            NSString *result = [self detectQRCodeUrlFromWebView:self.wkwebView];
            if (result && [result hasPrefix:@"http"]) {
                qrcodeUrl = [NSURL URLWithString:result];
            }
            dispatch_group_leave(group);
        });
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self webView:self.wkwebView srcFromPoint:point callBack:^(id  _Nullable src, NSError * _Nullable error) {
                imgSrc = src;
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self webView:self.wkwebView titleFromPoint:point callBack:^(id  _Nullable text, NSError * _Nullable error) {
                title = text;
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self webView:self.wkwebView hrefFromPoint:point callBack:^(id  _Nullable text, NSError * _Nullable error) {
                href = text;
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self webView:self.wkwebView tagNameFromPoint:point callBack:^(id  _Nullable tagName, NSError * _Nullable error) {
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_enter(group);
        dispatch_group_async(group, queue, ^{
            [self webView:self.wkwebView imgSrcArrayFromPoint:point callBack:^(id  _Nullable srces, NSError * _Nullable error) {
                dispatch_group_leave(group);
            }];
        });
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSMutableArray <UIAlertAction *> *actionArray = [[NSMutableArray alloc] initWithCapacity:1];
            if (qrcodeUrl) {
                UIAlertAction *action = [self action:@"识别二维码" handler:^(UIAlertAction *action) {
                    SFSafariViewController *vc = [[SFSafariViewController alloc] initWithURL:qrcodeUrl];
                    [self.ss_viewController presentViewController:vc animated:YES completion:nil];
                }];
                [actionArray addObject:action];
            }
            
            if (imgSrc) {
                UIAlertAction *action = [self action:@"保存图片" handler:^(UIAlertAction *action) {
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:imgSrc]]];
                    if (image) {
                        [SSHelpPhotoManager saveImage:image completionHandler:^(BOOL success, NSError * _Nullable error) {
                            if (success) {
                                [__weak_self showToast:@"保存成功"];
                            } else if (error) {
                                [__weak_self showToast:error.localizedDescription];
                            }
                        }];
                    } else {
                        //加载图片失败
                        [__weak_self showToast:@"加载图片资源失败."];
                    }
                }];
                [actionArray addObject:action];
            }
            
            if (title) {
                UIAlertAction *action = [self action:@"复制链接文字" handler:^(UIAlertAction *action) {
                    [UIPasteboard generalPasteboard].string = title;
                }];
                [actionArray addObject:action];
            }
            
            if (href) {
                UIAlertAction *action = [self action:@"复制链接地址" handler:^(UIAlertAction *action) {
                    [UIPasteboard generalPasteboard].string = href;
                }];
                [actionArray addObject:action];
            }
            
            // 取消
            UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            }];
            [actionArray addObject:cancel];
            
            if (actionArray.count>1) {
                // 弹框
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
                for (NSInteger index=0; index<actionArray.count; index++) {
                    [alert addAction:actionArray[index]];
                }
                [self.ss_viewController presentViewController:alert animated:YES completion:nil];
            }
        });
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        SSWebLog(@"2. 结束长按手势");
    } else if (gesture.state == UIGestureRecognizerStateChanged) {
        SSWebLog(@"3. 长按手势改变");
    }
}

- (UIAlertAction *)action:(NSString *)title handler:(void (^ __nullable)(UIAlertAction *action))handler
{
    UIAlertAction *action = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:handler];
    return action;
}

/// 抓取WebView上某一点类型tag
- (void)webView:(WKWebView *)webView tagNameFromPoint:(CGPoint )point callBack:(void (^)(id _Nullable tagName, NSError * _Nullable error) )callback
{
    NSString *typeJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", point.x, point.y];
    [webView evaluateJavaScript:typeJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        callback ? callback(result,error) : NULL;
    }];
}

/// 抓取WebView上某一点标题
- (void)webView:(WKWebView *)webView titleFromPoint:(CGPoint )point callBack:(void(^)(id _Nullable title, NSError * _Nullable error))callback
{
    NSString *titleJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).innerText",point.x, point.y];
    [webView evaluateJavaScript:titleJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        callback ? callback(result,error) : NULL;
    }];
}

/// 抓取WebView上某一点来源src
- (void)webView:(WKWebView *)webView srcFromPoint:(CGPoint )point callBack:(void(^)(id _Nullable src, NSError * _Nullable error))callback
{
    //识别、抓取html元素，获取长按位置对应的图片url的JS代码
    NSString *imgJS = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", point.x, point.y];
    [webView evaluateJavaScript:imgJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        callback ? callback(result,error) : NULL;
    }];
}

/// 抓取WebView上某一点链接
- (void)webView:(WKWebView *)webView hrefFromPoint:(CGPoint )point callBack:(void(^)(id _Nullable href, NSError * _Nullable error))callback
{
    //注入JS方法
    NSString *hrefJS = @"function DynamicJSSearchHref(x,y) {\
                            var e = document.elementFromPoint(x, y);\
                            while(e){\
                                if(e.href){\
                                return e.href;\
                            }\
                            e = e.parentElement;\
                            }\
                            return e.href;\
                      }";
    [webView evaluateJavaScript:hrefJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            callback ? callback(nil,error) : NULL;
        } else {
            //调用JS方法
            NSString *hrefFunc = [NSString stringWithFormat:@"DynamicJSSearchHref(%f,%f);",point.x,point.y];
            [webView evaluateJavaScript:hrefFunc completionHandler:^(id _Nullable href, NSError * _Nullable error){
                callback ? callback(result,error) : NULL;
            }];
        }
    }];
}

/// 抓取WebView上所有图片URL
- (void)webView:(WKWebView *)webView imgSrcArrayFromPoint:(CGPoint )point callBack:(void(^)(id _Nullable srces, NSError * _Nullable error))callback
{
    NSString *hrefJS = @"function tmpDynamicSearchAllImage(){"
                        "var img = [];"
                        "for(var i=0;i<$(\"img\").length;i++){"
                            "if(parseInt($(\"img\").eq(i).css(\"width\"))> 60){ "//获取所有符合放大要求的图片，将图片路径(src)获取
                               //" img[i] = $(\"img\").eq(i).attr(\"src\");"
                                "img[i] = $(\"img\").eq(i).prop(\"src\");"
                           " }"
                        "}"
                        "var img_info = {};"
                        "img_info.list = img;" //保存所有图片的url
                        "return img;"
                    "}";
    [webView evaluateJavaScript:hrefJS completionHandler:^(id _Nullable result, NSError * _Nullable error) {
        if (error) {
            callback ? callback(nil,error) : NULL;
        } else {
            [webView evaluateJavaScript:@"tmpDynamicSearchAllImage()" completionHandler:^(id _Nullable array, NSError * _Nullable error){
                if (error) {
                    callback ? callback(nil,error) :NULL;
                } else {
                    NSMutableArray *imageArray = [NSMutableArray array];
                    if (array) {
                        for (NSString *urlString in array) {
                            
                            if (!urlString || [urlString isEqual:[NSNull null]] || [urlString isKindOfClass:[NSNull class]] ) continue ;
                            NSString *lowString = urlString.lowercaseString;
                            if ([lowString hasPrefix:@"http"]
                                &&([lowString.lowercaseString containsString:@".jpg"] ||
                                   [lowString.lowercaseString containsString:@".jpeg"]||
                                   [lowString.lowercaseString containsString:@".png"] ||
                                   [lowString.lowercaseString containsString:@".gif"])) {
                                
                                [imageArray addObject:urlString];
                            }
                        }
                    }
                    callback ? callback(imageArray,nil) :NULL;
                }
             }];
        }
    }];
}

/// 当前屏幕中的目标webview读取二维码
/// @param webView 目标
- (NSString * _Nullable)detectQRCodeUrlFromWebView:(WKWebView *)webView
{
    //截图 再读取
    UIGraphicsBeginImageContextWithOptions(webView.superview.bounds.size, YES, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [webView.superview.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    CIImage *ciImage = [[CIImage alloc] initWithCGImage:image.CGImage options:nil];
    //渲染
    CIContext *ciContext = [CIContext contextWithOptions:@{kCIContextUseSoftwareRenderer : @(YES)}];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:ciContext options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];// 二维码识别
    NSArray *features = [detector featuresInImage:ciImage];
    for (CIQRCodeFeature *feature in features) {
        if (feature.messageString) {
            return feature.messageString;
        }
    }
    return nil;
}

@end
