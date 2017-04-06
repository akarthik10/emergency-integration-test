//
//  NSDictionary+GGStringDictionary.m
//  WindContours
//
//  Created by Görkem Güclü on 04.01.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "NSDictionary+GGStringDictionary.h"
#import "NSArray+GGStringArray.h"

@implementation NSDictionary (GGStringDictionary)

-(NSDictionary *)dictionaryWithStringValues
{
    return [NSDictionary dictionaryWithStringValuesForDictionary:self];
}

+(NSDictionary *)dictionaryWithStringValuesForDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in [dictionary allKeys]) {
        id value = [dictionary valueForKey:key];
        if ([value isKindOfClass:[NSString class]]) {

            // all good
            [dic setValue:value forKey:key];
            
        }else if ([value isKindOfClass:[NSDictionary class]]) {
            
            // go deeper
            NSDictionary *newValue = [NSDictionary dictionaryWithStringValuesForDictionary:value];
            [dic setValue:newValue forKey:key];
            
        }else if ([value isKindOfClass:[NSArray class]]){
            
            // array
            NSArray *array = (NSArray *)value;
            NSArray *stringArray = [NSArray arrayWithStringValuesForArray:array];
            [dic setValue:stringArray forKey:key];
            
        }else {
            @try {
                // Try something
                NSString *stringValue = [value stringValue];
                [dic setValue:stringValue forKey:key];
            }
            @catch (NSException * e) {
                NSLog(@"Exception: %@", e);
            }
        }
    }
    return dic;
}


@end
