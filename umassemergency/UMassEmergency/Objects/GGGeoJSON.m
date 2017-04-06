//
//  GGGeoJSON.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 17.06.15.
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

#import "GGGeoJSON.h"
#import "GGPolygon.h"
#import "NSDictionary+GGStringDictionary.h"
#import "NSString+GGJSONObject.h"

@interface GGGeoJSON ()

@end

@implementation GGGeoJSON

-(NSUInteger)numberOfPoints
{
    GGLocation *point = [self point];
    if (point) {
        return 1;
    }
    return [self allPoints].count;
}

-(NSArray *)allPoints
{
    GGLocation *point = [self point];
    if (point) {
        return @[point];
    }
    NSMutableArray *pins = [[NSMutableArray alloc] init];
    NSArray *multiPolygon = [self multiPolygon];
    for (GGPolygon *polygon in multiPolygon) {
        [pins addObjectsFromArray:polygon.locations];
    }
    return pins;
}

-(GGLocation *)point
{
    if ([self.type isEqualToString:@"Point"]) {
        NSArray *coordinates = [self.geoJSON valueForKey:@"coordinates"];
        if (coordinates.count > 1) {
            NSNumber *lon = [coordinates objectAtIndex:0];
            NSNumber *lat = [coordinates objectAtIndex:1];
            GGLocation *location = [[GGLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
            location.name = self.name;
            return location;
        }
    }
    return nil;
}

-(NSArray<GGPolygon *> *)multiPolygon
{
    if (self.geoJSON) {
        NSString *type = [self.geoJSON valueForKey:@"type"];
        NSArray *coordinates = [self.geoJSON valueForKey:@"coordinates"];
        if (type && ![type isEqualToString:@"Point"]) {
            
            if (type && [type isEqualToString:@"Polygon"]) {
                
                if (coordinates && coordinates.count > 0) {
                    
                    NSArray *polygonCoordinates;
                    NSArray *outerArray = coordinates;
                    // check if outerArray is outerArray or mistakenly innerArray
                    if (outerArray.count > 0 && [outerArray[0] isKindOfClass:[NSArray class]]) {
                        // there it is an outerArray
                        // put innerArray to innerArray
                        NSArray *polygonCoordinate = outerArray[0];
                        if (polygonCoordinate.count > 0 && [polygonCoordinate[0] isKindOfClass:[NSNumber class]]) {
                            // wrong
                            // there should be another array
                            polygonCoordinates = outerArray;
                        }else{
                            polygonCoordinates = outerArray[0];
                        }
                    }
                    
                    NSMutableArray *polygonLocations = [[NSMutableArray alloc] init];
                    for (NSArray *coordinates in polygonCoordinates) {
                        if ([coordinates isKindOfClass:[NSArray class]] && coordinates.count > 1) {
                            NSNumber *longitude = coordinates[0];
                            NSNumber *latitude = coordinates[1];
                            CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
                            if (CLLocationCoordinate2DIsValid(coordinate)) {
                                CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                                [polygonLocations addObject:location];
                            }
                        }
                    }
                    GGPolygon *polygon = [[GGPolygon alloc] init];
                    polygon.locations = polygonLocations;
                    
                    return @[polygon];
                }
                
            }else if (type && [type isEqualToString:@"MultiPolygon"]) {
                
                if (coordinates && coordinates.count > 0) {
                    
                    NSArray *array = coordinates[0];
                    NSMutableArray *multiPolygon = [[NSMutableArray alloc] init];
                    
                    for (NSArray *polygons in array) {
                        
                        NSArray *polygonsArray = polygons;
                        if (polygons.count > 1 && [polygons[0] isKindOfClass:[NSNumber class]]) {
                            // coordinates not array
                            polygonsArray = @[polygons[0],polygons[1]];
                        }
                        
                        NSMutableArray *polygonLocations = [[NSMutableArray alloc] init];
                        GGPolygon *polygon = [[GGPolygon alloc] init];
                        for (NSArray *coordinates in polygons) {
                            if ([coordinates isKindOfClass:[NSArray class]] && coordinates.count > 1) {
                                NSNumber *longitude = coordinates[0];
                                NSNumber *latitude = coordinates[1];
                                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake([latitude doubleValue], [longitude doubleValue]);
                                if (CLLocationCoordinate2DIsValid(coordinate)) {
                                    CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
                                    [polygonLocations addObject:location];
                                }
                            }
                        }
                        polygon.locations = polygonLocations;
                        [multiPolygon addObject:polygon];
                    }
                    
                    return multiPolygon;
                }
                
            }
        }
    }
    return [NSArray arrayWithObject:[[GGPolygon alloc] init]];
}

-(CLLocationDistance)closestDistanceToPolygonFromLocation:(CLLocation *)location
{
    GGLocation *loc1 = self.point;
    if (loc1) {
        return [loc1 distanceFromLocation:location];
    }
    CLLocationDistance distance = FLT_MAX;
    for (CLLocation *pin in [self allPoints]) {
        distance = MIN(distance, [pin distanceFromLocation:location]);
    }
    return distance;
}

#pragma mark -

-(NSString *)geoJSONString
{
    NSString *locationString = [self.geoJSON jsonStringWithPrettyPrint:NO];
    return locationString;
}


#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.type = @"Point";
        NSMutableDictionary *geoJSON = [[NSMutableDictionary alloc] init];
        [geoJSON setValue:self.type forKey:@"type"];
        [geoJSON setValue:[NSArray array] forKey:@"coordinates"];
        self.geoJSON = geoJSON;
    }
    return self;
}

