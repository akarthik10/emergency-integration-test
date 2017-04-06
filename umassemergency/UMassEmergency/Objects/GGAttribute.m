//
//  GGAttribute.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 10.07.16.
//  Copyright © 2016 University of Massachusetts.
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

#import "GGAttribute.h"

@implementation GGAttribute

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.selectedValues = [NSArray array];
    }
    return self;
}


-(NSString *)selectedValuesString
{
    if (self.selectedValues.count > 0) {

        if (self.selectedValues.count > 1) {
            NSString *string = @"";
            for (GGAttributeValue *value in self.selectedValues) {
                if ([self.selectedValues indexOfObject:value] != 0) {
                    string = [string stringByAppendingString:@", "];
                }
                string = [string stringByAppendingString:value.title];
            }
            return string;
        }

        GGAttributeValue *value = self.selectedValues[0];
        return value.title;
    }
    return @"";
}

+(GGAttributeType)typeForTypeName:(NSString *)name
{
    if ([name isEqualToString:@"range"]) {
        return GGAttributeTypeRange;
    }else if ([name isEqualToString:@"bool"]) {
        return GGAttributeTypeBool;
    }else if ([name isEqualToString:@"number"]) {
        return GGAttributeTypeNumber;
    }else if ([name isEqualToString:@"text"]) {
        return GGAttributeTypeText;
    }
    return GGAttributeTypeUnknown;
}

@end
