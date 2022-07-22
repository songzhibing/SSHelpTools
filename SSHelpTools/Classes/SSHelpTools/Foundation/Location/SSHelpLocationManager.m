//
//  SSHelpLocationManager.m
//
//  Copyright (c) 2014-2017 Intuit Inc.
//

#import "SSHelpLocationManager.h"
#import "SSHelpLocationRequest.h"
#import "SSHelpHeadingRequest.h"
#import "SSHelpDefines.h"

@interface SSHelpLocationManager () <CLLocationManagerDelegate, SSHelpLocationRequestDelegate>

/** The instance of CLLocationManager encapsulated by this class. */
@property (nonatomic, strong) CLLocationManager *locationManager;

/** The most recent current location, or nil if the current location is unknown, invalid, or stale. */
@property (nonatomic, strong) CLLocation *currentLocation;

/** The most recent current heading, or nil if the current heading is unknown, invalid, or stale. */
@property (nonatomic, strong) CLHeading *currentHeading;

/** Whether or not the CLLocationManager is currently monitoring significant location changes. */
@property (nonatomic, assign) BOOL isMonitoringSignificantLocationChanges;

/** Whether or not the CLLocationManager is currently sending location updates. */
@property (nonatomic, assign) BOOL isUpdatingLocation;

/** Whether or not the CLLocationManager is currently sending heading updates. */
@property (nonatomic, assign) BOOL isUpdatingHeading;

/** Whether an error occurred during the last location update. */
@property (nonatomic, assign) BOOL updateFailed;

// An array of active location requests in the form:
// @[ SSHelpLocationRequest *locationRequest1, SSHelpLocationRequest *locationRequest2, ... ]
@property (nonatomic, strong) __SSLOC_GENERICS(NSArray, SSHelpLocationRequest *) *locationRequests;

// An array of active heading requests in the form:
// @[ INTUHeadingRequest *headingRequest1, INTUHeadingRequest *headingRequest2, ... ]
@property (nonatomic, strong) __SSLOC_GENERICS(NSArray, SSHelpHeadingRequest *) *headingRequests;

@end


@implementation SSHelpLocationManager

static id _sharedInstance;

/** 
 Returns the current state of heading services for this device. 
 */
+ (SSHeadingServicesState)headingServicesState
{
    if ([CLLocationManager headingAvailable]) {
        return SSHeadingServicesStateAvailable;
    } else {
        return SSHeadingServicesStateUnavailable;
    }
}

/**
 Returns the singleton instance of this class.
 */
+ (instancetype)sharedInstance
{
    static dispatch_once_t _onceToken;
    dispatch_once(&_onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init
{
    NSAssert(_sharedInstance == nil, @"Only one instance of SSHelpLocationManager should be created. Use +[SSHelpLocationManager sharedInstance] instead.");
    self = [super init];
    if (self) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        self.preferredAuthorizationType = SSAuthorizationTypeAuto;

#ifdef __IPHONE_8_4
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
        /* iOS 9 requires setting allowsBackgroundLocationUpdates to YES in order to receive background location updates.
         We only set it to YES if the location background mode is enabled for this app, as the documentation suggests it is a
         fatal programmer error otherwise. */
        NSArray *backgroundModes = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"UIBackgroundModes"];
        if ([backgroundModes containsObject:@"location"]) {
            if (@available(iOS 9, *)) {
                [_locationManager setAllowsBackgroundLocationUpdates:YES];
            }
        }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4 */
#endif /* __IPHONE_8_4 */

        _locationRequests = @[];
    }
    return self;
}

/**
 Returns the current state of location services for this app, based on the system settings and user authorization status.
 */
- (SSLocationServicesState)locationServicesState
{
    if ([CLLocationManager locationServicesEnabled] == NO) {
        return SSLocationServicesStateDisabled;
    }
    
    CLAuthorizationStatus status = kCLAuthorizationStatusNotDetermined;
    if (@available(iOS 14.0, *)) {
        status = self.locationManager.authorizationStatus;
    }else{
        status = [CLLocationManager authorizationStatus];
    }
    
    switch (status) {
        case kCLAuthorizationStatusNotDetermined:
            return SSLocationServicesStateNotDetermined;
        case kCLAuthorizationStatusDenied:
            return SSLocationServicesStateDenied;
        case kCLAuthorizationStatusRestricted:
            return SSLocationServicesStateRestricted;
        default:
            return SSLocationServicesStateAvailable;
    }
}


#pragma mark Public location methods

