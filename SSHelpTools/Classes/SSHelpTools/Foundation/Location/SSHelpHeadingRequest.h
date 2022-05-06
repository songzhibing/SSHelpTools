//
//  INTUHeadingRequest.h
//
//  Copyright (c) 2014-2017 Intuit Inc.
//

#import "SSHelpLocationGenerator.h"

NS_ASSUME_NONNULL_BEGIN

@interface SSHelpHeadingRequest : NSObject

/** The request ID for this heading request (set during initialization). */
@property (nonatomic, readonly) SSHeadingRequestID requestID;

/** Whether this is a recurring heading request (all heading requests are assumed to be for now). */
@property (nonatomic, readonly) BOOL isRecurring;

/** The block to execute when the heading request completes. */
@property (nonatomic, copy, nullable) SSHeadingRequestBlock block;

@end

NS_ASSUME_NONNULL_END
