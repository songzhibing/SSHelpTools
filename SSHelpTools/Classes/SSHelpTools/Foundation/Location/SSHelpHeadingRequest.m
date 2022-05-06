//
//  INTUHeadingRequest.m
//
//  Copyright (c) 2014-2017 Intuit Inc.
//

#import "SSHelpHeadingRequest.h"
#import "SSHelpLocationGenerator.h"

@implementation SSHelpHeadingRequest

/**
 Designated initializer. Initializes and returns a newly allocated heading request.
 */
- (instancetype)init
{
    if (self = [super init]) {
        _requestID = [SSHelpLocationGenerator getUniqueRequestID];
        _isRecurring = YES;
    }
    return self;
}

/**
 Two heading requests are considered equal if their request IDs match.
 */
- (BOOL)isEqual:(id)object
{
    if (object == self) {
        return YES;
    }
    if (!object || ![object isKindOfClass:[self class]]) {
        return NO;
    }
    if (((SSHelpHeadingRequest *)object).requestID == self.requestID) {
        return YES;
    }
    return NO;
}

/**
 Return a hash based on the string representation of the request ID.
 */
- (NSUInteger)hash
{
    return [[NSString stringWithFormat:@"%ld", (long)self.requestID] hash];
}

@end
