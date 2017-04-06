//
//  GGReport.h
//  UMassEmergency
//
//  Created by Görkem Güclü on 09.01.17.
//  Copyright © 2017 University of Massachusetts.
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
#import "GGMediaAsset.h"

@interface GGReport : NSObject

@property (nonatomic, strong) NSString *sessionID;
@property (nonatomic, strong) CLLocation *location;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSMutableArray<GGMediaAsset *> *assets;

-(void)addAsset:(GGMediaAsset *)asset;
-(void)removeAsset:(GGMediaAsset *)asset;

- (instancetype)initWithSessionID:(NSString *)sessionID;

@end
