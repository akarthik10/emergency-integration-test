//
//  GGApp.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 25.03.15.
//  Copyright (c) 2015 University of Massachusetts.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you
//  may not use this file except in compliance with the License. You
//  may obtain a copy of the License at
//  
//  http://www.apache.org/licenses/LICENSE-2.0
//  
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
//  implied. See the License for the specific language governing
//  permissions and limitations under the License.
//

#import "GGApp.h"
#import "GGGeoJSON.h"
#import "GGUser.h"
#import "GGGNSManager.h"

#include <ifaddrs.h>
#include <arpa/inet.h>
#include <net/if.h>

#define IOS_CELLULAR    @"pdp_ip0"
#define IOS_WIFI        @"en0"
#define IP_ADDR_IPv4    @"ipv4"
#define IP_ADDR_IPv6    @"ipv6"

@interface GGApp ()

@property (nonatomic, strong) ClientBridge *clientBridge;
@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSOperationQueue *queue;

@property (nonatomic, readwrite) NSInteger timerCounter;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) NSMutableSet *timerDelegates;

@property (nonatomic, strong) NSMutableSet *dataDelegates;

@property (nonatomic, strong) NSMutableSet *internetConnectionDelegates;

@property (nonatomic, strong) GGGNSManager *gns;
@property (nonatomic, strong) CLLocation *currentLocation;

@end

static GGApp *instance = nil;

@implementation GGApp


#pragma mark - Status Bar

-(void)setStatusBarHidden:(BOOL)statusBarHidden
{
    _statusBarHidden = statusBarHidden;
    
    for (id<GGAppStatusBarDelegate> delegate in self.statusBarDelegates) {
        if ([delegate respondsToSelector:@selector(app:didUpdateStatusBarHidden:)]) {
            [delegate app:self didUpdateStatusBarHidden:statusBarHidden];
        }
    }
}

-(void)addStatusBarDelegate:(id<GGAppStatusBarDelegate>)delegate
{
    [self.statusBarDelegates addObject:delegate];
}

-(void)removeStatusBarDelegate:(id<GGAppStatusBarDelegate>)delegate
{
    [self.statusBarDelegates removeObject:delegate];
}

#pragma mark - Internet Connection

-(BOOL)internetConnectionAvailable
{
    return [AFNetworkReachabilityManager sharedManager].reachable;
}

-(BOOL)internetConnectionAvailableViaWifi
{
    return [AFNetworkReachabilityManager sharedManager].reachableViaWiFi;
}

-(void)notifyReachabilityChange:(AFNetworkReachabilityStatus)status
{
    for (id<GGAppInternetConnectionDelegate> delegate in self.internetConnectionDelegates) {
        if ([delegate respondsToSelector:@selector(app:didChangeInternetConnectionStatus:)]) {
            [delegate app:self didChangeInternetConnectionStatus:status];
        }
    }
}

-(void)addInternetConnectionDelegate:(id<GGAppInternetConnectionDelegate>)delegate
{
    [self.internetConnectionDelegates addObject:delegate];
}

-(void)removeInternetConnectionDelegate:(id<GGAppInternetConnectionDelegate>)delegate
{
    [self.internetConnectionDelegates removeObject:delegate];
}



- (NSString *)getIPAddress:(BOOL)preferIPv4
{
    NSArray *searchArray = preferIPv4 ?
    @[  IOS_WIFI @"/" IP_ADDR_IPv4, IOS_WIFI @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6 ] :
    @[  IOS_WIFI @"/" IP_ADDR_IPv6, IOS_WIFI @"/" IP_ADDR_IPv4, IOS_CELLULAR @"/" IP_ADDR_IPv6, IOS_CELLULAR @"/" IP_ADDR_IPv4 ] ;
    
    NSDictionary *addresses = [self getIPAddresses];
    NSLog(@"addresses: %@", addresses);
    
    __block NSString *address;
    [searchArray enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop)
     {
         address = addresses[key];
         if(address) *stop = YES;
     } ];
    return address ? address : @"0.0.0.0";
}

