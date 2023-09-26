//
//  HomeModule.m
//  BeeHive
//
//  Created by 一渡 on 7/14/15.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "HomeModule.h"
#import "BHViewController.h"


@interface HomeModule()<SSBHModuleProtocol>

@end

@implementation HomeModule

-(void)modInit:(SSBHContext *)context
{
    switch (context.env) {
        case SSBHEnvironmentDev:
            //....初始化开发环境
            break;
        case SSBHEnvironmentProd:
            //....初始化生产环境
        default:
            break;
    }
}

- (void)modSetUp:(SSBHContext *)context
{
    NSLog(@"HomeModule setup");
}


@end
