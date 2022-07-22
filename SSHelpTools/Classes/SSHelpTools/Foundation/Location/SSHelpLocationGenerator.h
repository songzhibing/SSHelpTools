//
//  SSHelpLocationGenerator.h
//
//  Copyright (c) 2014-2017 Intuit Inc.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

#if __has_feature(objc_generics)
#   define __SSLOC_GENERICS(type, ...)       type<__VA_ARGS__>
#else
#   define __SSLOC_GENERICS(type, ...)       type
#endif

#ifdef NS_DESIGNATED_INITIALIZER
#   define __SSLOC_DESIGNATED_INITIALIZER    NS_DESIGNATED_INITIALIZER
#else
#   define __SSLOC_DESIGNATED_INITIALIZER
#endif


#ifndef SSLOC_ENABLE_LOGGING
#   ifdef DEBUG
#       define SSLOC_ENABLE_LOGGING 1
#   else
#       define SSLOC_ENABLE_LOGGING 0
#   endif /* DEBUG */
#endif /* SSLOC_ENABLE_LOGGING */

//#if SSLOC_ENABLE_LOGGING
//#   define SSLOCLog(...)  NSLog(@"SSHelpLocationManager: %@", [NSString stringWithFormat:__VA_ARGS__]);
//#else
//#   define SSLOCLog(...)
//#endif /* SSLOC_ENABLE_LOGGING */


static const CLLocationAccuracy kSSLOCHorizontalAccuracyThresholdCity =         5000.0;  // in meters
static const CLLocationAccuracy kSSLOCHorizontalAccuracyThresholdNeighborhood = 1000.0;  // in meters
static const CLLocationAccuracy kSSLOCHorizontalAccuracyThresholdBlock =         100.0;  // in meters
static const CLLocationAccuracy kSSLOCHorizontalAccuracyThresholdHouse =          15.0;  // in meters
static const CLLocationAccuracy kSSLOCHorizontalAccuracyThresholdRoom  =           5.0;  // in meters

static const NSTimeInterval kSSLOCUpdateTimeStaleThresholdCity =         600.0;  // in seconds
static const NSTimeInterval kSSLOCUpdateTimeStaleThresholdNeighborhood = 300.0;  // in seconds
static const NSTimeInterval kSSLOCUpdateTimeStaleThresholdBlock =         60.0;  // in seconds
static const NSTimeInterval kSSLOCUpdateTimeStaleThresholdHouse =         15.0;  // in seconds
static const NSTimeInterval kSSLOCUpdateTimeStaleThresholdRoom  =          5.0;  // in seconds

/** The possible states that location services can be in. */
typedef NS_ENUM(NSInteger, SSLocationServicesState) {
    
    /** User has already granted this app permissions to access location services, and they are enabled and ready for use by this app.
        Note: this state will be returned for both the "When In Use" and "Always" permission levels. */
    SSLocationServicesStateAvailable,
   
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    SSLocationServicesStateNotDetermined,
    
    /** User has explicitly denied this app permission to access location services. (The user can enable permissions again for this app from the system Settings app.) */
    SSLocationServicesStateDenied,
    
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    SSLocationServicesStateRestricted,
    
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    SSLocationServicesStateDisabled
};

/** The possible states that heading services can be in. */
typedef NS_ENUM(NSInteger, SSHeadingServicesState) {
   
    /** Heading services are available on the device */
    SSHeadingServicesStateAvailable,
    
    /** Heading services are available on the device */
    SSHeadingServicesStateUnavailable,
};

/** A unique ID that corresponds to one location request. */
typedef NSInteger SSLocationRequestID;

/** A unique ID that corresponds to one heading request. */
typedef NSInteger SSHeadingRequestID;

/** An abstraction of both the horizontal accuracy and recency of location data.
    Room is the highest level of accuracy/recency; City is the lowest level. */