- (NSDictionary *)getIPAddresses
{
    NSMutableDictionary *addresses = [NSMutableDictionary dictionaryWithCapacity:8];
    
    // retrieve the current interfaces - returns 0 on success
    struct ifaddrs *interfaces;
    if(!getifaddrs(&interfaces)) {
        // Loop through linked list of interfaces
        struct ifaddrs *interface;
        for(interface=interfaces; interface; interface=interface->ifa_next) {
            if(!(interface->ifa_flags & IFF_UP)) {
                continue; // deeply nested code harder to read
            }
            const struct sockaddr_in *addr = (const struct sockaddr_in*)interface->ifa_addr;
            char addrBuf[ MAX(INET_ADDRSTRLEN, INET6_ADDRSTRLEN) ];
            if(addr && (addr->sin_family==AF_INET || addr->sin_family==AF_INET6)) {
                NSString *name = [NSString stringWithUTF8String:interface->ifa_name];
                NSString *type;
                if(addr->sin_family == AF_INET) {
                    if(inet_ntop(AF_INET, &addr->sin_addr, addrBuf, INET_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv4;
                    }
                } else {
                    const struct sockaddr_in6 *addr6 = (const struct sockaddr_in6*)interface->ifa_addr;
                    if(inet_ntop(AF_INET6, &addr6->sin6_addr, addrBuf, INET6_ADDRSTRLEN)) {
                        type = IP_ADDR_IPv6;
                    }
                }
                if(type) {
                    NSString *key = [NSString stringWithFormat:@"%@/%@", name, type];
                    addresses[key] = [NSString stringWithUTF8String:addrBuf];
                }
            }
        }
        // Free memory
        freeifaddrs(interfaces);
    }
    return [addresses count] ? addresses : nil;
}


#pragma mark - Location

-(BOOL)isLocationServicesEnabled
{
    return [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
}

-(void)startLocationManager
{
    if (!self.locationManager) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = 250.0;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.pausesLocationUpdatesAutomatically = YES;
    self.locationManager.activityType = CLActivityTypeOther;
    self.locationManager.allowsBackgroundLocationUpdates = NO;
    
    [self.locationManager startMonitoringSignificantLocationChanges];
    [self.locationManager startUpdatingLocation];
    [self.locationManager startUpdatingHeading];
}

-(void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            break;
            
        default:
            break;
    }
    
    for (id<GGAppLocationDelegate> delegate in self.locationDelegates) {
        if ([delegate respondsToSelector:@selector(app:didChangeAuthorizationStatus:)]) {
            [delegate app:self didChangeAuthorizationStatus:status];
        }
    }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    [manager stopUpdatingLocation];
    
    CLLocation *newLocation = locations.lastObject;
    
//    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//    XLog(@"Location age: %f",locationAge);
//    if (locationAge > 5.0) return;
//    
//    if (newLocation.horizontalAccuracy < 0) return;
    
    if (self.currentLocation && [newLocation.timestamp timeIntervalSinceDate:self.currentLocation.timestamp] < 2) {
        // new location update is old or too early (<1 seconds)
        return;
//        XLog(@"Location seconds: %f",[newLocation.timestamp timeIntervalSinceDate:self.currentLocation.timestamp]);
//        XLog(@"Current Location: %@",self.currentLocation.timestamp);
//        XLog(@"New Location: %@",newLocation.timestamp);
        if ([newLocation.timestamp timeIntervalSinceDate:self.currentLocation.timestamp] < 1) {
//            XLog(@"Too soon");
            return;
        }
    }
    
    self.currentLocation = newLocation;

    if ([UIApplication sharedApplication].applicationState != UIApplicationStateBackground && [GGConstants isLocationSimulated]) {
        GGLocation *location = [GGConstants simulatedLocation];
        newLocation = location;
    }
    
    [self updateLocationInBackground:newLocation withCompletion:nil];
    
    for (id<GGAppLocationDelegate> delegate in self.locationDelegates) {
        if ([delegate respondsToSelector:@selector(app:didUpdateLocations:)]) {
            [delegate app:self didUpdateLocations:locations];
        }
    }
}


-(void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    CLLocation *currentLocation = self.locationManager.location;
    if ([GGConstants isLocationSimulated]) {
        GGLocation *location = [GGConstants simulatedLocation];
        currentLocation = location;
    }
    
    [self.dataManager updateHazardsDirectionToHeading:newHeading andLocation:currentLocation];
    
    for (id<GGAppLocationDelegate> delegate in self.locationDelegates) {
        if ([delegate respondsToSelector:@selector(app:didUpdateHeading:)]) {
            [delegate app:self didUpdateHeading:newHeading];
        }
    }
    
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    
    XLog(@"Unable to start location manager. Error:%@", [error description]);
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    switch (status) {
        case kCLAuthorizationStatusAuthorizedAlways:
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            XLog(@"All OK");
            break;
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
        }
            break;
        case kCLAuthorizationStatusNotDetermined:
            XLog(@"No idea ?!");
            break;
    }
    
}