/**
 Asynchronously requests the current location of the device using location services.

 @param desiredAccuracy The accuracy level desired (refers to the accuracy and recency of the location).
 @param timeout         The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing.
                            If this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param block           The block to be executed when the request succeeds, fails, or times out. Three parameters are passed into the block:
                            - The current location (the most recent one acquired, regardless of accuracy level), or nil if no valid location was acquired
                            - The achieved accuracy for the current location (may be less than the desired accuracy if the request failed)
                            - The request status (if it succeeded, or if not, why it failed)

 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (SSLocationRequestID)requestLocationWithDesiredAccuracy:(SSLocationAccuracy)desiredAccuracy
                                                  timeout:(NSTimeInterval)timeout
                                                    block:(SSLocationRequestBlock)block
{
    return [self requestLocationWithDesiredAccuracy:desiredAccuracy
                                desiredActivityType:CLActivityTypeOther
                                            timeout:timeout
                               delayUntilAuthorized:NO
                                              block:block];
}

/**
 Asynchronously requests the current location of the device using location services.
 
 @param desiredAccuracy The accuracy level desired (refers to the accuracy and recency of the location).
 @param timeout         The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing.
                            If this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param block           The block to be executed when the request succeeds, fails, or times out. Three parameters are passed into the block:
                            - The current location (the most recent one acquired, regardless of accuracy level), or nil if no valid location was acquired
                            - The achieved accuracy for the current location (may be less than the desired accuracy if the request failed)
                            - The request status (if it succeeded, or if not, why it failed)
 
 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (SSLocationRequestID)requestLocationWithDesiredAccuracy:(SSLocationAccuracy)desiredAccuracy
                                      desiredActivityType:(CLActivityType)desiredActivityType
                                                  timeout:(NSTimeInterval)timeout
                                                    block:(SSLocationRequestBlock)block
{
    return [self requestLocationWithDesiredAccuracy:desiredAccuracy
                                desiredActivityType:desiredActivityType
                                            timeout:timeout
                               delayUntilAuthorized:NO
                                              block:block];
}

/**
 Asynchronously requests the current location of the device using location services, optionally waiting until the user grants the app permission
 to access location services before starting the timeout countdown.

 @param desiredAccuracy      The accuracy level desired (refers to the accuracy and recency of the location).
 @param timeout              The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing. If
                             this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param delayUntilAuthorized A flag specifying whether the timeout should only take effect after the user responds to the system prompt requesting
                             permission for this app to access location services. If YES, the timeout countdown will not begin until after the
                             app receives location services permissions. If NO, the timeout countdown begins immediately when calling this method.
 @param block                The block to be executed when the request succeeds, fails, or times out. Three parameters are passed into the block:
                                 - The current location (the most recent one acquired, regardless of accuracy level), or nil if no valid location was acquired
                                 - The achieved accuracy for the current location (may be less than the desired accuracy if the request failed)
                                 - The request status (if it succeeded, or if not, why it failed)

 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (SSLocationRequestID)requestLocationWithDesiredAccuracy:(SSLocationAccuracy)desiredAccuracy
                                                  timeout:(NSTimeInterval)timeout
                                     delayUntilAuthorized:(BOOL)delayUntilAuthorized
                                                    block:(SSLocationRequestBlock)block
{
    return [self requestLocationWithDesiredAccuracy:desiredAccuracy
                                desiredActivityType:CLActivityTypeOther
                                            timeout:timeout
                               delayUntilAuthorized:delayUntilAuthorized
                                              block:block];
}

/**
 Asynchronously requests the current location of the device using location services, optionally waiting until the user grants the app permission
 to access location services before starting the timeout countdown.
 
 @param desiredAccuracy      The accuracy level desired (refers to the accuracy and recency of the location).
 @param desiredActivityType  The activity type desired for the location tracking.
 @param timeout              The maximum amount of time (in seconds) to wait for a location with the desired accuracy before completing. If
                             this value is 0.0, no timeout will be set (will wait indefinitely for success, unless request is force completed or canceled).
 @param delayUntilAuthorized A flag specifying whether the timeout should only take effect after the user responds to the system prompt requesting
                             permission for this app to access location services. If YES, the timeout countdown will not begin until after the
                             app receives location services permissions. If NO, the timeout countdown begins immediately when calling this method.
 @param block                The block to be executed when the request succeeds, fails, or times out. Three parameters are passed into the block:
                                 - The current location (the most recent one acquired, regardless of accuracy level), or nil if no valid location was acquired
                                 - The achieved accuracy for the current location (may be less than the desired accuracy if the request failed)
                                 - The request status (if it succeeded, or if not, why it failed)
 
 @return The location request ID, which can be used to force early completion or cancel the request while it is in progress.
 */
- (SSLocationRequestID)requestLocationWithDesiredAccuracy:(SSLocationAccuracy)desiredAccuracy
                                      desiredActivityType:(CLActivityType)desiredActivityType
                                                  timeout:(NSTimeInterval)timeout
                                     delayUntilAuthorized:(BOOL)delayUntilAuthorized
                                                    block:(SSLocationRequestBlock)block
{
    NSAssert([NSThread isMainThread], @"SSHelpLocationManager should only be called from the main thread.");

    if (desiredAccuracy == SSLocationAccuracyNone) {
        NSAssert(desiredAccuracy != SSLocationAccuracyNone, @"SSLocationAccuracyNone is not a valid desired accuracy.");
        desiredAccuracy = SSLocationAccuracyCity; // default to the lowest valid desired accuracy
    }

    SSHelpLocationRequest *locationRequest = [[SSHelpLocationRequest alloc] initWithType:SSHelpLocationRequestTypeSingle];
    locationRequest.delegate = self;
    locationRequest.desiredAccuracy = desiredAccuracy;
    locationRequest.timeout = timeout;
    locationRequest.block = block;
    locationRequest.desiredActivityType = desiredActivityType;
    
    BOOL deferTimeout = delayUntilAuthorized && ([self locationServicesState] == SSLocationServicesStateNotDetermined);
    if (!deferTimeout) {
        [locationRequest startTimeoutTimerIfNeeded];
    }

    [self addLocationRequest:locationRequest];

    return locationRequest.requestID;
}

/**
 Creates a subscription for location updates that will execute the block once per update indefinitely (until canceled), regardless of the accuracy of each location.
 This method instructs location services to use the highest accuracy available (which also requires the most power).
 If an error occurs, the block will execute with a status other than SSLocationStatusSuccess, and the subscription will be canceled automatically.
 
 @param block The block to execute every time an updated location is available.
              The status will be SSLocationStatusSuccess unless an error occurred; it will never be SSLocationStatusTimedOut.
 
 @return The location request ID, which can be used to cancel the subscription of location updates to this block.
 */
