//
//  GGConstants.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 12.05.15.
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

#import "GGConstants.h"
#import <Google/Analytics.h>

@implementation GGConstants

+(void)sendTrackingScreenName:(NSString *)name
{
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:name];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
}

#pragma mark - 

+(BOOL)useTabController
{
    return NO;
}

#pragma mark - Attributes

+(NSString *)attributesJSONURL
{
    return @"https://date.cs.umass.edu/notifier/campus/umass/ContextnetVisual/attributes.json";
}

#pragma mark - GNS

+(NSString *)gnsHost
{
    NSString *gnsHost = [[NSUserDefaults standardUserDefaults] valueForKey:@"gnsHost"];
    if (gnsHost) {
        return gnsHost;
    }
    return [GGConstants gnsDefaultHost];
}

+(NSString *)gnsDefaultHost
{
    return @"localhost";
    return @"hazard.hpcc.umass.edu";
}

+(void)setGNSHost:(NSString *)gnsHost
{
    [[NSUserDefaults standardUserDefaults] setValue:gnsHost forKey:@"gnsHost"];
}

+(NSInteger)gnsPort
{
    NSNumber *gnsPort = [[NSUserDefaults standardUserDefaults] valueForKey:@"gnsPort"];
    if (gnsPort) {
        return [gnsPort integerValue];
    }
    return [GGConstants gnsDefaultPort];
}

+(NSInteger)gnsDefaultPort
{
    return 24303;
}

+(void)setGNSPort:(NSInteger)gnsPort
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithInteger:gnsPort] forKey:@"gnsPort"];
}

+(NSString *)backendURL;
{
    NSString *backendURL = [[NSUserDefaults standardUserDefaults] valueForKey:@"backendURL"];
    if (backendURL) {
        return backendURL;
    }
    return [GGConstants backendDefaultHost];
}

+(NSString *)backendDefaultHost
{
    return @"http://localhost:8000/backend";
//    return @"http://ec2-54-172-25-80.compute-1.amazonaws.com/backend";
//    return @"http://date.cs.umass.edu/notifier/campus/umass/backend.php";
}

+(void)setBackendURL:(NSString *)backendURL
{
    [[NSUserDefaults standardUserDefaults] setValue:backendURL forKey:@"backendURL"];
}

+(NSString *)casaAlertsURL
{
    return [GGConstants backendURL];
//    return @"http://ec2-54-172-25-80.compute-1.amazonaws.com/backend";
//    return @"http://date.cs.umass.edu/notifier/campus/umass/backend.php";
//    return @"http://hazard.hpcc.umass.edu:8081/";
}

+(NSString *)casaAlertsURLAlternative
{
    return @"http://hazard.hpcc.umass.edu/alerts/old/";
}

+(BOOL)casaAlertsParseHTML
{
    return YES;
//    return NO;
}

+(NSString *)radarImageURL
{
    return @"http://droc1.srh.noaa.gov/dfw/current_merge.png";
}

+(NSString *)radarImageXMLURL
{
    return @"http://droc1.srh.noaa.gov/dfw/nowcast.xml";
    return @"http://droc1.srh.noaa.gov/dfw/merge.xml";
}

+(NSString *)radarImageUsername
{
    return @"hazardseesapp";
}

+(NSString *)radarImagePassword
{
    return @"hazardseesapp";
}

+(BOOL)shouldPlaySound
{
    NSNumber *shouldPlaySound = [[NSUserDefaults standardUserDefaults] valueForKey:@"shouldPlaySound"];
    if (shouldPlaySound) {
        return [shouldPlaySound boolValue];
    }
    return YES;
}

+(void)setShouldPlaySound:(BOOL)shouldPlaySound
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:shouldPlaySound] forKey:@"shouldPlaySound"];
}

#pragma mark - 

+(BOOL)inDeveloperMode
{
    NSNumber *inDeveloperMode = [[NSUserDefaults standardUserDefaults] valueForKey:@"inDeveloperMode"];
    if (inDeveloperMode) {
        return [inDeveloperMode boolValue];
    }
    return NO;
}