typedef NS_ENUM(NSInteger, SSLocationAccuracy) {
    
    // 'None' is not valid as a desired accuracy.
    /** Inaccurate (>5000 meters, and/or received >10 minutes ago). */
    SSLocationAccuracyNone = 0,
    
    // The below options are valid desired accuracies.
    /** 5000 meters or better, and received within the last 10 minutes. Lowest accuracy. */
    SSLocationAccuracyCity,
    
    /** 1000 meters or better, and received within the last 5 minutes. */
    SSLocationAccuracyNeighborhood,
    
    /** 100 meters or better, and received within the last 1 minute. */
    SSLocationAccuracyBlock,
    
    /** 15 meters or better, and received within the last 15 seconds. */
    SSLocationAccuracyHouse,
    
    /** 5 meters or better, and received within the last 5 seconds. Highest accuracy. */
    SSLocationAccuracyRoom,
};

/** An alias of the heading filter accuracy in degrees.
    Specifies the minimum amount of change in degrees needed for a heading service update. Observers will not be notified of updates less than the stated filter value. */
typedef CLLocationDegrees SSHeadingFilterAccuracy;

/** A status that will be passed in to the completion block of a location request. */
typedef NS_ENUM(NSInteger, SSLocationStatus) {
   
    // These statuses will accompany a valid location.
    /** Got a location and desired accuracy level was achieved successfully. */
    SSLocationStatusSuccess = 0,
    
    /** Got a location, but the desired accuracy level was not reached before timeout. (Not applicable to subscriptions.) */
    SSLocationStatusTimedOut,
    
    // These statuses indicate some sort of error, and will accompany a nil location.
    /** User has not yet responded to the dialog that grants this app permission to access location services. */
    SSLocationStatusServicesNotDetermined,
    
    /** User has explicitly denied this app permission to access location services. */
    SSLocationStatusServicesDenied,
    
    /** User does not have ability to enable location services (e.g. parental controls, corporate policy, etc). */
    SSLocationStatusServicesRestricted,
    
    /** User has turned off location services device-wide (for all apps) from the system Settings app. */
    SSLocationStatusServicesDisabled,
    
    /** An error occurred while using the system location services. */
    SSLocationStatusError
};

/** A status that will be passed in to the completion block of a heading request. */
typedef NS_ENUM(NSInteger, SSHeadingStatus) {
    
    // These statuses will accompany a valid heading.
    /** Got a heading successfully. */
    SSHeadingStatusSuccess = 0,

    // These statuses indicate some sort of error, and will accompany a nil heading.
    /** Heading was invalid. */
    SSHeadingStatusInvalid,

    /** Heading services are not available on the device */
    SSHeadingStatusUnavailable
};

/**
 A block type for a location request, which is executed when the request succeeds, fails, or times out.
 
 @param currentLocation The most recent & accurate current location available when the block executes, or nil if no valid location is available.
 @param achievedAccuracy The accuracy level that was actually achieved (may be better than, equal to, or worse than the desired accuracy).
 @param status The status of the location request - whether it succeeded, timed out, or failed due to some sort of error. This can be used to
               understand what the outcome of the request was, decide if/how to use the associated currentLocation, and determine whether other
               actions are required (such as displaying an error message to the user, retrying with another request, quietly proceeding, etc).
 */
typedef void(^SSLocationRequestBlock)(CLLocation *currentLocation, SSLocationAccuracy achievedAccuracy, SSLocationStatus status);


typedef void(^SSLocationReverseGeocodeBlock)(CLPlacemark *_Nullable placemark, NSError * _Nullable error);

/**
 A block type for a heading request, which is executed when the request succeeds.

 @param currentHeading  The most recent current heading available when the block executes.
 @param status          The status of the request - whether it succeeded or failed due to some sort of error. This can be used to understand if any further action is needed.
 */
typedef void(^SSHeadingRequestBlock)(CLHeading *_Nullable currentHeading, SSHeadingStatus status);

typedef NS_ENUM(NSUInteger, SSAuthorizationType) {
    SSAuthorizationTypeAuto,
    SSAuthorizationTypeAlways,
    SSAuthorizationTypeWhenInUse,
};

@interface SSHelpLocationGenerator : NSObject

/**
 Returns a unique request ID (within the lifetime of the application).
 */
+ (SSLocationRequestID)getUniqueRequestID;

@end

NS_ASSUME_NONNULL_END
