//
//  SSHelpNavigationBarModel.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/6/27.
//

#import "SSHelpNavigationBarModel.h"
#import "SSHelpDefines.h"

@implementation SSHelpNavigationBarModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    SSHelpNavigationBarModel *_model = [[SSHelpNavigationBarModel alloc] init];
    _model.title = SSEncodeStringFromDict(dict, @"title");
    _model.titleImage = dict[@"image"];
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