- (SSLocationRequestID)subscribeToLocationUpdatesWithBlock:(SSLocationRequestBlock)block
{
    return [self subscribeToLocationUpdatesWithDesiredAccuracy:SSLocationAccuracyRoom
                                           desiredActivityType:CLActivityTypeOther
                                                         block:block];
}

/**
 Creates a subscription for location updates that will execute the block once per update indefinitely (until canceled), regardless of the accuracy of each location.
 The specified desired accuracy is passed along to location services, and controls how much power is used, with higher accuracies using more power.
 If an error occurs, the block will execute with a status other than SSLocationStatusSuccess, and the subscription will be canceled automatically.

 @param desiredAccuracy The accuracy level desired, which controls how much power is used by the device's location services.
 @param block           The block to execute every time an updated location is available. Note that this block runs for every update, regardless of
                        whether the achievedAccuracy is at least the desiredAccuracy.
                        The status will be SSLocationStatusSuccess unless an error occurred; it will never be SSLocationStatusTimedOut.

 @return The location request ID, which can be used to cancel the subscription of location updates to this block.
 */
- (SSLocationRequestID)subscribeToLocationUpdatesWithDesiredAccuracy:(SSLocationAccuracy)desiredAccuracy
                                                               block:(SSLocationRequestBlock)block
{
    return [self subscribeToLocationUpdatesWithDesiredAccuracy:desiredAccuracy
                                           desiredActivityType:CLActivityTypeOther
                                                         block:block];
}

/**
 Creates a subscription for location updates that will execute the block once per update indefinitely (until canceled), regardless of the accuracy of each location.
 The specified desired accuracy is passed along to location services, and controls how much power is used, with higher accuracies using more power.
 If an error occurs, the block will execute with a status other than SSLocationStatusSuccess, and the subscription will be canceled automatically.
 
 @param desiredAccuracy The accuracy level desired, which controls how much power is used by the device's location services.
 @param desiredActivityType The activity type that is to be tracked, controls when/if tracking it paused.
 @param block           The block to execute every time an updated location is available. Note that this block runs for every update, regardless of
                        whether the achievedAccuracy is at least the desiredAccuracy.
                        The status will be SSLocationStatusSuccess unless an error occurred; it will never be SSLocationStatusTimedOut.
 
 @return The location request ID, which can be used to cancel the subscription of location updates to this block.
 */
- (SSLocationRequestID)subscribeToLocationUpdatesWithDesiredAccuracy:(SSLocationAccuracy)desiredAccuracy
                                                 desiredActivityType:(CLActivityType)desiredActivityType
                                                               block:(SSLocationRequestBlock)block
{
    NSAssert([NSThread isMainThread], @"SSHelpLocationManager should only be called from the main thread.");

    SSHelpLocationRequest *locationRequest = [[SSHelpLocationRequest alloc] initWithType:SSHelpLocationRequestTypeSubscription];
    locationRequest.desiredAccuracy = desiredAccuracy;
    locationRequest.desiredActivityType = desiredActivityType;
    locationRequest.block = block;

    [self addLocationRequest:locationRequest];

    return locationRequest.requestID;
}

/**
 Creates a subscription for significant location changes that will execute the block once per change indefinitely (until canceled).
 If an error occurs, the block will execute with a status other than SSLocationStatusSuccess, and the subscription will be canceled automatically.
 
 @param block The block to execute every time an updated location is available.
              The status will be SSLocationStatusSuccess unless an error occurred; it will never be SSLocationStatusTimedOut.
 
 @return The location request ID, which can be used to cancel the subscription of significant location changes to this block.
 */
- (SSLocationRequestID)subscribeToSignificantLocationChangesWithBlock:(SSLocationRequestBlock)block
{
    NSAssert([NSThread isMainThread], @"SSHelpLocationManager should only be called from the main thread.");

    SSHelpLocationRequest *locationRequest = [[SSHelpLocationRequest alloc] initWithType:SSHelpLocationRequestTypeSignificantChanges];
    locationRequest.block = block;

    [self addLocationRequest:locationRequest];

    return locationRequest.requestID;
}

/**
 Immediately forces completion of the location request with the given requestID (if it exists), and executes the original request block with the results.
 This is effectively a manual timeout, and will result in the request completing with status SSLocationStatusTimedOut.
 */
- (void)forceCompleteLocationRequest:(SSLocationRequestID)requestID
{
    NSAssert([NSThread isMainThread], @"SSHelpLocationManager should only be called from the main thread.");

    for (SSHelpLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.requestID == requestID) {
            if (locationRequest.isRecurring) {
                // Recurring requests can only be canceled
                [self cancelLocationRequest:requestID];
            } else {
                [locationRequest forceTimeout];
                [self completeLocationRequest:locationRequest];
            }
            break;
        }
    }
}

/**
 Immediately cancels the location request with the given requestID (if it exists), without executing the original request block.
 */
- (void)cancelLocationRequest:(SSLocationRequestID)requestID
{
    NSAssert([NSThread isMainThread], @"SSHelpLocationManager should only be called from the main thread.");

    for (SSHelpLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.requestID == requestID) {
            [locationRequest cancel];
            SSLog(@"Location Request canceled with ID: %ld", (long)locationRequest.requestID);
            [self removeLocationRequest:locationRequest];
            break;
        }
    }
}

/** reverse geocode requests */
- (void)reverseGeocodeLocation:(CLLocation *)location completion:(SSLocationReverseGeocodeBlock)completion
{
    CLGeocoder *geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error) {
            completion(nil,error);
        }else{
            CLPlacemark *placemark = [placemarks firstObject];
            completion(placemark,nil);
        }
    }];
}

