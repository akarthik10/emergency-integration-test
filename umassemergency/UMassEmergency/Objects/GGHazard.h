//
//  GGHazard.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 07.04.15.
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
#import <CoreLocation/CoreLocation.h>
#import "GGHazardPolygon.h"
#import "GGWarningCategory.h"
#import "GGWarningType.h"

typedef enum : NSUInteger {
    GGHazardActiveUnknown,
    GGHazardActivePassed,
    GGHazardActiveNow
} GGHazardActive;

@class GGTimeframe;
@interface GGHazard : NSObject

@property (nonatomic, assign) GGWarningType *type;
@property (nonatomic, strong) NSString *hazardID;
@property (nonatomic, strong) NSString *hazardType;
@property (nonatomic, strong) NSString *headline;
@property (nonatomic, readonly) NSString *summary;
@property (nonatomic, strong) NSString *defaultSummary;
@property (nonatomic, strong) NSString *validSummary;
@property (nonatomic, strong) NSString *expiredSummary;
@property (nonatomic, strong) NSString *longDescription;
@property (nonatomic, strong) NSString *certainty;
@property (nonatomic, strong) NSDate *effectiveDate;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSArray *polygons;
@property (nonatomic, strong) NSArray *complexPolygons;

@property (nonatomic, strong, readonly) UIImage *icon;
@property (nonatomic, strong, readonly) UIImage *iconSmall;
@property (nonatomic, strong, readonly) UIImage *iconBig;

@property (nonatomic, readwrite) CLLocationCoordinate2D centerCoordinate;
@property (nonatomic, readwrite) CLLocationCoordinate2D complexCenterCoordinate;
@property (nonatomic, readwrite) CLLocationDistance currentDistance;
@property (nonatomic, readwrite) CLLocationDistance currentDistanceToClosestPolygonPoint;
@property (nonatomic, readwrite) CLLocationDirection currentDirection;

-(GGHazardActive)isActive;
-(BOOL)isExpirationDateVisible;

-(void)updateDistanceToLocation:(CLLocation *)location;
-(void)updateDirectionToHeading:(CLHeading *)heading andLocation:(CLLocation *)location;

-(CLLocationDistance)distanceToLocation:(CLLocation *)location;

+(GGHazard *)hazardWithDictionary:(NSDictionary *)info;

-(BOOL)isInTimeframe:(GGTimeframe *)timeframe;
-(BOOL)isOlderThan12Hours;

@end
