//
//  GGLocation.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 03.09.15.
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

#import "GGLocation.h"

@implementation GGLocation

- (instancetype)initWithName:(NSString *)name andLocation:(CLLocation *)location
{
    self = [super initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    if (self) {
        self.name = name;
    }
    return self;
}


-(BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[CLLocation class]]) {
        CLLocation *location = (CLLocation *)object;
        return self.coordinate.latitude == location.coordinate.latitude && self.coordinate.longitude == location.coordinate.longitude;
    }
    return NO;
}


-(NSDictionary *)dictionaryPresentation
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.name forKey:@"name"];

    NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
    [locationDic setValue:[NSNumber numberWithDouble:self.coordinate.latitude] forKey:@"latitude"];
    [locationDic setValue:[NSNumber numberWithDouble:self.coordinate.longitude] forKey:@"longitude"];

    [dic setValue:locationDic forKey:@"locations"];
    
    return dic;
}

@end
