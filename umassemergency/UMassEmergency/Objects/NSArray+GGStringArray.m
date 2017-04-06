//
//  NSArray+GGStringArray.m
//  WindContours
//
//  Created by Görkem Güclü on 04.01.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "NSArray+GGStringArray.h"
#import "NSDictionary+GGStringDictionary.h"

@implementation NSArray (GGStringArray)

-(NSArray *)arrayWithStringValues
{
    return [NSArray arrayWithStringValuesForArray:self];
}

+(NSArray *)arrayWithStringValuesForArray:(NSArray *)array
{
    NSMutableArray *ar = [[NSMutableArray alloc] init];
    
    for (id value in array) {

        if ([value isKindOfClass:[NSString class]]) {
            
            // all good
            [ar addObject:value];
            
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            
            // go deeper
            NSDictionary *newValue = [NSDictionary dictionaryWithStringValuesForDictionary:value];
            [ar addObject:newValue];
            
        }else if ([value isKindOfClass:[NSArray class]]){
            
            NSArray *subArray = (NSArray *)value;
            NSArray *stringArray = [NSArray arrayWithStringValuesForArray:subArray];
            [ar addObject:stringArray];
            
        }else{
            @try {
                // Try something
                NSString *stringValue = [value stringValue];
                [ar addObject:stringValue];
            }
            @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            }
        }
    }
    
    return ar;
}

@end
