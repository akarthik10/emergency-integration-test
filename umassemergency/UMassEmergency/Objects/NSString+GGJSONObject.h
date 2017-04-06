//
//  NSString+GGJSONObject.h
//  WindContours
//
//  Created by Görkem Güclü on 06.05.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import <Foundation/Foundation.h>

@interface NSString (GGJSONObject)

-(id)jsonObject;
-(id)jsonObjectWithReadingOptions:(NSJSONReadingOptions)options;

@end
