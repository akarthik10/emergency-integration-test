//
//  NSDictionary+GGSortedDictionary.h
//  WindContours
//
//  Created by Görkem Güclü on 24.03.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GGSortedDictionary)

-(NSArray *)allKeysSortedAlphabeticallyAscending:(BOOL)ascending;

@end