+(void)setInDeveloperMode:(BOOL)inDeveloperMode
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:inDeveloperMode] forKey:@"inDeveloperMode"];
}


+(BOOL)useFakeExpirationDates
{
    NSNumber *fakeExpirationDates = [[NSUserDefaults standardUserDefaults] valueForKey:@"useFakeExpirationDates"];
    if (fakeExpirationDates) {
        return [fakeExpirationDates boolValue];
    }
    return NO;
}

+(void)setFakeExpirationDates:(BOOL)fakeExpirationDates
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:fakeExpirationDates] forKey:@"useFakeExpirationDates"];
}


#pragma mark - Date Format

+(BOOL)useLongDateFormat
{
    NSNumber *longDateFormat = [[NSUserDefaults standardUserDefaults] valueForKey:@"longDateFormat"];
    if (longDateFormat) {
        return [longDateFormat boolValue];
    }
    return NO;
}

+(void)setLongDateFormat:(BOOL)longDateFormat
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:longDateFormat] forKey:@"longDateFormat"];
}


#pragma mark - Alerts


+(BOOL)shouldShowAllAlerts
{
    NSNumber *shouldShowAllAlerts = [[NSUserDefaults standardUserDefaults] valueForKey:@"shouldShowAllAlerts"];
    if (shouldShowAllAlerts) {
        return [shouldShowAllAlerts boolValue];
    }
    return NO;
}

+(void)setShouldShowAllAlerts:(BOOL)shouldShowAllAlerts
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:shouldShowAllAlerts] forKey:@"shouldShowAllAlerts"];
}


+(BOOL)shouldShowAllExistingAlerts
{
    NSNumber *shouldShowAllAlerts = [[NSUserDefaults standardUserDefaults] valueForKey:@"shouldShowAllExistingAlerts"];
    if (shouldShowAllAlerts) {
        return [shouldShowAllAlerts boolValue];
    }
    return NO;
}

+(void)setShouldShowAllExistingAlerts:(BOOL)shouldShowAllAlerts
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:shouldShowAllAlerts] forKey:@"shouldShowAllExistingAlerts"];
}


+(BOOL)useComplexPolygons
{
    NSNumber *useComplexPolygons = [[NSUserDefaults standardUserDefaults] valueForKey:@"useComplexPolygons"];
    if (useComplexPolygons) {
        return [useComplexPolygons boolValue];
    }
    return YES;
}

+(void)setUseComplexPolygons:(BOOL)useComplexPolygons
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:useComplexPolygons] forKey:@"useComplexPolygons"];
}

#pragma mark - Time simulation

+(BOOL)isTimeSimulated
{
    NSNumber *isTimeSimulated = [[NSUserDefaults standardUserDefaults] valueForKey:@"isTimeSimulated"];
    if (isTimeSimulated) {
        return [isTimeSimulated boolValue];
    }
    return NO;
}

+(void)setIsTimeSimulated:(BOOL)isTimeSimulated
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isTimeSimulated] forKey:@"isTimeSimulated"];
}

+(BOOL)isSimulatedTimeAdvancing
{
    NSNumber *isSimulatedTimeAdvancing = [[NSUserDefaults standardUserDefaults] valueForKey:@"isSimulatedTimeAdvancing"];
    if (isSimulatedTimeAdvancing) {
        return [isSimulatedTimeAdvancing boolValue];
    }
    return NO;
}

+(void)setIsSimulatedTimeAdvancing:(BOOL)isSimulatedTimeAdvancing
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isSimulatedTimeAdvancing] forKey:@"isSimulatedTimeAdvancing"];
}

+(NSDate *)simulatedTime
{
    NSDate *date = [[NSUserDefaults standardUserDefaults] valueForKey:@"simulatedTime"];
    return date;
}

+(void)setSimulatedTime:(NSDate *)simulatedTime
{
    [[NSUserDefaults standardUserDefaults] setValue:simulatedTime forKey:@"simulatedTime"];
}

+(NSTimeInterval)simulatedTimeInterval
{
    NSNumber *timeInterval = [[NSUserDefaults standardUserDefaults] valueForKey:@"simulatedTimeInterval"];
    if (timeInterval) {
        return [timeInterval doubleValue];
    }
    return 0.0;
}

