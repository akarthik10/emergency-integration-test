//
//  GGDataManager.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 12.04.15.
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
#import "GGUser.h"
#import <XMLDictionary/XMLDictionary.h>
#import <AFNetworking/AFNetworking.h>
#import <CoreLocation/CoreLocation.h>
#import "GGWarningCategory.h"
#import "GGHazard.h"


@interface GGDataManager : NSObject

@property (nonatomic, strong) NSArray *attributes;
@property (nonatomic, strong) NSArray *warningPreferences;
@property (nonatomic, strong) NSArray *warningTypeGroups;
@property (nonatomic, strong) NSMutableDictionary *userPreferences;
@property (nonatomic, strong) NSArray *alertFiles;
@property (nonatomic, strong, readonly) NSArray *hazards;

@property (nonatomic, strong) NSDate *lastAlertUpdateDate;

@property (nonatomic, strong) NSArray *timeframes;
@property (nonatomic, strong) NSArray *simulationLocations;

-(void)updateAlertsWithCompletion:(void (^)(void))completion tooEarly:(void (^)(void))tooEarlyBlock;
-(void)updateAlertsWithCompletion:(void (^)(void))completion;
-(void)downloadAlert:(NSString *)alertID withCompletion:(void (^)(GGHazard *hazard))completion;

-(NSArray *)hazardsSortedByLocation:(NSArray *)hazards;
-(void)updateHazardsDistanceToLocation:(CLLocation *)location;
-(void)updateHazardsDirectionToHeading:(CLHeading *)heading andLocation:(CLLocation *)location;

-(void)addHazard:(GGHazard *)hazard;
-(void)removeHazard:(GGHazard *)hazard;
-(GGHazard *)hazardWithHazardID:(NSString *)hazardID;

-(void)saveSelectedPreference:(GGWarningPreference *)preference;
-(void)uploadAttributesPreferencesWithCompletion:(void (^)(NSString *error))completionBlock;
-(void)downloadAttributesPreferencesWithCompletion:(void (^)(NSString *error))completionBlock;

@end
