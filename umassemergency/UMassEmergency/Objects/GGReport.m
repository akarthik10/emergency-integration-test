//
//  GGReport.m
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

#import "GGReport.h"

@implementation GGReport



-(void)addAsset:(GGMediaAsset *)asset
{
    [self.assets addObject:asset];
}

-(void)removeAsset:(GGMediaAsset *)asset
{
    [self.assets removeObject:asset];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc] init];

        NSTimeInterval timestamp = [NSDate date].timeIntervalSinceReferenceDate;
        NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
        uuid = [uuid substringToIndex:10];
        NSString *sessionID = [NSString stringWithFormat:@"%@-%li",uuid,(long)timestamp];

        self.sessionID = sessionID;
    }
    return self;
}

- (instancetype)initWithSessionID:(NSString *)sessionID
{
    self = [super init];
    if (self) {
        self.assets = [[NSMutableArray alloc] init];
        self.sessionID = sessionID;
    }
    return self;
}

@end
