//
//  SSHelpLocationGenerator.m
//
//  Copyright (c) 2014-2017 Intuit Inc.
//

#import "SSHelpLocationGenerator.h"

@implementation SSHelpLocationGenerator

static SSLocationRequestID _nextRequestID = 0;

+ (SSLocationRequestID)getUniqueRequestID
{
    _nextRequestID++;
    return _nextRequestID;
}

@end
