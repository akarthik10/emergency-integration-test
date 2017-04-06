//
//  GGPolygon.m
//  WindContours
//
//  Created by Görkem Güclü on 18.05.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "GGPolygon.h"

@implementation GGPolygon

-(void)setLocations:(NSArray<CLLocation *> *)locations
{
    _locations = locations;
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CLLocation *location in locations) {
        NSValue *polygonCoordinateValue = [NSValue valueWithMKCoordinate:location.coordinate];
        [array addObject:polygonCoordinateValue];
    }
    _polygonCoordinates = array;
    _centerCoordinate = [self calculateCenterCoordinate];
}

-(void)setPolygonCoordinates:(NSArray *)polygonCoordinates
{
    _polygonCoordinates = polygonCoordinates;
    
    NSMutableArray *locations = [[NSMutableArray alloc] init];
    for (NSValue *polygonCoordinateValue in polygonCoordinates) {
        CLLocationCoordinate2D coordinate = [polygonCoordinateValue MKCoordinateValue];
        CLLocation *location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        [locations addObject:location];
    }
    _locations = locations;
    _centerCoordinate = [self calculateCenterCoordinate];
}

-(CLLocationDistance)distanceToClosestPolygonCoordinateFromLocation:(CLLocation *)location
{
    CLLocationDistance distance = MAXFLOAT;
    CLLocation *closestLocation = [self closestPolygonLocationFromLocation:location];
    if (closestLocation) {
        distance = [closestLocation distanceFromLocation:location];
    }
    return distance;
}

-(CLLocation *)closestPolygonLocationFromLocation:(CLLocation *)location
{
    CLLocationDistance distance = MAXFLOAT;
    CLLocation *closest = nil;
    for (NSValue *polygonCoordinateValue in self.polygonCoordinates) {
        CLLocationCoordinate2D coordinate = [polygonCoordinateValue MKCoordinateValue];
        CLLocation *toLocation = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
        CLLocationDistance locationDistance = [location distanceFromLocation:toLocation];
        distance = MIN(distance, locationDistance);
        if (distance == locationDistance) {
            closest = toLocation;
        }
    }
    return closest;
}


-(CLLocationCoordinate2D)calculateCenterCoordinate
{
    CLLocationDegrees minLat = MAXFLOAT,minLng = MAXFLOAT,maxLat = -200,maxLng = -200;
    
    for (NSValue *polygonCoordinateValue in self.polygonCoordinates) {
        CLLocationCoordinate2D coordinate = [polygonCoordinateValue MKCoordinateValue];
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


@end