+(void)setSimulatedTimeInterval:(NSTimeInterval)simulatedTimeInterval
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithDouble:simulatedTimeInterval] forKey:@"simulatedTimeInterval"];
}

#pragma mark - Location simulation

+(BOOL)isLocationSimulated
{
    NSNumber *isLocationSimulated = [[NSUserDefaults standardUserDefaults] valueForKey:@"isLocationSimulated"];
    if (isLocationSimulated) {
        return [isLocationSimulated boolValue];
    }
    return NO;
}

+(void)setIsLocationSimulated:(BOOL)isLocationSimulated
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:isLocationSimulated] forKey:@"isLocationSimulated"];
}

+(GGLocation *)simulatedLocation
{
    NSDictionary *simulatedLocation = [[NSUserDefaults standardUserDefaults] valueForKey:@"simulatedLocation"];
    if (simulatedLocation) {
        CLLocationDegrees lat = [[simulatedLocation valueForKey:@"lat"] doubleValue];
        CLLocationDegrees lon = [[simulatedLocation valueForKey:@"lon"] doubleValue];
        NSString *name = [simulatedLocation valueForKey:@"name"];
        GGLocation *location = [[GGLocation alloc] initWithLatitude:lat longitude:lon];
        location.name = name;
        return location;
    }
    return nil;
}

+(void)setSimulatedLocation:(GGLocation *)location
{
    CLLocationCoordinate2D coordinates = location.coordinate;
    if (CLLocationCoordinate2DIsValid(coordinates)) {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
        [dic setValue:[NSNumber numberWithDouble:coordinates.latitude] forKey:@"lat"];
        [dic setValue:[NSNumber numberWithDouble:coordinates.longitude] forKey:@"lon"];
        if (location.name) {
            [dic setValue:location.name forKey:@"name"];
        }
        [[NSUserDefaults standardUserDefaults] setValue:dic forKey:@"simulatedLocation"];
    }
}

+(BOOL)receiveNotificationWhenLocationUpdated
{
    NSNumber *receiveNotificationWhenLocationUpdated = [[NSUserDefaults standardUserDefaults] valueForKey:@"receiveNotificationWhenLocationUpdated"];
    if (receiveNotificationWhenLocationUpdated) {
        return [receiveNotificationWhenLocationUpdated boolValue];
    }
    return YES;
}

+(void)setReceiveNotificationWhenLocationUpdated:(BOOL)receiveNotificationWhenLocationUpdated
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:receiveNotificationWhenLocationUpdated] forKey:@"receiveNotificationWhenLocationUpdated"];
}

#pragma mark - Radar Images

+(BOOL)useGrayScaleRadarImages
{
    NSNumber *useGrayScaleRadarImages = [[NSUserDefaults standardUserDefaults] valueForKey:@"useGrayScaleRadarImages"];
    if (useGrayScaleRadarImages) {
        return [useGrayScaleRadarImages boolValue];
    }
    return NO;
}

+(void)setUseGrayScaleRadarImages:(BOOL)useGrayScaleRadarImages
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:useGrayScaleRadarImages] forKey:@"useGrayScaleRadarImages"];
}

#pragma mark - Polygons

+(BOOL)showPolygons
{
    NSNumber *showPolygons = [[NSUserDefaults standardUserDefaults] valueForKey:@"showPolygons"];
    if (showPolygons) {
        return [showPolygons boolValue];
    }
    return YES;
}

+(void)setShowPolygons:(BOOL)showPolygons
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:showPolygons] forKey:@"showPolygons"];
}

#pragma mark - Camera

+(BOOL)runningCamera
{
    NSNumber *runningCamera = [[NSUserDefaults standardUserDefaults] valueForKey:@"runningCamera"];
    if (runningCamera) {
        return [runningCamera boolValue];
    }
    return YES;
}

+(void)setRunningCamera:(BOOL)runningCamera
{
    [[NSUserDefaults standardUserDefaults] setValue:[NSNumber numberWithBool:runningCamera] forKey:@"runningCamera"];
}


@end