- (instancetype)initWithGeoJSON:(NSDictionary *)geoJSON
{
    self = [super init];
    if (self) {
        self.geoJSON = geoJSON;
        self.type = [geoJSON valueForKey:@"type"];
        [self fixGeoJSON];
    }
    return self;
}

- (instancetype)initWithPoint:(CLLocationCoordinate2D)coordinate
{
    self = [super init];
    if (self) {
        self.type = @"Point";
        NSMutableDictionary *geoJSON = [[NSMutableDictionary alloc] init];
        [geoJSON setValue:self.type forKey:@"type"];
        [geoJSON setValue:[NSArray arrayWithObjects:[NSNumber numberWithDouble:coordinate.longitude], [NSNumber numberWithDouble:coordinate.latitude], nil] forKey:@"coordinates"];
        self.geoJSON = geoJSON;
    }
    return self;
}

- (instancetype)initWithPolygon:(GGPolygon *)polygon
{
    self = [super init];
    if (self) {
        self.type = @"Polygon";
        NSMutableDictionary *geoJSON = [[NSMutableDictionary alloc] init];
        [geoJSON setValue:self.type forKey:@"type"];
        
        NSMutableArray *coordinates = [[NSMutableArray alloc] init];
        for (CLLocation *location in polygon.locations) {
            CLLocationCoordinate2D coordinate = location.coordinate;
            [coordinates addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:coordinate.longitude], [NSNumber numberWithDouble:coordinate.latitude], nil]];
        }
        // check if last point of polygon equals first point of polygon
        // polygon must have at least 3 points
        if (polygon.locations.count > 2) {
            CLLocation *firstLocation = [polygon.locations firstObject];
            CLLocation *lastLocation = [polygon.locations lastObject];
            if (!(firstLocation.coordinate.latitude == lastLocation.coordinate.latitude && firstLocation.coordinate.longitude == lastLocation.coordinate.longitude)) {
                // last point is not equal to first point
                // add first point to the end
                CLLocationCoordinate2D coordinate = firstLocation.coordinate;
                [coordinates addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:coordinate.longitude], [NSNumber numberWithDouble:coordinate.latitude], nil]];
            }
        }
        
        [geoJSON setValue:@[coordinates] forKey:@"coordinates"];    // add extra array
        self.geoJSON = geoJSON;
    }
    return self;
}

- (instancetype)initWithMultiPolygon:(NSArray<GGPolygon *> *)polygons
{
    self = [super init];
    if (self) {
        self.type = @"MultiPolygon";
        NSMutableDictionary *geoJSON = [[NSMutableDictionary alloc] init];
        [geoJSON setValue:self.type forKey:@"type"];
        
        NSMutableArray *outerCoordinates = [[NSMutableArray alloc] init];
        for (GGPolygon *polygon in polygons) {
            NSMutableArray *coordinates = [[NSMutableArray alloc] init];
            for (CLLocation *location in polygon.locations) {
                CLLocationCoordinate2D coordinate = location.coordinate;
                [coordinates addObject:[NSArray arrayWithObjects:[NSNumber numberWithDouble:coordinate.longitude], [NSNumber numberWithDouble:coordinate.latitude], nil]];
            }
            [outerCoordinates addObject:coordinates];
        }
        [geoJSON setValue:outerCoordinates forKey:@"coordinates"];
        self.geoJSON = geoJSON;
    }
    return self;
}

