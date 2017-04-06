//
//  GGRadarImage.m
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

#import "GGRadarImage.h"
#import <XMLDictionary/XMLDictionary.h>

@implementation GGRadarImage

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        _xmlURL = [GGConstants radarImageXMLURL];
        
    }
    return self;
}


-(void)setImage:(UIImage *)image
{
    _image = image;
    if (image) {
        _grayScaleImage = [image grayScaleImage];
    }
}


-(void)setXmlURL:(NSString *)xmlURL
{
    if (xmlURL) {
        _xmlURL = xmlURL;
    }
}


-(void)setXmlString:(NSString *)xmlString
{
    _xmlString = xmlString;
    if (xmlString) {
        [self parseXML:xmlString];
    }
}

-(void)parseXML:(NSString *)xmlString
{
    XMLDictionaryParser *xmlParser = [[XMLDictionaryParser alloc] init];
    xmlParser.trimWhiteSpace = YES;
    
    NSDictionary *dictionary = [xmlParser dictionaryWithString:xmlString];
//    XLog(@"XML: %@",dictionary);

    NSDictionary *mergeDimensions = [dictionary valueForKey:@"mergedimensions"];
    NSNumber *numLats = [mergeDimensions valueForKey:@"num_lats"];
    NSNumber *numLons = [mergeDimensions valueForKey:@"num_lons"];
    
    if (numLats) {
        _numLats = [numLats integerValue];
    }
    if (numLons) {
        _numLons = [numLons integerValue];
    }
    
    NSDictionary *netcdfAttributes = [dictionary valueForKey:@"netcdf_attributes"];
    if (netcdfAttributes) {
        NSNumber *latitude = [netcdfAttributes valueForKey:@"Latitude"];
        NSNumber *longitude = [netcdfAttributes valueForKey:@"Longitude"];
        NSNumber *latGridSpacing = [netcdfAttributes valueForKey:@"LatGridSpacing"];
        NSNumber *lonGridSpacing = [netcdfAttributes valueForKey:@"LonGridSpacing"];
        
        if (latitude && longitude) {
            CLLocationDegrees lat = [latitude doubleValue];
            CLLocationDegrees lon = [longitude doubleValue];
            _coordinate = CLLocationCoordinate2DMake(lat, lon);
        }
        
        if (latGridSpacing) {
            _latGridSpacing = [latGridSpacing floatValue];
        }
        if (lonGridSpacing) {
            _lonGridSpacing = [lonGridSpacing floatValue];
        }
    }
    
//    XLog(@"Image Coordinate: %f,%f",self.coordinate.latitude,self.coordinate.longitude);
//    XLog(@"Image NumLats: %li NumLons: %li",(long)self.numLats,(long)self.numLons);
//    XLog(@"Image latGridSpacing: %f lonGridSpacing: %f",self.latGridSpacing,self.lonGridSpacing);
}

-(BOOL)isInTimeframe:(GGTimeframe *)timeframe
{
    if (!timeframe) {
        return NO;
    }
    
    if (self.timeframeIDs && self.timeframeIDs.count == 0) {
        return YES;
    }
    
    if (self.timeframeIDs && [self.timeframeIDs containsObject:timeframe.timeframeID]) {
        return YES;
    }
    
    return NO;
}

@end
