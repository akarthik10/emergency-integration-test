//
//  GGAttribute.h
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

#import <Foundation/Foundation.h>
#import "GGAttributeValue.h"

typedef enum : NSUInteger {
    GGAttributeTypeBool,
    GGAttributeTypeNumber,
    GGAttributeTypeText,
    GGAttributeTypeRange,
    GGAttributeTypeUnknown,
} GGAttributeType;

@interface GGAttribute : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSArray *options;
@property (nonatomic, readwrite) NSInteger selectCount;
@property (nonatomic, readwrite) GGAttributeType type;

@property (nonatomic, strong) NSArray *selectedValues;

-(NSString *)selectedValuesString;

+(GGAttributeType)typeForTypeName:(NSString *)name;

@end