#pragma mark Public heading methods

/**
 Asynchronously requests the current heading of the device using location services.

 @param block The block to be executed when the request succeeds. One parameter is passed into the block:
 - The current heading (the most recent one acquired, regardless of accuracy level), or nil if no valid heading was acquired
 
 @return The heading request ID, which can be used remove the request from being called in the future.
 */
- (SSHeadingRequestID)subscribeToHeadingUpdatesWithBlock:(SSHeadingRequestBlock)block
{
    SSHelpHeadingRequest *headingRequest = [[SSHelpHeadingRequest alloc] init];
    headingRequest.block = block;

    [self addHeadingRequest:headingRequest];

    return headingRequest.requestID;
}

/**
 Immediately cancels the heading request with the given requestID (if it exists), without executing the original request block.
 */
- (void)cancelHeadingRequest:(SSHeadingRequestID)requestID
{
    for (SSHelpHeadingRequest *headingRequest in self.headingRequests) {
        if (headingRequest.requestID == requestID) {
            [self removeHeadingRequest:headingRequest];
            SSLog(@"Heading Request canceled with ID: %ld", (long)headingRequest.requestID);
            break;
        }
    }
}

#pragma mark Internal location methods

/**
 Adds the given location request to the array of requests, updates the maximum desired accuracy, and starts location updates if needed.
 */
- (void)addLocationRequest:(SSHelpLocationRequest *)locationRequest
{
    SSLocationServicesState locationServicesState = [self locationServicesState];
    if (locationServicesState == SSLocationServicesStateDisabled ||
        locationServicesState == SSLocationServicesStateDenied ||
        locationServicesState == SSLocationServicesStateRestricted) {
        // No need to add this location request, because location services are turned off device-wide, or the user has denied this app permissions to use them
        [self completeLocationRequest:locationRequest];
        return;
    }

    switch (locationRequest.type) {
        case SSHelpLocationRequestTypeSingle:
        case SSHelpLocationRequestTypeSubscription:
        {
            SSLocationAccuracy maximumDesiredAccuracy = SSLocationAccuracyNone;
            // Determine the maximum desired accuracy for all existing location requests (does not include the new request we're currently adding)
            for (SSHelpLocationRequest *locationRequest in [self activeLocationRequestsExcludingType:SSHelpLocationRequestTypeSignificantChanges]) {
                if (locationRequest.desiredAccuracy > maximumDesiredAccuracy) {
                    maximumDesiredAccuracy = locationRequest.desiredAccuracy;
                }
            }
            // Take the max of the maximum desired accuracy for all existing location requests and the desired accuracy of the new request we're currently adding
            maximumDesiredAccuracy = MAX(locationRequest.desiredAccuracy, maximumDesiredAccuracy);
            [self updateWithMaximumDesiredAccuracy:maximumDesiredAccuracy];
            [self updateWithDesiredActivityType:locationRequest.desiredActivityType];

            [self startUpdatingLocationIfNeeded];
        }
            break;
        case SSHelpLocationRequestTypeSignificantChanges:
            [self startMonitoringSignificantLocationChangesIfNeeded];
            break;
    }
    __SSLOC_GENERICS(NSMutableArray, SSHelpLocationRequest *) *newLocationRequests = [NSMutableArray arrayWithArray:self.locationRequests];
    [newLocationRequests addObject:locationRequest];
    self.locationRequests = newLocationRequests;
    SSLog(@"Location Request added with ID: %ld", (long)locationRequest.requestID);

    // Process all location requests now, as we may be able to immediately complete the request just added above
    // if a location update was recently received (stored in self.currentLocation) that satisfies its criteria.
    [self processLocationRequests];
}

/**
 Removes a given location request from the array of requests, updates the maximum desired accuracy, and stops location updates if needed.
 */
- (void)removeLocationRequest:(SSHelpLocationRequest *)locationRequest
{
    __SSLOC_GENERICS(NSMutableArray, SSHelpLocationRequest *) *newLocationRequests = [NSMutableArray arrayWithArray:self.locationRequests];
    [newLocationRequests removeObject:locationRequest];
    self.locationRequests = newLocationRequests;

    switch (locationRequest.type) {
        case SSHelpLocationRequestTypeSingle:
        case SSHelpLocationRequestTypeSubscription:
        {
            // Determine the maximum desired accuracy for all remaining location requests
            SSLocationAccuracy maximumDesiredAccuracy = SSLocationAccuracyNone;
            for (SSHelpLocationRequest *locationRequest in [self activeLocationRequestsExcludingType:SSHelpLocationRequestTypeSignificantChanges]) {
                if (locationRequest.desiredAccuracy > maximumDesiredAccuracy) {
                    maximumDesiredAccuracy = locationRequest.desiredAccuracy;
                }
            }
            [self updateWithMaximumDesiredAccuracy:maximumDesiredAccuracy];

            [self stopUpdatingLocationIfPossible];
        }
            break;
        case SSHelpLocationRequestTypeSignificantChanges:
            [self stopMonitoringSignificantLocationChangesIfPossible];
            break;
    }
}

/**
 Returns the most recent current location, or nil if the current location is unknown, invalid, or stale.
 */
- (CLLocation *)currentLocation
{
    if (_currentLocation) {
        // Location isn't nil, so test to see if it is valid
        if (!CLLocationCoordinate2DIsValid(_currentLocation.coordinate) || (_currentLocation.coordinate.latitude == 0.0 && _currentLocation.coordinate.longitude == 0.0)) {
            // The current location is invalid; discard it and return nil
            _currentLocation = nil;
        }
    }

    // Location is either nil or valid at this point, return it
    return _currentLocation;
}

