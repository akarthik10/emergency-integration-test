//
//  GGHazard.m
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

#import "GGHazard.h"
#import <MapKit/MapKit.h>
#import "GGTimeframe.h"

@interface GGHazard ()

@property (nonatomic, strong) NSDate *fakeExpirationDate;

@end

@implementation GGHazard

- (instancetype)init
{
    self = [super init];
    if (self) {
//        _type = GGHazardTypeUnknown;
    }
    return self;
}

-(void)setPolygons:(NSArray *)polygons
{
    _polygons = polygons;
    if (polygons) {
        _centerCoordinate = [self calculateCenterCoordinateForPolygons:polygons];
    }
}

-(void)setComplexPolygons:(NSArray *)complexPolygons
{
    _complexPolygons = complexPolygons;
    if (complexPolygons) {
        _complexCenterCoordinate = [self calculateCenterCoordinateForPolygons:complexPolygons];
    }
}

#pragma mark - Icon

-(UIImage *)icon
{
    if (self.type && self.type.icon) {
        return self.type.icon;
    }
//    if (self.category && self.category.icon) {
//        return self.category.icon;
//    }
    return nil;
}

-(UIImage *)iconSmall
{
    if (self.type && self.type.iconSmall) {
        return self.type.iconSmall;
    }
//    if (self.category && self.category.iconSmall) {
//        return self.category.iconSmall;
//    }
    return nil;
}

-(UIImage *)iconBig
{
    if (self.type && self.type.iconBig) {
        return self.type.iconBig;
    }
//    if (self.category && self.category.iconBig) {
//        return self.category.iconBig;
//    }
    return nil;
}

#pragma mark -

-(void)updateDistanceToLocation:(CLLocation *)location
{
    _currentDistance = [self distanceToLocation:location];
    _currentDistanceToClosestPolygonPoint = _currentDistance;
    for (GGHazardPolygon *polygon in self.polygons) {
        _currentDistanceToClosestPolygonPoint = MIN(_currentDistanceToClosestPolygonPoint, [polygon distanceToClosestPolygonCoordinateFromLocation:location]);
    }
}

-(void)updateDirectionToHeading:(CLHeading *)heading andLocation:(CLLocation *)location
{
    _currentDirection = [self degreeForHeading:heading toLocation:location];
}


-(CLLocationDirection)degreeForHeading:(CLHeading *)heading toLocation:(CLLocation *)location
{
    double result;
    
    double x1 = location.coordinate.latitude;
    double y1 = location.coordinate.longitude;
    // Test: kaiserin augusta allee
//    x1 = 52.525917;
//    y1 = 13.314401;
    double x2 = self.complexCenterCoordinate.latitude;
    double y2 = self.complexCenterCoordinate.longitude;
    // Test: aral tankstelle
//    x2 = 52.520903;
//    y2 = 13.333788;
    
    double dx = (x2 - x1);
    double dy = (y2 - y1);
    
    if (dx == 0) {
        if (dy > 0) {
            result = 90;
        }
        else {
            result = 270;
        }
    }
    else {
        result = (atan(dy/dx)) * 180 / M_PI;
    }
    
    if (dx < 0) {
        result = result + 180;
    }
    
    if (result < 0) {
        result = result + 360;
    }
    
    double degree = ((result - heading.magneticHeading) * M_PI / 180);
    return degree;
}


-(CLLocationDistance)distanceToLocation:(CLLocation *)location
{
    CLLocationCoordinate2D centerCoordinates = [self centerCoordinate];
    CLLocation *centerLocation = [[CLLocation alloc] initWithLatitude:centerCoordinates.latitude longitude:centerCoordinates.longitude];
    CLLocationDistance distance = [centerLocation distanceFromLocation:location];
    return distance;
}


