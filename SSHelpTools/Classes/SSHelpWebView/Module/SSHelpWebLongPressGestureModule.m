//
//  SSHelpWebLongPressGestureModule.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2023/10/20.
//

#import "SSHelpWebLongPressGestureModule.h"
//#import <SSHelpTools/UIImSSSharedInstanceWithBlockage+SSHelp.h>
//#import <SSHelpTools/SSHelpPhotoManager.h>

@interface SSHelpWebLongPressGestureModule()<UIGestureRecognizerDelegate>
@property(nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@end


@implementation SSHelpWebLongPressGestureModule

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

/// 长按识别手势设置
- (void)setSupportLongPressGestureRecognizer:(BOOL)supportLongPressGestureRecognizer
{
//    if (supportLongPressGestureRecognizer) {
//        if (_longPressGesture) return;
//        _longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerHandler:)];
//        _longPressGesture.delegate = self;
//        _longPressGesture.name = @"SSHelpWebView.LongPressGesture.identifier";
//        [self addGestureRecognizer:_longPressGesture];
//    } else {
//        if (_longPressGesture) {
//            [self removeGestureRecognizer:_longPressGesture];
//            _longPressGesture = nil;
//        }
//    }
}

///// 长按识别手势
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
//{
//    return YES;
//}
//
///// 长按识别手势
//- (void)gestureRecognizerHandler:(UIGestureRecognizer *)gestureRecognizer
//{
//    @weakify(self);
//    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
//    {
//        CGPoint point = [gestureRecognizer locationInView:self];
//        if (point.x == NSNotFound || point.y == NSNotFound) return;
//        if (_logEnable) {
//            SSLog(@"手势开始...(%lf,%lf)",point.x,point.y);
//        }
//
//#ifdef DEBUG
////        NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).style.color='red';", point.x, point.y];
////        [self evaluateJavaScript:js completionHandler:^(NSString *_Nullable url, NSError * _Nullable error) {
////
////        }];
//#endif
//        
//        dispatch_queue_t queue = dispatch_get_main_queue();
//        dispatch_group_t group = dispatch_group_create();
//        
//        NSString *toSaveImage    = @"保存图片";  //NSString *fcQRCode = @"识别二维码";
//        NSString *toBrowseImages = @"看图模式";
//        NSString *toCopyLinkText = @"复制链接文字";
//        NSString *toCopyHref     = @"复制链接地址";
//        NSArray  *toActionArray  = @[toSaveImage,toBrowseImages,toCopyLinkText,toCopyHref];
//        __block NSMutableArray <UIAlertAction *> *actionArray = [[NSMutableArray alloc] init];
//        
//        for (NSInteger index=0; index<toActionArray.count; index++)
//        {
//            NSString *actionItem = toActionArray[index];
//            dispatch_group_enter(group);
//            dispatch_group_async(group, queue, ^{
//                @strongify(self);
//                if ([actionItem isEqualToString:toSaveImage])
//                {
//                    //获取长按位置对应的图片url
//                    NSString *javaScript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", point.x, point.y];
//                    [self evaluateJavaScript:javaScript completionHandler:^(NSString *_Nullable url, NSError * _Nullable error) {
//                        if (self_weak_.logEnable) {
//                            SSLog(@"长按图片信息：%@ 错误信息:%@",url,error.localizedDescription);
//                        }
//                        if (url) {
//                            UIImage *image = [[UIImage alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
//                            if (image) {
//                                //只要是图片，则可保存图片
//                                UIAlertAction *action = [UIAlertAction actionWithTitle:@"保存图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                    [SSHelpPhotoManager saveImage:image completionHandler:^(BOOL success, NSError * _Nullable error) {
//                                        @strongify(self);
//                                        [self presentAlertViewControllerWithMessage:success?@"保存成功":@"保存失败"];
//                                    }];
//                                }];
//                                [actionArray addObject:action];
//                                
//                                //图片是二维码，则可进行识别
//                                [UIImage ss_featuresInImage:image callback:^(NSString * _Nullable result) {
//                                    if (result) {
//                                        UIAlertAction *action = [UIAlertAction actionWithTitle:@"识别二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                            //
//                                        }];
//                                        [actionArray addObject:action];
//                                    }
//                                    dispatch_group_leave(group);
//                                }];
//                                // 保证 dispatch_group_leave 对应
//                                return;
//                            }
//                        }
//                        dispatch_group_leave(group);
//                    }];
//                }
//                else if ([actionItem isEqualToString:toBrowseImages])
//                {
//                    //获取所有图片
//                    NSString *javaScript = @"function tmpDynamicSearchAllImage(){"
//                                        "var img = [];"
//                                        "for(var i=0;i<$(\"img\").length;i++){"
//                                            "if(parseInt($(\"img\").eq(i).css(\"width\"))> 60){ "//获取所有符合放大要求的图片，将图片路径(src)获取
//                                               //" img[i] = $(\"img\").eq(i).attr(\"src\");"
//                                                "img[i] = $(\"img\").eq(i).prop(\"src\");"
//                                           " }"
//                                        "}"
//                                        "var img_info = {};"
//                                        "img_info.list = img;" //保存所有图片的url
//                                        "return img;"
//                                    "}";
//                    [self evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//                        if (!error) {
//                            @strongify(self);
//                            [self evaluateJavaScript:@"tmpDynamicSearchAllImage()" completionHandler:^(id _Nullable array, NSError * _Nullable error){
//                                if (self_weak_.logEnable) {
//                                    SSLog(@"所有图片：%@",array);
//                                }
//                                dispatch_group_leave(group);
//                            }];
//                        } else {
//                            dispatch_group_leave(group);
//                        }
//                    }];
//                }
//                else if ([actionItem isEqualToString:toCopyLinkText])
//                {
//                    //复制链接文字
//                    NSString *javaScript = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).innerText",point.x, point.y];
//                    [self evaluateJavaScript:javaScript completionHandler:^(NSString *_Nullable text, NSError * _Nullable error) {
//                        if (self_weak_.logEnable) {
//                            SSLog(@"获取文字信息：%@ 错误信息:%@",text,error.localizedDescription);
//                        }
//                        if (text && text.length) {
//                            UIAlertAction *action = [UIAlertAction actionWithTitle:toCopyLinkText style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                [UIPasteboard generalPasteboard].string = text;
//                            }];
//                            [actionArray addObject:action];
//                        }
//                        dispatch_group_leave(group);
//                    }];
//                } else if ([actionItem isEqualToString:toCopyHref]) {
//                    //复制链接
//                    NSString *javaScript = @"function tmpDynamicJavaScriptSearchHref(x,y) {\
//                                                var e = document.elementFromPoint(x, y);\
//                                                while(e){\
//                                                    if(e.href){\
//                                                        return e.href;\
//                                                    }\
//                                                    e = e.parentElement;\
//                                                }\
//                                                return e.href;\
//                                            }";
//                    [self evaluateJavaScript:javaScript completionHandler:^(id _Nullable result, NSError * _Nullable error) {
//                        if (error) {
//                            if (self_weak_.logEnable) {
//                                SSLog(@"注入获取链接JavaScript失败:%@",error.localizedDescription);
//                            }
//                            dispatch_group_leave(group);
//                        } else {
//                            @strongify(self);
//                            NSString *javaScript = [NSString stringWithFormat:@"tmpDynamicJavaScriptSearchHref(%f,%f);",point.x,point.y];
//                            [self evaluateJavaScript:javaScript completionHandler:^(NSString *_Nullable href, NSError * _Nullable error){
//                                if (self_weak_.logEnable) {
//                                    SSLog(@"获取链接信息：%@ 错误信息:%@",result,error.localizedDescription);
//                                }
//                                if (href && href.length) {
//                                    UIAlertAction *action = [UIAlertAction actionWithTitle:toCopyHref style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//                                        [UIPasteboard generalPasteboard].string = href;
//                                    }];
//                                    [actionArray addObject:action];
//                                }
//                                dispatch_group_leave(group);
//                            }];
//                        }
//                    }];
//
//                } else {
//                    dispatch_group_leave(group);
//                }
//            });
//        }
//        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//            if (actionArray.count) {
//                @strongify(self);
//                UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//                for (NSInteger index=0; index<actionArray.count; index++) {
//                    [alert addAction:actionArray[index]];
//                }
//                UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
//                }];
//                [alert addAction:cancel];
//                [self presentViewController:alert animated:YES completion:nil];
//            }
//        });
//    } else if (gestureRecognizer.state == UIGestureRecognizerStateChanged) {
//        if (_logEnable) {
//            //SSLog(@"长按手势变化...");
//        }
//    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
//        if (_logEnable) {
//            SSLog(@"结束长按手势...");
//        }
//    }
//}

@end
