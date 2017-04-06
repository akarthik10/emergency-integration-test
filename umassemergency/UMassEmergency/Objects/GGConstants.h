//
//  GGConstants.h
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

#import <Foundation/Foundation.h>
#import "GGLocation.h"

@interface GGConstants : NSObject


+(NSString *)backendURL;
+(NSString *)backendDefaultHost;
+(void)setBackendURL:(NSString *)backendURL;

#pragma mark -

+(void)sendTrackingScreenName:(NSString *)name;

+(BOOL)useTabController;

+(NSString *)attributesJSONURL;

+(NSString *)gnsHost;
+(void)setGNSHost:(NSString *)gnsHost;
+(NSString *)gnsDefaultHost;

+(NSInteger)gnsPort;
+(void)setGNSPort:(NSInteger)gnsPort;
+(NSInteger)gnsDefaultPort;

+(NSString *)casaAlertsURL;
+(BOOL)casaAlertsParseHTML;

+(NSString *)radarImageURL;
+(NSString *)radarImageXMLURL;
+(NSString *)radarImageUsername;
+(NSString *)radarImagePassword;

+(void)setShouldPlaySound:(BOOL)shouldPlaySound;
+(BOOL)shouldPlaySound;

+(BOOL)inDeveloperMode;
+(void)setInDeveloperMode:(BOOL)inDeveloperMode;

+(BOOL)useFakeExpirationDates;
+(void)setFakeExpirationDates:(BOOL)fakeExpirationDates;

+(BOOL)useLongDateFormat;
+(void)setLongDateFormat:(BOOL)longDateFormat;

#pragma mark - All Alerts

+(BOOL)shouldShowAllAlerts;
+(void)setShouldShowAllAlerts:(BOOL)shouldShowAllAlerts;

+(BOOL)shouldShowAllExistingAlerts;
+(void)setShouldShowAllExistingAlerts:(BOOL)shouldShowAllAlerts;

+(BOOL)useComplexPolygons;
+(void)setUseComplexPolygons:(BOOL)useComplexPolygons;

#pragma mark - Time simulation

+(BOOL)isTimeSimulated;
+(void)setIsTimeSimulated:(BOOL)isTimeSimulated;

+(BOOL)isSimulatedTimeAdvancing;
+(void)setIsSimulatedTimeAdvancing:(BOOL)isSimulatedTimeAdvancing;

+(NSDate *)simulatedTime;
+(void)setSimulatedTime:(NSDate *)simulatedTime;

+(NSTimeInterval)simulatedTimeInterval;
+(void)setSimulatedTimeInterval:(NSTimeInterval)simulatedTimeInterval;

#pragma mark - Location simulation

+(BOOL)isLocationSimulated;
+(void)setIsLocationSimulated:(BOOL)isLocationSimulated;

+(GGLocation *)simulatedLocation;
+(void)setSimulatedLocation:(GGLocation *)location;

+(BOOL)useGrayScaleRadarImages;
+(void)setUseGrayScaleRadarImages:(BOOL)useGrayScaleRadarImages;

+(BOOL)showPolygons;
+(void)setShowPolygons:(BOOL)showPolygons;

+(BOOL)receiveNotificationWhenLocationUpdated;
+(void)setReceiveNotificationWhenLocationUpdated:(BOOL)receiveNotificationWhenLocationUpdated;

#pragma mark - Camera
+(BOOL)runningCamera;
+(void)setRunningCamera:(BOOL)runningCamera;

@end