-(CLLocationCoordinate2D)calculateCenterCoordinateForPolygons:(NSArray *)polygons
{
    CLLocationDegrees minLat = MAXFLOAT,minLng = MAXFLOAT,maxLat = -200,maxLng = -200;

    for (GGHazardPolygon *hazardPolygon in polygons) {
        
        CLLocationCoordinate2D coordinate = [hazardPolygon centerCoordinate];
        minLat = MIN(minLat, coordinate.latitude);
        minLng = MIN(minLng, coordinate.longitude);
        
        maxLat = MAX(maxLat, coordinate.latitude);
        maxLng = MAX(maxLng, coordinate.longitude);
    }
    
    CLLocationCoordinate2D coordinateOrigin = CLLocationCoordinate2DMake(minLat, minLng);
    CLLocationCoordinate2D coordinateMax = CLLocationCoordinate2DMake(maxLat, maxLng);
    
    MKMapPoint upperLeft = MKMapPointForCoordinate(coordinateOrigin);
    MKMapPoint lowerRight = MKMapPointForCoordinate(coordinateMax);
    
    //Create the map rect
    MKMapRect mapRect = MKMapRectMake(upperLeft.x,
                                      upperLeft.y,
                                      lowerRight.x - upperLeft.x,
                                      lowerRight.y - upperLeft.y);
    
    //Create the region
    MKCoordinateRegion region = MKCoordinateRegionForMapRect(mapRect);
    
    //THIS HAS THE CENTER, it should include spread
    CLLocationCoordinate2D centerCoordinate = region.center;
    
    return centerCoordinate;
}


-(GGHazardActive)isActive
{
    NSDate *now = [NSDate now];
    if (self.effectiveDate && self.expirationDate) {
        if ([[self.effectiveDate laterDate:now] isEqualToDate:now] && [[self.expirationDate laterDate:now] isEqualToDate:self.expirationDate]) {
            return GGHazardActiveNow;
        }
    }else if (self.effectiveDate && !self.expirationDate) {
        if ([[self.effectiveDate laterDate:now] isEqualToDate:now]) {
            return GGHazardActiveNow;
        }
    }else if (self.expirationDate) {
        if ([[self.expirationDate laterDate:now] isEqualToDate:self.expirationDate]) {
            return GGHazardActiveNow;
        }
    }
    if ([[self.effectiveDate laterDate:now] isEqualToDate:self.effectiveDate]) {
        return GGHazardActiveNow;
    }
    if ([[self.expirationDate laterDate:now] isEqualToDate:now]) {
        return GGHazardActivePassed;
    }
    return GGHazardActiveUnknown;
}


-(BOOL)isExpirationDateVisible
{
    BOOL containsNWS = [[self.hazardType lowercaseString] containsSubstring:@"_nws"];
    return containsNWS;
}


-(BOOL)isOlderThan12Hours
{
    NSDate *twelveHoursAgo = [NSDate dateWithTimeIntervalSinceNow:-60*60*12];

    if ([[self.expirationDate laterDate:twelveHoursAgo] isEqualToDate:twelveHoursAgo]) {
        return YES;
    }
    return NO;
}


-(NSDate *)expirationDate
{
    if ([GGConstants useFakeExpirationDates]) {
        if (!self.fakeExpirationDate) {
            NSInteger random = arc4random_uniform(7);
            self.fakeExpirationDate = [NSDate dateWithTimeIntervalSinceNow:random*60*5+4.9*60-15*60];
        }
        return self.fakeExpirationDate;
    }
    return _expirationDate;
}


-(NSString *)summary
{
    NSString *text = self.defaultSummary;
    
    switch ([self isActive]) {
        case GGHazardActiveNow:
            text = self.validSummary;
            break;
        case GGHazardActivePassed:
            text = self.expiredSummary;
            break;
            
        default:
            text = self.defaultSummary;
            break;
    }
    
//    NSString *minutesLeft = [NSDate stringForDisplayFromDate:self.effectiveDate];
    NSString *minutesLeft = [self.effectiveDate stringForDisplayFromDate:[NSDate now] prefixed:NO timeStyle:NSDateFormatterMediumStyle];
    text = [text stringByReplacingOccurrencesOfString:@"%s" withString:minutesLeft];
    
    return text;
}


#pragma mark -

