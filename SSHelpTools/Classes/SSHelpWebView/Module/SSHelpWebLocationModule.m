//
//  SSHelpWebLocationModule.m
//  SSHelpWebView
//
//  Created by 宋直兵 on 2022/3/7.
//

#import "SSHelpWebLocationModule.h"

@interface SSHelpWebLocationModule()

@end

@implementation SSHelpWebLocationModule

- (void)moduleRegisterJsHandler
{
    [self baseRegisterHandler:kWebApiGetLocation handler:^(NSString * _Nonnull api, id  _Nonnull data, SSBridgeJsCallback  _Nonnull callback) {
        [[SSHelpLocationManager sharedInstance] requestLocationWithDesiredAccuracy:SSLocationAccuracyHouse timeout:5 delayUntilAuthorized:YES block:^(CLLocation * _Nonnull location, SSLocationAccuracy achievedAccuracy, SSLocationStatus status) {
            SSHelpWebObjcResponse *response = [[SSHelpWebObjcResponse alloc] init];
            if (location) {
                response.code = 1;
                NSString *latitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
                NSString *longitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
                response.data = @{@"latitude":latitude,@"longitude":longitude
                };
            }else{
                response.code = 0;
            }
            callback(response);
        }];
    }];
}

@end
