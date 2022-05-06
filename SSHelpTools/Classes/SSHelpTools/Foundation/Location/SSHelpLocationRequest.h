//
//  SSHelpLocationRequest.h
//
//  Copyright (c) 2014-2017 Intuit Inc.
//

#import "SSHelpLocationGenerator.h"

NS_ASSUME_NONNULL_BEGIN

/** The available types of location requests. */
typedef NS_ENUM(NSInteger, SSHelpLocationRequestType) {
    
    /** A one-time location request with a specific desired accuracy and optional timeout. */
    SSHelpLocationRequestTypeSingle,
    
    /** A subscription to location updates. */
    SSHelpLocationRequestTypeSubscription,
    
    /** A subscription to significant location changes. */
    SSHelpLocationRequestTypeSignificantChanges
};

@class SSHelpLocationRequest;

/**
 Protocol for the SSHelpLocationRequest to notify the its delegate that a request has timed out.
 */
@protocol SSHelpLocationRequestDelegate

/**
 Notification that a location request has timed out.
 
 @param locationRequest The location request that timed out.
 */
- (void)locationRequestDidTimeout:(SSHelpLocationRequest *)locationRequest;

@end


/**
 Represents a geolocation request that is created and managed by SSHelpLocationManager.
 */
@interface SSHelpLocationRequest : NSObject

/** The delegate for this location request. */
@property (nonatomic, weak, nullable) id<SSHelpLocationRequestDelegate> delegate;

/** The request ID for this location request (set during initialization). */
@property (nonatomic, readonly) SSLocationRequestID requestID;

/** The type of this location request (set during initialization). */
@property (nonatomic, readonly) SSHelpLocationRequestType type;

/** Whether this is a recurring location request (type is either Subscription or SignificantChanges). */
@property (nonatomic, readonly) BOOL isRecurring;

/** The desired accuracy for this location request. */
@property (nonatomic, assign) SSLocationAccuracy desiredAccuracy;

/** The desired activity type for this location request. */
@property (nonatomic, assign) CLActivityType desiredActivityType;

/** The maximum amount of time the location request should be allowed to live before completing.
    If this value is exactly 0.0, it will be ignored (the request will never timeout by itself). */
@property (nonatomic, assign) NSTimeInterval timeout;

/** How long the location request has been alive since the timeout value was last set. */
@property (nonatomic, readonly) NSTimeInterval timeAlive;

/** Whether this location request has timed out (will also be YES if it has been completed). Subcriptions can never time out. */
@property (nonatomic, readonly) BOOL hasTimedOut;

/** The block to execute when the location request completes. */
@property (nonatomic, copy, nullable) SSLocationRequestBlock block;

/** Designated initializer. Initializes and returns a newly allocated location request object with the specified type. */
- (instancetype)initWithType:(SSHelpLocationRequestType)type __SSLOC_DESIGNATED_INITIALIZER;

/** Completes the location request. */
- (void)complete;

/** Forces the location request to consider itself timed out. */
- (void)forceTimeout;

/** Cancels the location request. */
- (void)cancel;

/** Starts the location request's timeout timer if a nonzero timeout value is set, and the timer has not already been started. */
- (void)startTimeoutTimerIfNeeded;

/** Returns the associated recency threshold (in seconds) for the location request's desired accuracy level. */
- (NSTimeInterval)updateTimeStaleThreshold;

/** Returns the associated horizontal accuracy threshold (in meters) for the location request's desired accuracy level. */
- (CLLocationAccuracy)horizontalAccuracyThreshold;

@end

NS_ASSUME_NONNULL_END
