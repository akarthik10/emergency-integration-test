//
//  GGPolygon.h
//  WindContours
//
//  Created by Görkem Güclü on 18.05.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface GGPolygon : NSObject

@property (nonatomic, strong) NSArray<CLLocation *> *locations;
@property (nonatomic, strong) NSArray *polygonCoordinates;
@property (nonatomic, readwrite) CLLocationCoordinate2D centerCoordinate;

-(CLLocation *)closestPolygonLocationFromLocation:(CLLocation *)location;
-(CLLocationDistance)distanceToClosestPolygonCoordinateFromLocation:(CLLocation *)location;

@end
