//
//  NSDictionary+GGStringDictionary.h
//  WindContours
//
//  Created by Görkem Güclü on 04.01.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GGStringDictionary)

-(NSDictionary *)dictionaryWithStringValues;
+(NSDictionary *)dictionaryWithStringValuesForDictionary:(NSDictionary *)dic;

@end
