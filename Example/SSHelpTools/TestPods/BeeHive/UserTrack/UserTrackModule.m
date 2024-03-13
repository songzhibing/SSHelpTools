//
//  UserTrackModule.m
//  BeeHive
//
//  Created by 一渡 on 7/14/15.
//  Copyright (c) 2015 一渡. All rights reserved.
//

#import "UserTrackModule.h"
#import "BHUserTrackViewController.h"

@interface UserTrackModule()<SSBHModuleProtocol>

@end

@implementation UserTrackModule


SSBH_EXPORT_MODULE(NO)

- (void)modSetUp:(SSBHContext *)context
{
    NSLog(@"UserTrackModule setup");
}



-(void)modInit:(SSBHContext *)context
{

//    [[BeeHive shareInstance] registerService:@protocol(UserTrackServiceProtocol) service:[BHUserTrackViewController class]];
}

@end
