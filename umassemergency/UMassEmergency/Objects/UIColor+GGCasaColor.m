//
//  UIColor+GGCasaColor.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 14.05.15.
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

#import "UIColor+GGCasaColor.h"

@implementation UIColor (GGCasaColor)


+(UIColor *)umassMaroonColor
{
    return [UIColor colorWithRed:0.427 green:0.000 blue:0.039 alpha:1.000];
}

+(UIColor *)casaBrandColor
{
    return [UIColor colorWithRed:0.604 green:0.863 blue:0.988 alpha:1.000];
}

+(UIColor *)casaBrandDarkColor
{
    return [UIColor colorWithRed:0.404 green:0.510 blue:0.545 alpha:1.000];
}

+(UIColor *)superLightGrayColor
{
    return [UIColor colorWithRed:0.949 green:0.949 blue:0.949 alpha:1.000];
}

+(UIColor *)darkGreenColor
{
    return [UIColor colorWithRed:0.008 green:0.588 blue:0.169 alpha:1.000];
}

+(UIColor *)darkRedColor
{
    return [UIColor colorWithRed:0.427 green:0.000 blue:0.039 alpha:1.000];
}

+(UIColor *)notificationBackgroundColor
{
    return [UIColor colorWithRed:1.000 green:0.973 blue:0.702 alpha:1.000];
}

+(UIColor *)statusActiveColor
{
    return [UIColor darkGreenColor];
}

+(UIColor *)statusExpiredColor
{
    return [UIColor darkRedColor];
}

+(UIColor *)statusPendingColor
{
    return [UIColor colorWithRed:0.271 green:0.541 blue:1.000 alpha:1.000];
}

+ (UIColor *)colorFromHexString:(NSString *)hexString
{
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

@end