- (instancetype)initWithString:(NSString *)geoJSONString
{
    self = [super init];
    if (self) {
        NSDictionary *json = (NSDictionary *)[geoJSONString jsonObject];
        if ([json isKindOfClass:[NSDictionary class]]) {
            self.geoJSON = json;
            NSString *type = [json valueForKey:@"type"];
            if (type) {
                self.type = type;
            }
        }
    }
    return self;
}

-(NSDictionary *)dictionaryPresentation
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.name forKey:@"name"];
    [dic setValue:self.geoJSON forKey:@"location"];
    
    return dic;
}

-(NSDictionary *)geoJSONDictionaryWithStrings
{
    return [self.geoJSON dictionaryWithStringValues];
}

#pragma mark -

-(void)fixGeoJSON
{
    if (self.geoJSON && self.type) {
        
        if ([self.type isEqualToString:@"Polygon"]) {
            
            NSDictionary *currentGeoJSON = self.geoJSON;
            NSArray *outerRing = [currentGeoJSON valueForKey:@"coordinates"];
            NSMutableArray *newOuterRing = [[NSMutableArray alloc] init];
            for (NSArray *innerRing in outerRing) {
                NSMutableArray *newInnerRing = [[NSMutableArray alloc] init];
                for (NSArray *coordinateArray in innerRing) {
                    if (coordinateArray.count > 1) {
                        // coordinates
                        NSNumber *firstPoint = coordinateArray[0];
                        NSNumber *secondPoint = coordinateArray[1];
                        if ([firstPoint isKindOfClass:[NSString class]] && [secondPoint isKindOfClass:[NSString class]]) {
                            // turn them to numbers if string
                            firstPoint = [NSNumber numberWithDouble:[firstPoint doubleValue]];
                            secondPoint = [NSNumber numberWithDouble:[secondPoint doubleValue]];
                        }
                        NSArray *newCoordinates = [NSArray arrayWithObjects:firstPoint, secondPoint, nil];
                        [newInnerRing addObject:newCoordinates];
                    }
                }
                NSArray *firstCoordinates = innerRing.firstObject;
                NSArray *lastCoordinates = innerRing.lastObject;
                if (![firstCoordinates isEqual:lastCoordinates]) {
                    [newInnerRing addObject:firstCoordinates];
                }
                [newOuterRing addObject:newInnerRing];
            }
            NSMutableDictionary *newGeoJSON = [[NSMutableDictionary alloc] initWithDictionary:currentGeoJSON];
            [newGeoJSON setValue:newOuterRing forKey:@"coordinates"];
            self.geoJSON = newGeoJSON;
            
        }else if ([self.type isEqualToString:@"Point"]){
            
            NSDictionary *currentGeoJSON = self.geoJSON;
            NSArray *coordinateArray = [currentGeoJSON valueForKey:@"coordinates"];
            if (coordinateArray.count > 1) {
                // coordinates
                NSNumber *firstPoint = coordinateArray[0];
                NSNumber *secondPoint = coordinateArray[1];
                if ([firstPoint isKindOfClass:[NSString class]] && [secondPoint isKindOfClass:[NSString class]]) {
                    // turn them to numbers if string
                    firstPoint = [NSNumber numberWithDouble:[firstPoint doubleValue]];
                    secondPoint = [NSNumber numberWithDouble:[secondPoint doubleValue]];
                }
                NSArray *newCoordinates = [NSArray arrayWithObjects:firstPoint, secondPoint, nil];
                NSMutableDictionary *newGeoJSON = [[NSMutableDictionary alloc] initWithDictionary:currentGeoJSON];
                [newGeoJSON setValue:newCoordinates forKey:@"coordinates"];
                self.geoJSON = newGeoJSON;
            }
        }
    }
}

@end
