//
//  GGRadarImage.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 16.05.15.
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
#import "GGTimeframe.h"

@interface GGRadarImage : NSObject

@property (nonatomic, strong) NSString *xmlString;
@property (nonatomic, strong) NSString *xmlURL;
@property (nonatomic, strong) NSString *imageURL;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong, readonly) UIImage *grayScaleImage;
@property (nonatomic, strong) NSArray *timeframeIDs;
@property (nonatomic, strong) NSNumber *alpha;
@property (nonatomic, readwrite) BOOL isGrayScale;

@property (nonatomic, strong) NSArray *alertFileURLs;

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSInteger numLats;
@property (nonatomic, readonly) NSInteger numLons;

@property (nonatomic, readonly) CGFloat latGridSpacing;
@property (nonatomic, readonly) CGFloat lonGridSpacing;

-(BOOL)isInTimeframe:(GGTimeframe *)timeframe;

@end