+(GGHazard *)hazardWithDictionary:(NSDictionary *)info
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];

    NSString *hazardID = [info valueForKey:@"id"];
    NSString *hazardPolygons = [info valueForKey:@"Polygons"];
    NSString *hazardProperties = [info valueForKey:@"properties"];

    GGHazard *hazard;
    if (hazardID) {

        hazard = [[GGHazard alloc] init];
        hazard.hazardID = hazardID;
        hazard.hazardType = @"warning";

        if (hazardPolygons) {
            NSString *polygonsString = [hazardPolygons valueForKey:@"Polygons"];
            
            if ([polygonsString isKindOfClass:[NSString class]]) {
                // String
                NSString *jsonString = [polygonsString stringByReplacingOccurrencesOfString:@"\\\"" withString:@""];
                
                NSError *error;
                NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                NSString *coordinatesString = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                data = [coordinatesString dataUsingEncoding:NSUTF8StringEncoding];
                NSArray *coordinates = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
                NSMutableDictionary *geometry = [[NSMutableDictionary alloc] init];
                [geometry setValue:@"Polygon" forKey:@"type"];
                [geometry setValue:coordinates forKey:@"coordinates"];

                hazard.polygons = [GGHazard hazardPolygonsForHazard:hazard withGeometry:geometry andLongitudeBeforeLatitude:NO];
                
            }else if ([polygonsString isKindOfClass:[NSDictionary class]]) {
                // GeoJSON
                
                NSDictionary *geometry = (NSDictionary *)polygonsString;
                hazard.polygons = [GGHazard hazardPolygonsForHazard:hazard withGeometry:geometry andLongitudeBeforeLatitude:NO];
            }
            
            hazard.complexPolygons = hazard.polygons;
            
        }
        
        if (hazardProperties) {
            
            NSString *alertID = [hazardProperties valueForKey:@"alertID"];
            NSString *startTime = [hazardProperties valueForKey:@"startTime"];
            NSString *expiryTime = [hazardProperties valueForKey:@"expiryTime"];
            NSString *title = [hazardProperties valueForKey:@"title"];
            NSString *body = [hazardProperties valueForKey:@"body"];
            NSNumber *boundingLatitudeMin = [hazardProperties valueForKey:@"boundingLatitudeMin"];
            NSNumber *boundingLatitudeMax = [hazardProperties valueForKey:@"boundingLatitudeMax"];
            NSNumber *boundingLongitudeMin = [hazardProperties valueForKey:@"boundingLongitudeMin"];
            NSNumber *boundingLongitudeMax = [hazardProperties valueForKey:@"boundingLongitudeMax"];
            
            if (title) {
                hazard.defaultSummary = title;
                hazard.headline = title;
            }
            
            if (body) {
                hazard.longDescription = body;
            }
            
            if (startTime) {
                hazard.timestamp = [formatter dateFromString:startTime];
                hazard.effectiveDate = [formatter dateFromString:startTime];
            }
            
            if (expiryTime) {
                hazard.expirationDate = [formatter dateFromString:expiryTime];
            }
            
        }
    }
    
    /*
    NSString *hazardType = [info valueForKey:@"hazardType"];
    NSDictionary *properties = [info valueForKey:@"properties"];
    NSDictionary *geometry = [info valueForKey:@"geometry"];
    NSDictionary *complexGeometry = [info valueForKey:@"complexGeometry"];

    
    if (properties) {
        NSString *summary = [properties valueForKey:@"summary"];
        if (summary) {
            hazard.defaultSummary = summary;
            hazard.pendingSummary = summary;
            hazard.validSummary = summary;
            hazard.expiredSummary = summary;
        }
        
        NSString *pendingSummary = [properties valueForKey:@"pendingSummary"];
        if (pendingSummary) {
            hazard.pendingSummary = pendingSummary;
        }

        NSString *validSummary = [properties valueForKey:@"validSummary"];
        if (validSummary) {
            hazard.validSummary = validSummary;
        }

        NSString *expiredSummary = [properties valueForKey:@"expiredSummary"];
        if (expiredSummary) {
            hazard.expiredSummary = expiredSummary;
        }

        NSString *longDescription = [properties valueForKey:@"longDescription"];
        if (longDescription) {
            hazard.longDescription = longDescription;
        }

        NSString *event = [properties valueForKey:@"event"];
        if (event) {
            hazard.eventName = event;
        }

        NSString *headline = [properties valueForKey:@"headline"];
        if (headline) {
            hazard.headline = headline;
        }else{
            hazard.headline = event;
        }

        NSString *expires = [properties valueForKey:@"expires"];
        if (expires) {
            hazard.expirationDate = [formatter dateFromString:expires];
        }

        NSString *timestamp = [properties valueForKey:@"timestamp"];
        if (timestamp) {
            hazard.timestamp = [formatter dateFromString:timestamp];
            hazard.effectiveDate = hazard.timestamp;
        }

        NSString *effective = [properties valueForKey:@"effective"];
        if (effective) {
            hazard.effectiveDate = [formatter dateFromString:effective];
        }

        NSString *validAt = [properties valueForKey:@"validAt"];
        if (validAt) {
            hazard.effectiveDate = [formatter dateFromString:validAt];
        }
    }

    
    hazard.polygons = [GGHazard hazardPolygonsForHazard:hazard withGeometry:geometry];
    hazard.complexPolygons = [GGHazard hazardPolygonsForHazard:hazard withGeometry:complexGeometry];
    
    if (!hazard.complexPolygons) {
        hazard.complexPolygons = hazard.polygons;
    }
     */
    
    return hazard;
        
}


