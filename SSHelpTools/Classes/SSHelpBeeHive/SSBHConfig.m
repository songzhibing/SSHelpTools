/**
 * Created by BeeHive.
 * Copyright (c) 2016, Alibaba, Inc. All rights reserved.
 *
 * This source code is licensed under the GNU GENERAL PUBLIC LICENSE.
 * For the full copyright and license information,please view the LICENSE file in the root directory of this source tree.
 */

#import "SSBHConfig.h"
#import "SSBHCommon.h"

@interface SSBHConfig()

@property(nonatomic, strong) NSMutableDictionary *config;

@end

@implementation SSBHConfig

static SSBHConfig *_BHConfigInstance;


+ (instancetype)shareInstance
{
    static dispatch_once_t p;
    
    dispatch_once(&p, ^{
        _BHConfigInstance = [[[self class] alloc] init];
    });
    return _BHConfigInstance;
}


+ (NSString *)stringValue:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        return nil;
    }
    
    return (NSString *)[[SSBHConfig shareInstance].config objectForKey:key];
}

+ (NSDictionary *)dictionaryValue:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        return nil;
    }
    
    if (![[[SSBHConfig shareInstance].config objectForKey:key] isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    
    return (NSDictionary *)[[SSBHConfig shareInstance].config objectForKey:key];
}

+ (NSArray *)arrayValue:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        return nil;
    }
    
    if (![[[SSBHConfig shareInstance].config objectForKey:key] isKindOfClass:[NSArray class]]) {
        return nil;
    }
    
    return (NSArray *)[[SSBHConfig shareInstance].config objectForKey:key];
}

+ (NSInteger)integerValue:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        return 0;
    }
    
    return [[[SSBHConfig shareInstance].config objectForKey:key] integerValue];
}

+ (float)floatValue:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        return 0.0;
    }
    
    return [(NSNumber *)[[SSBHConfig shareInstance].config objectForKey:key] floatValue];
}

+ (BOOL)boolValue:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        return NO;
    }
    
    return [(NSNumber *)[[SSBHConfig shareInstance].config objectForKey:key] boolValue];
}


+ (id)get:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        @throw [NSException exceptionWithName:@"ConfigNotInitialize" reason:@"config not initialize" userInfo:nil];
        
        return nil;
    }
    
    id v = [[SSBHConfig shareInstance].config objectForKey:key];
    if (!v) {
        SSBHLog(@"InvaildKeyValue %@ is nil", key);
    }
    
    return v;
}

+ (BOOL)has:(NSString *)key
{
    if (![SSBHConfig shareInstance].config) {
        return NO;
    }
    
    if (![[SSBHConfig shareInstance].config objectForKey:key]) {
        return NO;
    }
    
    return YES;
}

+ (void)set:(NSString *)key value:(id)value
{
    if (![SSBHConfig shareInstance].config) {
        [SSBHConfig shareInstance].config = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    [[SSBHConfig shareInstance].config setObject:value forKey:key];
}


+ (void)set:(NSString *)key boolValue:(BOOL)value
{
    [self set:key value:[NSNumber numberWithBool:value]];
}

+ (void)set:(NSString *)key integerValue:(NSInteger)value
{
    [self set:key value:[NSNumber numberWithInteger:value]];
}


+ (void) add:(NSDictionary *)parameters
{
    if (![SSBHConfig shareInstance].config) {
        [SSBHConfig shareInstance].config = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    
    [[SSBHConfig shareInstance].config addEntriesFromDictionary:parameters];
}

+ (NSDictionary *) getAll
{
    return [SSBHConfig shareInstance].config;
}

+ (void)clear
{
    if ([SSBHConfig shareInstance].config) {
        [[SSBHConfig shareInstance].config removeAllObjects];
    }
}

@end