/**
 Requests permission to use location services on devices with iOS 8+.
 */
- (void)requestAuthorizationIfNeeded
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    // As of iOS 8, apps must explicitly request location services permissions. SSHelpLocationManager supports both levels, "Always" and "When In Use".
    // SSHelpLocationManager determines which level of permissions to request based on which description key is present in your app's Info.plist
    // If you provide values for both description keys, the more permissive "Always" level is requested.

    double iOSVersion = floor(NSFoundationVersionNumber);
    BOOL isiOSVersion7to10 = iOSVersion > NSFoundationVersionNumber_iOS_7_1 && iOSVersion <= NSFoundationVersionNumber10_11_Max;
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        BOOL canRequestAlways = NO;
        BOOL canRequestWhenInUse = NO;
        if (isiOSVersion7to10) {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        } else {
            canRequestAlways = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationAlwaysAndWhenInUseUsageDescription"] != nil;
            canRequestWhenInUse = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"NSLocationWhenInUseUsageDescription"] != nil;
        }
        BOOL needRequestAlways = NO;
        BOOL needRequestWhenInUse = NO;
        switch (self.preferredAuthorizationType) {
            case SSAuthorizationTypeAuto:
                needRequestAlways = canRequestAlways;
                needRequestWhenInUse = canRequestWhenInUse;
                break;
            case SSAuthorizationTypeAlways:
                needRequestAlways = canRequestAlways;
                break;
            case SSAuthorizationTypeWhenInUse:
                needRequestWhenInUse = canRequestWhenInUse;
                break;

            default:
                break;
        }
        if (needRequestAlways) {
            [self.locationManager requestAlwaysAuthorization];
        } else if (needRequestWhenInUse) {
            [self.locationManager requestWhenInUseAuthorization];
        } else {
            if (isiOSVersion7to10) {
                // At least one of the keys NSLocationAlwaysUsageDescription or NSLocationWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 8+.
                NSAssert(canRequestAlways || canRequestWhenInUse, @"To use location services in iOS 8+, your Info.plist must provide a value for either NSLocationWhenInUseUsageDescription or NSLocationAlwaysUsageDescription.");
            } else {
                // Key NSLocationAlwaysAndWhenInUseUsageDescription MUST be present in the Info.plist file to use location services on iOS 11+.
                NSAssert(canRequestAlways, @"To use location services in iOS 11+, your Info.plist must provide a value for NSLocationAlwaysAndWhenInUseUsageDescription.");
            }
        }
    }
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1 */
}

/**
 Sets the CLLocationManager desiredAccuracy based on the given maximum desired accuracy (which should be the maximum desired accuracy of all active location requests).
 */
- (void)updateWithMaximumDesiredAccuracy:(SSLocationAccuracy)maximumDesiredAccuracy
{
    switch (maximumDesiredAccuracy) {
        case SSLocationAccuracyNone:
            break;
        case SSLocationAccuracyCity:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyThreeKilometers) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
                SSLog(@"Changing location services accuracy level to: low (minimum).");
            }
            break;
        case SSLocationAccuracyNeighborhood:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyKilometer) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
                SSLog(@"Changing location services accuracy level to: medium low.");
            }
            break;
        case SSLocationAccuracyBlock:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyHundredMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
                SSLog(@"Changing location services accuracy level to: medium.");
            }
            break;
        case SSLocationAccuracyHouse:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyNearestTenMeters) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                SSLog(@"Changing location services accuracy level to: medium high.");
            }
            break;
        case SSLocationAccuracyRoom:
            if (self.locationManager.desiredAccuracy != kCLLocationAccuracyBest) {
                self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
                SSLog(@"Changing location services accuracy level to: high (maximum).");
            }
            break;
        default:
            NSAssert(nil, @"Invalid maximum desired accuracy!");
            break;
    }
}

/**
 Sets the CLLocationManager desiredActivityType
 */
- (void)updateWithDesiredActivityType:(CLActivityType)desiredActivityType
{
    if (@available(iOS 12.0, *)) {
        if (desiredActivityType == CLActivityTypeAirborne) {
            self.locationManager.activityType = CLActivityTypeAirborne;
            SSLog(@"Changing location services activity type to: airborne.");
            return;
        }
    }
    
    switch (desiredActivityType) {
        case CLActivityTypeFitness:
            self.locationManager.activityType = CLActivityTypeFitness;
            SSLog(@"Changing location services activity type to: fitness.");
            break;
        case CLActivityTypeAutomotiveNavigation:
            self.locationManager.activityType = CLActivityTypeAutomotiveNavigation;
            SSLog(@"Changing location services activity type to: automotive navigation.");
            break;
        case CLActivityTypeOtherNavigation:
            self.locationManager.activityType = CLActivityTypeOtherNavigation;
            SSLog(@"Changing location services activity type to: other navigation.");
            break;
        case CLActivityTypeOther:
        default:
            self.locationManager.activityType = CLActivityTypeOther;
            break;
    }
}

/**
 Inform CLLocationManager to start monitoring significant location changes.
 */
- (void)startMonitoringSignificantLocationChangesIfNeeded
{
    [self requestAuthorizationIfNeeded];

    NSArray *locationRequests = [self activeLocationRequestsWithType:SSHelpLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager startMonitoringSignificantLocationChanges];
        if (self.isMonitoringSignificantLocationChanges == NO) {
            SSLog(@"Significant location change monitoring has started.")
        }
        self.isMonitoringSignificantLocationChanges = YES;
    }
}

