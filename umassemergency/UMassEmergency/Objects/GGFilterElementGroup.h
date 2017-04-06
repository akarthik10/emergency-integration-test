//
//  GGFilterElementGroup.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 09.01.16.
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
#import "GGFilterElement.h"

@interface GGFilterElementGroup : NSObject

@property (nonatomic, strong) NSString *groupID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, readwrite) BOOL enabled;

@property (nonatomic, strong) NSArray *elements;

@end
