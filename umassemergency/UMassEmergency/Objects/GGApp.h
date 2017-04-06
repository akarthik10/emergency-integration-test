//
//  GGApp.h
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GGDataManager.h"
#import "GGHazard.h"
#import "UMassEmergency-Swift.h"
#import "KeychainItemWrapper.h"
#import "GGCamera.h"

static NSString *GGUpdateHazardsOnMapNotification = @"GGUpdateHazardsOnMapNotification";

@protocol GGAppLocationDelegate;
@protocol GGAppTimerDelegate;
@protocol GGAppDataDelegate;
@protocol GGAppInternetConnectionDelegate;
@interface GGApp : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableSet *locationDelegates;
@property (nonatomic, strong) NSMutableSet *statusBarDelegates;

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) GGDataManager *dataManager;

@property (nonatomic, strong) GGUser *user;

@property (nonatomic, strong) GGCamera *camera;

@property (nonatomic, readwrite) BOOL statusBarHidden;

+(GGApp *)instance;

-(BOOL)isLocationServicesEnabled;
-(void)forceUpdateLocation;
-(void)startLocationManager;
-(void)updateLocationInBackground:(CLLocation *)newLocation withCompletion:(void (^)(BOOL successful))completionBlock;
-(void)addLocationDelegate:(id<GGAppLocationDelegate>)delegate;
-(void)removeLocationDelegate:(id<GGAppLocationDelegate>)delegate;

-(void)addTimerDelegate:(id<GGAppTimerDelegate>)delegate;
-(void)removeTimerDelegate:(id<GGAppTimerDelegate>)delegate;

-(void)updateAlerts:(BOOL)force;
-(void)addDataDelegate:(id<GGAppDataDelegate>)delegate;
-(void)removeDataDelegate:(id<GGAppDataDelegate>)delegate;

-(void)startTimer;
-(void)stopTimer;

-(BOOL)internetConnectionAvailable;
-(BOOL)internetConnectionAvailableViaWifi;
-(void)addInternetConnectionDelegate:(id<GGAppInternetConnectionDelegate>)delegate;
-(void)removeInternetConnectionDelegate:(id<GGAppInternetConnectionDelegate>)delegate;

-(void)uploadDeviceTokenWithCompletion:(void (^)(NSString *error))completionBlock;

@end

@protocol GGAppInternetConnectionDelegate <NSObject>

-(void)app:(GGApp *)app didChangeInternetConnectionStatus:(AFNetworkReachabilityStatus)status;

@end

@protocol GGAppLocationDelegate <NSObject>

-(void)app:(GGApp *)app didUpdateLocations:(NSArray *)locations;
-(void)app:(GGApp *)app didUpdateHeading:(CLHeading *)heading;
@optional
-(void)app:(GGApp *)app didChangeAuthorizationStatus:(CLAuthorizationStatus)status;

@end

@protocol GGAppTimerDelegate <NSObject>

-(void)app:(GGApp *)app timerDidFire:(NSUInteger)timerCounter;

@end

@protocol GGAppDataDelegate <NSObject>

-(void)appDidUpdateRadarImages:(GGApp *)app;
-(void)appDidUpdateHazards:(GGApp *)app;

@end


@protocol GGAppStatusBarDelegate <NSObject>

-(void)app:(GGApp *)app didUpdateStatusBarHidden:(BOOL)hidden;

@end