/**
 Inform CLLocationManager to start sending us updates to our location.
 */
- (void)startUpdatingLocationIfNeeded
{
    [self requestAuthorizationIfNeeded];

    NSArray *locationRequests = [self activeLocationRequestsExcludingType:SSHelpLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager startUpdatingLocation];
        if (self.isUpdatingLocation == NO) {
            SSLog(@"Location services updates have started.");
        }
        self.isUpdatingLocation = YES;
    }
}

- (void)stopMonitoringSignificantLocationChangesIfPossible
{
    NSArray *locationRequests = [self activeLocationRequestsWithType:SSHelpLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager stopMonitoringSignificantLocationChanges];
        if (self.isMonitoringSignificantLocationChanges) {
            SSLog(@"Significant location change monitoring has stopped.");
        }
        self.isMonitoringSignificantLocationChanges = NO;
    }
}

/**
 Checks to see if there are any outstanding locationRequests, and if there are none, informs CLLocationManager to stop sending
 location updates. This is done as soon as location updates are no longer needed in order to conserve the device's battery.
 */
- (void)stopUpdatingLocationIfPossible
{
    NSArray *locationRequests = [self activeLocationRequestsExcludingType:SSHelpLocationRequestTypeSignificantChanges];
    if (locationRequests.count == 0) {
        [self.locationManager stopUpdatingLocation];
        if (self.isUpdatingLocation) {
            SSLog(@"Location services updates have stopped.");
        }
        self.isUpdatingLocation = NO;
    }
}

/**
 Iterates over the array of active location requests to check and see if the most recent current location
 successfully satisfies any of their criteria.
 */
- (void)processLocationRequests
{
    CLLocation *mostRecentLocation = self.currentLocation;

    for (SSHelpLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.hasTimedOut) {
            // Non-recurring request has timed out, complete it
            [self completeLocationRequest:locationRequest];
            continue;
        }

        if (mostRecentLocation != nil) {
            if (locationRequest.isRecurring) {
                // This is a subscription request, which lives indefinitely (unless manually canceled) and receives every location update we get
                [self processRecurringRequest:locationRequest];
                continue;
            } else {
                // This is a regular one-time location request
                NSTimeInterval currentLocationTimeSinceUpdate = fabs([mostRecentLocation.timestamp timeIntervalSinceNow]);
                CLLocationAccuracy currentLocationHorizontalAccuracy = mostRecentLocation.horizontalAccuracy;
                NSTimeInterval staleThreshold = [locationRequest updateTimeStaleThreshold];
                CLLocationAccuracy horizontalAccuracyThreshold = [locationRequest horizontalAccuracyThreshold];
                SSLog(@"compare：(%lf vs %lf) (%lf vs %lf)",currentLocationTimeSinceUpdate,staleThreshold,currentLocationHorizontalAccuracy,horizontalAccuracyThreshold);

                if (currentLocationTimeSinceUpdate <= staleThreshold &&
                    currentLocationHorizontalAccuracy <= horizontalAccuracyThreshold) {
                    // The request's desired accuracy has been reached, complete it
                    [self completeLocationRequest:locationRequest];
                    continue;
                }
            }
        }
    }
}

/**
 Immediately completes all active location requests.
 Used in cases such as when the location services authorization status changes to Denied or Restricted.
 */
- (void)completeAllLocationRequests
{
    // Iterate through a copy of the locationRequests array to avoid modifying the same array we are removing elements from
    __SSLOC_GENERICS(NSArray, SSHelpLocationRequest *) *locationRequests = [self.locationRequests copy];
    for (SSHelpLocationRequest *locationRequest in locationRequests) {
        [self completeLocationRequest:locationRequest];
    }
    SSLog(@"Finished completing all location requests.");
}

/**
 Completes the given location request by removing it from the array of locationRequests and executing its completion block.
 */
- (void)completeLocationRequest:(SSHelpLocationRequest *)locationRequest
{
    if (locationRequest == nil) {
        return;
    }

    [locationRequest complete];
    SSHelpLocationRequest *tmpLocationRequest = locationRequest;
    [self removeLocationRequest:locationRequest];

    SSLocationStatus status = [self statusForLocationRequest:tmpLocationRequest];
    CLLocation *currentLocation = self.currentLocation;
    SSLocationAccuracy achievedAccuracy = [self achievedAccuracyForLocation:currentLocation];

    // SSHelpLocationManager is not thread safe and should only be called from the main thread, so we should already be executing on the main thread now.
    // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned, for example in the
    // case where the user has denied permission to access location services and the request is immediately completed with the appropriate error.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (tmpLocationRequest && tmpLocationRequest.block) {
            tmpLocationRequest.block(currentLocation, achievedAccuracy, status);
        }
    });

    SSLog(@"Location Request completed with ID: %ld, currentLocation: %@, achievedAccuracy: %lu, status: %lu", (long)locationRequest.requestID, currentLocation, (unsigned long) achievedAccuracy, (unsigned long)status);
}

/**
 Handles calling a recurring location request's block with the current location.
 */
- (void)processRecurringRequest:(SSHelpLocationRequest *)locationRequest
{
    NSAssert(locationRequest.isRecurring, @"This method should only be called for recurring location requests.");

    SSLocationStatus status = [self statusForLocationRequest:locationRequest];
    CLLocation *currentLocation = self.currentLocation;
    SSLocationAccuracy achievedAccuracy = [self achievedAccuracyForLocation:currentLocation];

    // SSHelpLocationManager is not thread safe and should only be called from the main thread, so we should already be executing on the main thread now.
    // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (locationRequest.block) {
            locationRequest.block(currentLocation, achievedAccuracy, status);
        }
    });
}

