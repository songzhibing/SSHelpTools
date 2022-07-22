//
//  SSHelpButtonModel.m
//  SSHelpTools
//
//  Created by 宋直兵 on 2022/6/27.
//

#import "SSHelpButtonModel.h"
#import "SSHelpDefines.h"

@implementation SSHelpButtonModel

+ (instancetype)modelWithDictionary:(NSDictionary *)dict
{
    SSHelpButtonModel *_model = [[SSHelpButtonModel alloc] init];
    _model.title = SSEncodeStringFromDict(dict, @"title");
    _model.icon  = dict[@"icon"];
    
    NSString *style = SSEncodeStringFromDict(dict, @"style");
    if ([style isEqualToString:@"back"])
    {
        _model.style =  SSButtonStyleBack;
    }
    else if ([style isEqualToString:@"reload"])
    {
        _model.style =  SSButtonStyleRefresh;
    }
    else if ([style isEqualToString:@"location"])
    {
        _model.style =  SSButtonStyleLocation;
    }
    else if ([style isEqualToString:@"list"])
    {
        //列表按钮
        _model.style =  SSButtonStyleList;
        _model.childButtons = SSEncodeArrayFromDict(dict, @"list");
    }
    else if ([style isEqualToString:@"rightmore"])
    {
        _model.style =  SSButtonStyleRightMore;
    }
    else if ([style isEqualToString:@"rightback"])
    {
        _model.style =  SSButtonStyleRightExit;
    }
    else if ([style isEqualToString:@"space"])
    {
        _model.style =  SSButtonStyleSpace;
        _model.spaceInterval = SSEncodeStringFromDict(dict, @"spaceInterval").intValue;
    }
    else
    {
        _model.style =  SSButtonStyleCustom;
    }
    return _model;
}

@end
