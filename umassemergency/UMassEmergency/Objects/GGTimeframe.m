//
//  GGTimeframe.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 11.07.15.
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

#import "GGTimeframe.h"

@interface GGTimeframe ()

@end

@implementation GGTimeframe


- (instancetype)initWithDuration:(NSTimeInterval)duration andSecondsFromNow:(NSInteger)secondsFromNow
{
    self = [super init];
    if (self) {
        _duration = duration;
        _secondsFromNow = secondsFromNow;        
    }
    return self;
}

-(BOOL)isDateInTimeframe:(NSDate *)date
{
    if (!date) {
        return NO;
    }
    
    if ([date compare:self.beginDate] == NSOrderedAscending)
    {
//        // date is before begin date
//        if ([date compare:self.endDate] == NSOrderedAscending) {
//            // date is before end date
//            return YES;
//        }
        return NO;
    }
    
    if ([date compare:self.endDate] == NSOrderedDescending)
    {
        // date is after end date
        return NO;
    }
    
    return YES;
}

-(BOOL)isDateBeforTimeframeEnds:(NSDate *)date
{
    if ([date compare:self.endDate] == NSOrderedDescending)
        return NO;
    return YES;
}

-(NSDate *)beginDate
{
    return [NSDate dateWithTimeIntervalSinceNow:self.secondsFromNow];
}

-(NSDate *)endDate
{
    return [[self beginDate] dateByAddingTimeInterval:self.duration];
}



@end