/**
 Returns all active location requests with the given type.
 */
- (NSArray *)activeLocationRequestsWithType:(SSHelpLocationRequestType)locationRequestType
{
    return [self.locationRequests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SSHelpLocationRequest *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.type == locationRequestType;
    }]];
}

/**
 Returns all active location requests excluding requests with the given type.
 */
- (NSArray *)activeLocationRequestsExcludingType:(SSHelpLocationRequestType)locationRequestType
{
    return [self.locationRequests filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(SSHelpLocationRequest *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.type != locationRequestType;
    }]];
}

/**
 Returns the location manager status for the given location request.
 */
- (SSLocationStatus)statusForLocationRequest:(SSHelpLocationRequest *)locationRequest
{
    SSLocationServicesState locationServicesState = [self locationServicesState];

    if (locationServicesState == SSLocationServicesStateDisabled) {
        return SSLocationStatusServicesDisabled;
    }
    else if (locationServicesState == SSLocationServicesStateNotDetermined) {
        return SSLocationStatusServicesNotDetermined;
    }
    else if (locationServicesState == SSLocationServicesStateDenied) {
        return SSLocationStatusServicesDenied;
    }
    else if (locationServicesState == SSLocationServicesStateRestricted) {
        return SSLocationStatusServicesRestricted;
    }
    else if (self.updateFailed) {
        return SSLocationStatusError;
    }
    else if (locationRequest.hasTimedOut) {
        return SSLocationStatusTimedOut;
    }

    return SSLocationStatusSuccess;
}

/**
 Returns the associated SSLocationAccuracy level that has been achieved for a given location,
 based on that location's horizontal accuracy and recency.
 */
- (SSLocationAccuracy)achievedAccuracyForLocation:(CLLocation *)location
{
    if (!location) {
        return SSLocationAccuracyNone;
    }

    NSTimeInterval timeSinceUpdate = fabs([location.timestamp timeIntervalSinceNow]);
    CLLocationAccuracy horizontalAccuracy = location.horizontalAccuracy;

    if (horizontalAccuracy <= kSSLOCHorizontalAccuracyThresholdRoom &&
        timeSinceUpdate <= kSSLOCUpdateTimeStaleThresholdRoom) {
        return SSLocationAccuracyRoom;
    }
    else if (horizontalAccuracy <= kSSLOCHorizontalAccuracyThresholdHouse &&
             timeSinceUpdate <= kSSLOCUpdateTimeStaleThresholdHouse) {
        return SSLocationAccuracyHouse;
    }
    else if (horizontalAccuracy <= kSSLOCHorizontalAccuracyThresholdBlock &&
             timeSinceUpdate <= kSSLOCUpdateTimeStaleThresholdBlock) {
        return SSLocationAccuracyBlock;
    }
    else if (horizontalAccuracy <= kSSLOCHorizontalAccuracyThresholdNeighborhood &&
             timeSinceUpdate <= kSSLOCUpdateTimeStaleThresholdNeighborhood) {
        return SSLocationAccuracyNeighborhood;
    }
    else if (horizontalAccuracy <= kSSLOCHorizontalAccuracyThresholdCity &&
             timeSinceUpdate <= kSSLOCUpdateTimeStaleThresholdCity) {
        return SSLocationAccuracyCity;
    }
    else {
        return SSLocationAccuracyNone;
    }
}

#pragma mark Internal heading methods

/**
 Returns the most recent heading, or nil if the current heading is unknown or invalid.
 */
- (CLHeading *)currentHeading
{
    // Heading isn't nil, so test to see if it is valid
    if (!INTUCLHeadingIsIsValid(_currentHeading)) {
        // The current heading is invalid; discard it and return nil
        _currentHeading = nil;
    }

    // Heading is either nil or valid at this point, return it
    return _currentHeading;
}

/**
 Checks whether the given @c CLHeading has valid properties.
 */
BOOL INTUCLHeadingIsIsValid(CLHeading *heading)
{
    return heading.trueHeading > 0 &&
           heading.headingAccuracy > 0;
}

/**
 Adds the given heading request to the array of requests and starts heading updates.
 */
- (void)addHeadingRequest:(SSHelpHeadingRequest *)headingRequest
{
    NSAssert(headingRequest, @"Must pass in a non-nil heading request.");

    // If heading services are not available, just return
    if ([SSHelpLocationManager headingServicesState] == SSHeadingServicesStateUnavailable) {
        // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (headingRequest.block) {
                headingRequest.block(nil, SSHeadingStatusUnavailable);
            }
        });
        SSLog(@"Heading Request (ID %ld) NOT added since device heading is unavailable.", (long)headingRequest.requestID);
        return;
    }

    __SSLOC_GENERICS(NSMutableArray, SSHelpHeadingRequest *) *newHeadingRequests = [NSMutableArray arrayWithArray:self.headingRequests];
    [newHeadingRequests addObject:headingRequest];
    self.headingRequests = newHeadingRequests;
    SSLog(@"Heading Request added with ID: %ld", (long)headingRequest.requestID);

    [self startUpdatingHeadingIfNeeded];
}

/**
 Inform CLLocationManager to start sending us updates to our heading.
 */
- (void)startUpdatingHeadingIfNeeded
{
    if (self.headingRequests.count != 0) {
        [self.locationManager startUpdatingHeading];
        if (self.isUpdatingHeading == NO) {
            SSLog(@"Heading services updates have started.");
        }
        self.isUpdatingHeading = YES;
    }
}

/**
 Removes a given heading request from the array of requests and stops heading updates if needed.
 */