-(BOOL)isInTimeframe:(GGTimeframe *)timeframe
{
    // check if hazard is in timeframe
    
    BOOL result = self.effectiveDate.timeIntervalSince1970 <= timeframe.endDate.timeIntervalSince1970 && self.expirationDate.timeIntervalSince1970 >= timeframe.beginDate.timeIntervalSince1970;
    return result;
    
    // hazard begin date is after timeframe begin date and before timeframe end date
    // |_->_hB_<-_|
    
//    BOOL effectiveAfterTimeframeBeginDate = [[self.effectiveDate earlierDate:timeframe.beginDate] isEqualToDate:timeframe.beginDate];
    BOOL effectiveAfterTimeframeBeginDate = [self.effectiveDate compare:timeframe.beginDate] == NSOrderedDescending;
    
//    BOOL effectiveBeforeTimeframeEndDate = [[self.effectiveDate earlierDate:timeframe.endDate] isEqualToDate:self.effectiveDate];
    BOOL effectiveBeforeTimeframeEndDate = [self.effectiveDate compare:timeframe.endDate] == NSOrderedAscending;
    
    if (effectiveAfterTimeframeBeginDate && effectiveBeforeTimeframeEndDate) {
        return YES;
    }

    // hazard begin date is before timeframe begin date and before timeframe end date
    // hazard end date is after timeframe begin date and before timeframe end date
    // hB -> |__->_hE_->__|
    
    BOOL effectiveBeforeTimeframeBeginDate = [[self.effectiveDate earlierDate:timeframe.beginDate] isEqualToDate:self.effectiveDate];
    BOOL endsAfterTimeframeBeginDate = [[self.expirationDate earlierDate:timeframe.beginDate] isEqualToDate:timeframe.beginDate];
    BOOL endsBeforeTimeframeEndDate = [[self.expirationDate earlierDate:timeframe.endDate] isEqualToDate:self.expirationDate];
    if (effectiveBeforeTimeframeBeginDate && effectiveBeforeTimeframeEndDate && endsAfterTimeframeBeginDate && endsBeforeTimeframeEndDate) {
        return YES;
    }

    BOOL endsAfterTimeframeEndDate = [[self.expirationDate earlierDate:timeframe.endDate] isEqualToDate:timeframe.endDate];
    // hazard begin date is before timeframe begin date
    // hazard end date is after timeframe begin date and after timeframe end date
    // hB -> |__->__| -> hE
    
    if (effectiveBeforeTimeframeBeginDate && endsAfterTimeframeBeginDate && endsAfterTimeframeEndDate) {
        return YES;
    }
    
//    if ([timeframe isDateInTimeframe:self.expirationDate]) {
//        return YES;
//    }else if ([timeframe isDateInTimeframe:self.effectiveDate]) {
//        return YES;
//    }
    return NO;
}

+(NSArray *)hazardPolygonsForHazard:(GGHazard *)hazard withGeometry:(NSDictionary *)geometry
{
    return [GGHazard hazardPolygonsForHazard:hazard withGeometry:geometry andLongitudeBeforeLatitude:YES];
}

