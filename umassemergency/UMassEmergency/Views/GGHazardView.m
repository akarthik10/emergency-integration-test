//
//  GGHazardView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 11.05.15.
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

#import "GGHazardView.h"
#import "GGHazardCircleOverlay.h"
#import "GGHazardPolygonOverlay.h"

@implementation GGHazardView

- (instancetype)initWithHazard:(GGHazard *)hazard
{
    self = [super init];
    if (self) {
        self.hazard = hazard;
    }
    return self;
}


-(void)setHazard:(GGHazard *)hazard
{
    _hazard = hazard;
    if (hazard) {
        
        NSMutableArray *hazardAnnotations = [[NSMutableArray alloc] init];
        NSMutableArray *subHazardCenterAnnotations = [[NSMutableArray alloc] init];
        NSMutableArray *hazardOverlays = [[NSMutableArray alloc] init];
        
        NSArray *polygons = hazard.polygons;
        if ([GGConstants useComplexPolygons]) {
            polygons = hazard.complexPolygons;
        }
        
        for (GGHazardPolygon *polygon in polygons) {
            
            if (polygon.polygonCoordinates.count == 1) {
                // point
                NSValue *coordinate = polygon.polygonCoordinates[0];
                CLLocationCoordinate2D coordinate2D = [coordinate MKCoordinateValue];
                NSString *title = hazard.headline;
                if (!title) {
                    title = hazard.hazardID;
                }
                GGHazardAnnotation *anno = [[GGHazardAnnotation alloc] initWithTitle:title andCoordinate:coordinate2D];
                anno.hazard = hazard;
                [hazardAnnotations addObject:anno];
                
                GGHazardAnnotation *centerAnno = [[GGHazardAnnotation alloc] initWithTitle:hazard.headline andCoordinate:coordinate2D];
                centerAnno.hazard = hazard;
                [subHazardCenterAnnotations addObject:centerAnno];
                
//                GGHazardCircleOverlay *circle = [GGHazardCircleOverlay circleWithCenterCoordinate:coordinate2D radius:100];
//                circle.hazardPolygon = polygon;
//                [hazardOverlays addObject:circle];
                
            }else if (polygon.polygonCoordinates.count > 0) {
                // polygon
                
                NSInteger count = 0;
                CLLocationCoordinate2D polygonCoordinates[polygon.polygonCoordinates.count];
                for (NSValue *coordinate in polygon.polygonCoordinates) {
                    CLLocationCoordinate2D coordinate2D = [coordinate MKCoordinateValue];
                    polygonCoordinates[count] = coordinate2D;
                    
                    NSString *title = hazard.headline;
                    if (!title) {
                        title = hazard.hazardID;
                    }
                    GGHazardAnnotation *anno = [[GGHazardAnnotation alloc] initWithTitle:title andCoordinate:coordinate2D];
                    anno.hazard = hazard;
                    [hazardAnnotations addObject:anno];
                    count++;
                }
                
                NSString *title = hazard.headline;
                if (!title) {
                    title = hazard.hazardID;
                }
                GGHazardAnnotation *anno = [[GGHazardAnnotation alloc] initWithTitle:title andCoordinate:[polygon centerCoordinate]];
                anno.hazard = hazard;
                [subHazardCenterAnnotations addObject:anno];

                GGHazardPolygonOverlay *overlay = [GGHazardPolygonOverlay polygonWithCoordinates:polygonCoordinates count:polygon.polygonCoordinates.count];
                overlay.hazardPolygon = polygon;
                [hazardOverlays addObject:overlay];
                
            }
        }

        NSString *title = hazard.headline;
        if (!title) {
            title = hazard.hazardID;
        }
        
        GGHazardAnnotation *anno = [[GGHazardAnnotation alloc] initWithTitle:title andCoordinate:[hazard centerCoordinate]];
        anno.hazard = hazard;
        self.centerAnnotation = anno;

//        if (hazardAnnotations.count == 0) {
//            [hazardAnnotations addObject:self.centerAnnotation];
//        }

        if (subHazardCenterAnnotations.count == 0) {
            [subHazardCenterAnnotations addObject:self.centerAnnotation];
        }

        self.overlays = hazardOverlays;
        self.annotations = hazardAnnotations;
        self.subHazardCenterAnnotations = subHazardCenterAnnotations;
        

    }
}

@end
