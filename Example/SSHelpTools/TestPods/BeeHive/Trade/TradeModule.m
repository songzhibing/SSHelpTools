//
//  TradeModule.m
//  BeeHive
//
//  Created by 一渡 on 7/14/15.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "TradeModule.h"
#import "BHTradeViewController.h"

@interface TradeModule()

@end

@implementation TradeModule

+ (void)load
{
    [SSBeeHive registerDynamicModule:[self class]];
}

- (id)init{
    if (self = [super init])
    {
        NSLog(@"TradeModule init");
    }
    
    return self;
}


- (void)modWillResignActive:(BHContext *)context
{
    NSLog(@"失活...");
}

-(void)modInit:(BHContext *)context
{
    NSLog(@"模块初始化中");
    NSLog(@"%@",context.moduleConfigName);
    
    
    id<TradeServiceProtocol> service = [[SSBeeHive shareInstance] createService:@protocol(TradeServiceProtocol)];
    
    service.itemId = @"我是单例";
}


- (void)modSetUp:(BHContext *)context
{
//    [[BeeHive shareInstance]  registerService:@protocol(TradeServiceProtocol) service:[BHTradeViewController class]];
    
    NSLog(@"TradeModule setup");

}

- (void)basicModuleLevel
{
    
}

@end
