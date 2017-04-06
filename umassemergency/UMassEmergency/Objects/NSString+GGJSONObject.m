//
//  NSString+GGJSONObject.m
//  WindContours
//
//  Created by Görkem Güclü on 06.05.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "NSString+GGJSONObject.h"

@implementation NSString (GGJSONObject)


-(id)jsonObject
{
    return [self jsonObjectWithReadingOptions:NSJSONReadingMutableContainers];
}

-(id)jsonObjectWithReadingOptions:(NSJSONReadingOptions)options
{
    NSError *error;
    id object = [NSJSONSerialization JSONObjectWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
                                    options:options
                                      error:&error];
    if (error) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return [NSDictionary dictionary];
    } else {
        return object;
    }
}

@end