+(NSArray *)hazardPolygonsForHazard:(GGHazard *)hazard withGeometry:(NSDictionary *)geometry andLongitudeBeforeLatitude:(BOOL)firstLongitude
{
    NSMutableArray *hazardPolygons = [[NSMutableArray alloc] init];
    
    if (geometry) {
        NSArray *coordinates = [geometry valueForKey:@"coordinates"];
        NSString *type = [geometry valueForKey:@"type"];
        
        if ([type isEqualToString:@"Point"]) {
            
            GGHazardPolygon *hazardPolygon = [[GGHazardPolygon alloc] initWithHazard:hazard];
            NSMutableArray *hazardPoints = [[NSMutableArray alloc] init];
            
            CLLocationCoordinate2D point2D;
            
            NSArray *point = coordinates[0];
            if (point.count == 2) {
                
                NSNumber *lon = point[0];
                NSNumber *lat = point[1];
                if (!firstLongitude) {
                    lat = point[0];
                    lon = point[1];
                }
                
                point2D = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
                if (CLLocationCoordinate2DIsValid(point2D)) {
                    [hazardPoints addObject:[NSValue valueWithBytes:&point2D objCType:@encode(CLLocationCoordinate2D)]];
                }
                
                hazardPolygon.polygonCoordinates = hazardPoints;
                [hazardPolygons addObject:hazardPolygon];
            }
            
        }else if ([type isEqualToString:@"Polygon"]) {
            
            GGHazardPolygon *hazardPolygon = [[GGHazardPolygon alloc] initWithHazard:hazard];
            NSMutableArray *hazardPoints = [[NSMutableArray alloc] init];
            
            for (NSArray *polygon in coordinates) {
                
                NSInteger count = 0;
                
                CLLocationCoordinate2D point2D;
                
                for (NSArray *point in polygon) {
                    
                    NSNumber *lon = point[0];
                    NSNumber *lat = point[1];
                    if (!firstLongitude) {
                        lat = point[0];
                        lon = point[1];
                    }
                    
                    point2D = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
                    if (CLLocationCoordinate2DIsValid(point2D)) {
                        [hazardPoints addObject:[NSValue valueWithBytes:&point2D objCType:@encode(CLLocationCoordinate2D)]];
                    }
                    
                }
                
                count++;
            }
            
            hazardPolygon.polygonCoordinates = hazardPoints;
            [hazardPolygons addObject:hazardPolygon];
            
        }else if ([type isEqualToString:@"MultiPolygon"]) {
            
            
            for (NSArray *singlePolygonCoordinates in coordinates) {
                
                CLLocationCoordinate2D point2D;
                
                if (singlePolygonCoordinates.count > 0) {
                    
                    GGHazardPolygon *hazardPolygon = [[GGHazardPolygon alloc] initWithHazard:hazard];
                    NSMutableArray *hazardPoints = [[NSMutableArray alloc] init];
                    
                    NSArray *polygon = singlePolygonCoordinates[0];
                    for (NSArray *point in polygon) {
                        
                        NSNumber *lon = point[0];
                        NSNumber *lat = point[1];
                        if (!firstLongitude) {
                            lat = point[0];
                            lon = point[1];
                        }

                        point2D = CLLocationCoordinate2DMake([lat doubleValue], [lon doubleValue]);
                        if (CLLocationCoordinate2DIsValid(point2D)) {
                            [hazardPoints addObject:[NSValue valueWithBytes:&point2D objCType:@encode(CLLocationCoordinate2D)]];
                        }
                        
                    }
                    
                    hazardPolygon.polygonCoordinates = hazardPoints;
                    [hazardPolygons addObject:hazardPolygon];
                }
                
            }
            
        }
        
    }
    
    return hazardPolygons;
}


-(BOOL)isEqual:(id)object
{
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[GGHazard class]]) {
        return NO;
    }
    
    GGHazard *otherHazard = (GGHazard *)object;
    if (self.hazardID && otherHazard.hazardID) {
        return [otherHazard.hazardID isEqualToString:self.hazardID];
    }
    
    return NO;
}

@end
