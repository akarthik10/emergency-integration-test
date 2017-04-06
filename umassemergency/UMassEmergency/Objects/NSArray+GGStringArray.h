//
//  NSArray+GGStringArray.h
//  WindContours
//
//  Created by Görkem Güclü on 04.01.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import <Foundation/Foundation.h>

@interface NSArray (GGStringArray)

-(NSArray *)arrayWithStringValues;
+(NSArray *)arrayWithStringValuesForArray:(NSArray *)array;

@end