- (void)removeHeadingRequest:(SSHelpHeadingRequest *)headingRequest
{
    __SSLOC_GENERICS(NSMutableArray, SSHelpHeadingRequest *) *newHeadingRequests = [NSMutableArray arrayWithArray:self.headingRequests];
    [newHeadingRequests removeObject:headingRequest];
    self.headingRequests = newHeadingRequests;

    [self stopUpdatingHeadingIfPossible];
}

/**
 Checks to see if there are any outstanding headingRequests, and if there are none, informs CLLocationManager to stop sending
 heading updates. This is done as soon as heading updates are no longer needed in order to conserve the device's battery.
 */
- (void)stopUpdatingHeadingIfPossible
{
    if (self.headingRequests.count == 0) {
        [self.locationManager stopUpdatingHeading];
        if (self.isUpdatingHeading) {
            SSLog(@"Location services heading updates have stopped.");
        }
        self.isUpdatingHeading = NO;
    }
}

/**
 Iterates over the array of active heading requests and processes each
 */
- (void)processRecurringHeadingRequests
{
    for (SSHelpHeadingRequest *headingRequest in self.headingRequests) {
        [self processRecurringHeadingRequest:headingRequest];
    }
}

/**
 Handles calling a recurring heading request's block with the current heading.
 */
- (void)processRecurringHeadingRequest:(SSHelpHeadingRequest *)headingRequest
{
    NSAssert(headingRequest.isRecurring, @"This method should only be called for recurring heading requests.");

    SSHeadingStatus status = [self statusForHeadingRequest:headingRequest];

    // Check if the request had a fatal error and should be canceled
    if (status == SSHeadingStatusUnavailable) {
        // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
        dispatch_async(dispatch_get_main_queue(), ^{
            if (headingRequest.block) {
                headingRequest.block(nil, status);
            }
        });

        [self cancelHeadingRequest:headingRequest.requestID];
        return;
    }

    // dispatch_async is used to ensure that the completion block for a request is not executed before the request ID is returned.
    dispatch_async(dispatch_get_main_queue(), ^{
        if (headingRequest.block) {
            headingRequest.block(self.currentHeading, status);
        }
    });
}

/**
 Returns the status for the given heading request.
 */
- (SSHeadingStatus)statusForHeadingRequest:(SSHelpHeadingRequest *)headingRequest
{
    if ([SSHelpLocationManager headingServicesState] == SSHeadingServicesStateUnavailable) {
        return SSHeadingStatusUnavailable;
    }

    // The accessor will return nil for an invalid heading results
    if (!self.currentHeading) {
        return SSHeadingStatusInvalid;
    }

    return SSHeadingStatusSuccess;
}

#pragma mark SSHelpLocationRequestDelegate method

- (void)locationRequestDidTimeout:(SSHelpLocationRequest *)locationRequest
{
    // For robustness, only complete the location request if it is still active (by checking to see that it hasn't been removed from the locationRequests array).
    for (SSHelpLocationRequest *activeLocationRequest in self.locationRequests) {
        if (activeLocationRequest.requestID == locationRequest.requestID) {
            [self completeLocationRequest:locationRequest];
            break;
        }
    }
}

#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    // Received update successfully, so clear any previous errors
    self.updateFailed = NO;

    CLLocation *mostRecentLocation = [locations lastObject];
    SSLog(@"Received update locations: (%f,%f)",mostRecentLocation.coordinate.latitude,mostRecentLocation.coordinate.longitude);

    self.currentLocation = mostRecentLocation;

    // Process the location requests using the updated location
    [self processLocationRequests];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    self.currentHeading = newHeading;

    // Process the heading requests using the updated heading
    [self processRecurringHeadingRequests];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    SSLog(@"Location services error: %@", [error localizedDescription]);
    SSLocationServicesState locationServicesState = [self locationServicesState];
    if (SSLocationServicesStateNotDetermined == locationServicesState) {
        //测试发现，存在等待授权中，会回调此接口现象，因此在这里特殊处理一下
        return;
    }
    self.updateFailed = YES;

    for (SSHelpLocationRequest *locationRequest in self.locationRequests) {
        if (locationRequest.isRecurring) {
            // Keep the recurring request alive
            [self processRecurringRequest:locationRequest];
        } else {
            // Fail any non-recurring requests
            [self completeLocationRequest:locationRequest];
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusDenied || status == kCLAuthorizationStatusRestricted) {
        // Clear out any active location requests (which will execute the blocks with a status that reflects
        // the unavailability of location services) since we now no longer have location services permissions
        [self completeAllLocationRequests];
    }
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
    else if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
#else
    else if (status == kCLAuthorizationStatusAuthorized) {
#endif /* __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1 */

        // Start the timeout timer for location requests that were waiting for authorization
        for (SSHelpLocationRequest *locationRequest in self.locationRequests) {
            [locationRequest startTimeoutTimerIfNeeded];
        }
    }
}

#pragma mark - Additions
/** It is possible to force enable background location fetch even if your set any kind of Authorizations */
- (void)setBackgroundLocationUpdate:(BOOL)enabled
{
    if (@available(iOS 9, *)) {
        _locationManager.allowsBackgroundLocationUpdates = enabled;
    }
}

- (void)setShowsBackgroundLocationIndicator:(BOOL)shows
{
    if (@available(iOS 11, *)) {
        _locationManager.showsBackgroundLocationIndicator = shows;
    }
}

- (void)setPausesLocationUpdatesAutomatically:(BOOL)pauses
{
    _locationManager.pausesLocationUpdatesAutomatically = pauses;
}
    
@end