-(void)requestUpdateLocation
{
    [self.locationManager requestLocation];
}

-(void)forceUpdateLocation
{
    CLLocation *latestLocation = self.locationManager.location;
    
    if ([GGConstants isLocationSimulated]) {
        GGLocation *location = [GGConstants simulatedLocation];
        latestLocation = location;
    }
    
    if (latestLocation) {
        [self.dataManager updateHazardsDistanceToLocation:latestLocation];
        
//        for (id<GGAppLocationDelegate> delegate in self.locationDelegates) {
//            if ([delegate respondsToSelector:@selector(app:didUpdateLocations:)]) {
//                [delegate app:self didUpdateLocations:@[latestLocation]];
//            }
//        }
    }
}

-(void)updateLocationInBackground:(CLLocation *)newLocation withCompletion:(void (^)(BOOL successful))completionBlock
{
    XLog(@"Upload new location: %@",newLocation);
    
    UIApplication *application = [UIApplication sharedApplication];
    
    if (application.applicationState == UIApplicationStateActive) {
        [self.dataManager updateHazardsDistanceToLocation:newLocation];
    }
    
    GGGNSManager *gns = [GGGNSManager manager];
    if (application.applicationState == UIApplicationStateActive) {
        if (!(gns.guid && gns.connected)) {
            // gns not ready while app is running
            if (completionBlock) {
                completionBlock(NO);
            }
        }
    }
    
    if([[UIDevice currentDevice] respondsToSelector:@selector(isMultitaskingSupported)]) {
        
        __block UIBackgroundTaskIdentifier background_task;
        background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
            
            //Clean up code. Tell the system that we are done.
            [application endBackgroundTask: background_task];
            background_task = UIBackgroundTaskInvalid;
            
        }];
        
        
        //To make the code block asynchronous
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            UIApplication *application = [UIApplication sharedApplication];
            GGGNSManager *gns = [GGGNSManager manager];
            
            // update GNS records
            [gns loadGNSAccountWithCompletion:^(NSString *error) {
                
                if (error) {
                    XLog(@"Load GNS Error: %@",error);
                    
                    if (completionBlock) {
                        completionBlock(NO);
                    }
                    
                    [application endBackgroundTask:background_task];
                    background_task = UIBackgroundTaskInvalid;
                    //#### background task ends
                    return;
                }
                
                GGGeoJSON *geoJSON = [[GGGeoJSON alloc] initWithPoint:newLocation.coordinate];
                
                [gns writeField:@"geoLocationCurrent" value:geoJSON.geoJSON completion:^(NSString *error) {
                    if (error) {
                        XLog(@"Write Location Error: %@",error);
                    }else{
                        XLog(@"geoLocationCurrent WRITTEN");
                        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                            XLog(@"Time remaing: %.2f",application.backgroundTimeRemaining);
                        }
                        
                        [gns writeField:@"geoLocationUpdated" value:@"true" completion:^(NSString *error) {
                            
                            if (error) {
                                XLog(@"Write geoLocationUpdated Error: %@",error);
                            }else{
                                XLog(@"geoLocationUpdated WRITTEN");
                                if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                                    XLog(@"Time remaing: %.2f",application.backgroundTimeRemaining);
                                }
                            }
                            
                            NSString *timestamp = [NSString stringWithFormat:@"%f",[newLocation.timestamp timeIntervalSince1970]];
                            
                            [gns writeField:@"geoLocationCurrentTimestamp" value:timestamp completion:^(NSString *error) {
                                
                                if (error) {
                                    XLog(@"Write geoLocationCurrentTimestamp Error: %@",error);
                                }else{
                                    XLog(@"geoLocationCurrentTimestamp WRITTEN");
                                    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                                        XLog(@"Time remaing: %.2f",application.backgroundTimeRemaining);
                                    }
                                }
                                
                                NSString *datetime = [NSString stringWithFormat:@"%@",[newLocation.timestamp description]];
                                
                                [gns writeField:@"geoLocationCurrentDatetime" value:datetime completion:^(NSString *error) {
                                    
                                    if (error) {
                                        XLog(@"Write geoLocationCurrentDatetime Error: %@",error);
                                    }else{
                                        XLog(@"geoLocationCurrentDatetime WRITTEN");
                                        if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground){
                                            XLog(@"Time remaing: %.2f",application.backgroundTimeRemaining);
                                        }
                                    }
                                    
                                    if (completionBlock) {
                                        completionBlock(YES);
                                    }
                                    
                                    [application endBackgroundTask:background_task];
                                    background_task = UIBackgroundTaskInvalid;
                                    //#### background task ends
                                }];
                            }];
                        }];
                    }
                }];
            }];
        });
    }
}

