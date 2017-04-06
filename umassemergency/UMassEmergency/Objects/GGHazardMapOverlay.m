//
//  GGHazardMapOverlay.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 21.04.15.
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

#import "GGHazardMapOverlay.h"

@implementation GGHazardMapOverlay

- (instancetype)initWithRadarImage:(GGRadarImage *)radarImage
{
    self = [super init];
    if (self) {
        self.radarImage = radarImage;
    }
    return self;
}

- (CLLocationCoordinate2D)coordinate
{
    // Hardcoded
//    return CLLocationCoordinate2DMake(33.36993, -97.85504);
    
    // XML
    if (self.radarImage) {
        return self.radarImage.coordinate;
    }
    return CLLocationCoordinate2DMake(0, 0);
}

- (MKMapRect)boundingMapRect
{
    if (!self.radarImage) {
        return MKMapRectNull;
    }
    
    MKMapPoint upperLeft = MKMapPointForCoordinate(self.coordinate);
    
    // XML
    CLLocationDegrees bottom = self.coordinate.latitude - self.radarImage.numLats * self.radarImage.latGridSpacing;
    CLLocationDegrees right = self.coordinate.longitude + self.radarImage.numLons * self.radarImage.lonGridSpacing;
//    XLog(@"Bottom 1: %f",bottom);
//    XLog(@"Right 1: %f",right);

    // Hardcoded
//    CLLocationDegrees bottom = self.coordinate.latitude - 161 * 0.008999141;
//    CLLocationDegrees right = self.coordinate.longitude + 161 * 0.01068805;

//    XLog(@"Bottom 2: %f",bottom);
//    XLog(@"Right 2: %f",right);
    
    CLLocationCoordinate2D topRight = CLLocationCoordinate2DMake(self.coordinate.latitude, right);
    CLLocationCoordinate2D bottomLeft = CLLocationCoordinate2DMake(bottom, self.coordinate.longitude);

//    XLog(@"Coordinates: %f, %f, %f, %f",topRight.latitude,topRight.longitude,bottomLeft.latitude,bottomLeft.longitude);

    MKMapPoint topRightMap = MKMapPointForCoordinate(topRight);
    MKMapPoint bottomLeftMap = MKMapPointForCoordinate(bottomLeft);

    MKMapRect bounds = MKMapRectMake(upperLeft.x,upperLeft.y,fabs(upperLeft.x - topRightMap.x),fabs(upperLeft.y - bottomLeftMap.y));

    return bounds;
}


@end
