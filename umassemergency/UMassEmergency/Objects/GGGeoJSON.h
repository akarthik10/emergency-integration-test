//
//  GGGeoJSON.h
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "GGPolygon.h"

@interface GGGeoJSON : NSObject

@property (nonatomic, strong) NSDictionary *geoJSON;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;

- (instancetype)initWithGeoJSON:(NSDictionary *)geoJSON;
- (instancetype)initWithPoint:(CLLocationCoordinate2D)coordinate;
- (instancetype)initWithPolygon:(GGPolygon *)polygon;
- (instancetype)initWithMultiPolygon:(NSArray<GGPolygon *> *)polygons;
- (instancetype)initWithString:(NSString *)geoJSONString;

-(NSString *)geoJSONString;
-(NSDictionary *)geoJSONDictionaryWithStrings;

-(NSArray<GGPolygon *> *)multiPolygon;
-(GGLocation *)point;

-(NSUInteger)numberOfPoints;

-(NSDictionary *)dictionaryPresentation;

-(CLLocationDistance)closestDistanceToPolygonFromLocation:(CLLocation *)location;

@end