-(void)addLocationDelegate:(id<GGAppLocationDelegate>)delegate
{
    [self.locationDelegates addObject:delegate];
}

-(void)removeLocationDelegate:(id<GGAppLocationDelegate>)delegate
{
    [self.locationDelegates removeObject:delegate];
}


#pragma mark -

-(void)uploadAppDataWithCompletion:(void (^)(NSString *error))completionBlock
{
    [self uploadDeviceTokenWithCompletion:^(NSString *error) {
        [self uploadBundleIDWithCompletion:^(NSString *error) {
            [self uploadAppVersionWithCompletion:^(NSString *error) {
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }];
    }];
}

-(void)uploadBundleIDWithCompletion:(void (^)(NSString *error))completionBlock
{
    NSString *bundleID = [[NSBundle mainBundle] bundleIdentifier];
    GGGNSManager *gns = [GGGNSManager manager];
    [gns writeField:@"accountID" value:bundleID completion:^(NSString *error) {
        
        if (completionBlock) {
            completionBlock(error);
        }
        
    }];
    
}

-(void)uploadAppVersionWithCompletion:(void (^)(NSString *error))completionBlock
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *majorVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    NSString *deviceSystem = @"ios";

    GGGNSManager *gns = [GGGNSManager manager];
    [gns writeField:@"appVersion" value:majorVersion completion:^(NSString *error) {
        
        [gns writeField:@"appBuild" value:minorVersion completion:^(NSString *error) {
            
            [gns writeField:@"deviceSystem" value:deviceSystem completion:^(NSString *error) {
                
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
            
        }];
        
    }];
}

-(void)uploadDeviceTokenWithCompletion:(void (^)(NSString *error))completionBlock
{
    if (self.deviceToken) {
        GGGNSManager *gns = [GGGNSManager manager];
        [gns writeField:@"deviceID" value:self.deviceToken completion:^(NSString *error) {
            if (error) {
                XLog(@"DEVICEID NOT WRITTEN: %@",error);
            }else{
                XLog(@"DEVICEID WRITTEN");
            }
            
            if (completionBlock) {
                completionBlock(nil);
            }
        }];
    }else{
        if (completionBlock) {
            completionBlock(@"No device token available");
        }
    }
}

#pragma mark - Timer

-(void)startTimer
{
    [self stopTimer];
    
    XLog(@"Starting Timer");
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    XLog(@"Timer started");
}

-(void)stopTimer
{
    if ([self.timer isValid]) {
        XLog(@"Stopping Timer");
        [self.timer invalidate];
        XLog(@"Timer stopped");
    }
    self.timer = nil;
    self.timerCounter = 0;
}

-(void)timerFired:(NSTimer *)timer
{
    self.timerCounter++;
    
    GGGNSManager *gns = [GGGNSManager manager];
    if(self.timerCounter%5 == 1) {
        
        if (!gns.connected && !gns.isConnecting) {
            
            XLog(@"GNS not connected");
            
            [gns loadGNSAccountWithCompletion:^(NSString *error) {
                if (error) {
                    XLog(@"Could not load GNS Account Error: %@",error);
                    GGGNSManager *gns = [GGGNSManager manager];
                    [gns disconnectGNS];
                }
            }];
            
        }else if (gns.isConnecting) {
            
            XLog(@"Connecting to GNS");
            
        }else if (gns.isLoadingAccount) {
            
            XLog(@"Loading GNS Account");
            
        }else if (!gns.guid && !gns.isConnecting && !gns.isLoadingAccount) {
            
            XLog(@"GNS connected but no guid available");
            [gns disconnectGNS];
            
            [gns loadGNSAccountWithCompletion:^(NSString *error) {
                if (error) {
                    XLog(@"Could not load GNS Account Error: %@",error);
                }
            }];
            
        }else{
            
        }
    }

    if(self.timerCounter%10 == 1) {
        [self updateAlerts:NO];
    }
    
    if(self.timerCounter%60 == 1) {

        // update location
        [self requestUpdateLocation];
    }
    
    for (id<GGAppTimerDelegate> delegate in self.timerDelegates) {
        if ([delegate respondsToSelector:@selector(app:timerDidFire:)]) {
            [delegate app:self timerDidFire:self.timerCounter];
        }
    }
}

-(void)addTimerDelegate:(id<GGAppTimerDelegate>)delegate
{
    [self.timerDelegates addObject:delegate];
}

-(void)removeTimerDelegate:(id<GGAppTimerDelegate>)delegate
{
    [self.timerDelegates removeObject:delegate];
}

#pragma mark -

-(void)updateAlerts:(BOOL)force
{
    __weak GGApp *weakApp = self;
    
    if (force) {
        
        [self.dataManager updateAlertsWithCompletion:^{
            GGApp *strongApp = weakApp;
            [strongApp forceUpdateLocation];
            for (id<GGAppDataDelegate> delegate in strongApp.dataDelegates) {
                if ([delegate respondsToSelector:@selector(appDidUpdateHazards:)]) {
                    [delegate appDidUpdateHazards:strongApp];
                }
            }
        }];
         
    }else{
        [self.dataManager updateAlertsWithCompletion:^{
            GGApp *strongApp = weakApp;
            [strongApp forceUpdateLocation];
            for (id<GGAppDataDelegate> delegate in strongApp.dataDelegates) {
                if ([delegate respondsToSelector:@selector(appDidUpdateHazards:)]) {
                    [delegate appDidUpdateHazards:strongApp];
                }
            }
        } tooEarly:^{
            GGApp *strongApp = weakApp;
            [strongApp forceUpdateLocation];
            for (id<GGAppDataDelegate> delegate in strongApp.dataDelegates) {
                if ([delegate respondsToSelector:@selector(appDidUpdateHazards:)]) {
                    [delegate appDidUpdateHazards:strongApp];
                }
            }
        }];
    }
    
}

-(void)addDataDelegate:(id<GGAppDataDelegate>)delegate
{
    [self.dataDelegates addObject:delegate];
}

-(void)removeDataDelegate:(id<GGAppDataDelegate>)delegate
{
    [self.dataDelegates removeObject:delegate];
}


#pragma mark -

-(void)gnsStatusChanged
{
    GGGNSManager *gns = [GGGNSManager manager];
    switch (gns.status) {
            
        case GGGNSStatusAccountLoaded:
        {
            if (gns.guid && gns.connected) {
                // account loaded
                // write username, id and app data into GNS
                __weak GGApp *weakSelf = self;
                [gns writeField:@"username" value:gns.username completion:^(NSString *error) {
                    
                    GGApp *strongSelf = weakSelf;
                    
                    [strongSelf uploadAppDataWithCompletion:^(NSString *error) {
                        
                        [strongSelf requestUpdateLocation];
                        
                        [strongSelf.dataManager downloadAttributesPreferencesWithCompletion:^(NSString *error) {
                            
                            if (error) {
                                XLog(@"Error: %@",error);
                            }
                        }];
                        
                    }];
                    
                }];
            }
        }
            break;
            
        default:
            break;
    }
}

-(GGUser *)user
{
    if (!_user) {
        _user = [[GGUser alloc] init];
    }
    return _user;
}

#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
        
        self.internetConnectionDelegates = [[NSMutableSet alloc] init];
        self.timerDelegates = [[NSMutableSet alloc] init];
        self.locationDelegates = [[NSMutableSet alloc] init];
        self.dataDelegates = [[NSMutableSet alloc] init];
        self.statusBarDelegates = [[NSMutableSet alloc] init];

        self.dataManager = [[GGDataManager alloc] init];
        
        [self startLocationManager];

        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            [self notifyReachabilityChange:status];
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];

        self.camera = [[GGCamera alloc] init];

        GGGNSManager *gns = [GGGNSManager manager];
        gns.username = self.user.gnsUsername;
        gns.password = self.user.gnsPassword;
        self.gns = gns;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gnsStatusChanged) name:GGGNSStatusChangeNotification object:nil];

    }
    return self;
}


#pragma mark - 

+(GGApp *)instance
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [[GGApp alloc] init];
        }
    }
    return instance;
}



@end
