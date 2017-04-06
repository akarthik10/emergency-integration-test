//
//  NSDictionary+GGSortedDictionary.m
//  WindContours
//
//  Created by Görkem Güclü on 24.03.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//

#import "NSDictionary+GGSortedDictionary.h"

@implementation NSDictionary (GGSortedDictionary)

-(NSArray *)allKeysSortedAlphabeticallyAscending:(BOOL)ascending
{
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"description" ascending:ascending];
    return [self.allKeys sortedArrayUsingDescriptors:@[descriptor]];
}


@end
