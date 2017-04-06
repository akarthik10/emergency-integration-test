//
//  UIImage+GGGrayScaleImage.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 03.09.15.
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

#import "UIImage+GGGrayScaleImage.h"

@implementation UIImage (GGGrayScaleImage)

-(UIImage *)grayScaleImage
{
//    CGFloat scale = [[UIScreen mainScreen] scale];
//    
//    // Create image rectangle with current image width/height
//    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
//    
//    // Grayscale color space
//    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
//    
//    // Create bitmap content with current image size and grayscale colorspace
//    CGContextRef context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, colorSpace, kCGImageAlphaNone);
//    
//    // Draw image into current context, with specified rectangle
//    // using previously defined context (with grayscale colorspace)
//    CGContextDrawImage(context, imageRect, [self CGImage]);
//    
//    // Create bitmap image info from pixel data in current context
//    CGImageRef imageRef = CGBitmapContextCreateImage(context);
//    
//    // Release colorspace, context and bitmap information
//    CGColorSpaceRelease(colorSpace);
//    CGContextRelease(context);
//    
//    context = CGBitmapContextCreate(nil, self.size.width, self.size.height, 8, 0, nil, kCGImageAlphaOnly);
//    CGContextDrawImage(context, imageRect, [self CGImage]);
//    CGImageRef mask = CGBitmapContextCreateImage(context);
//    
//    // Create a new UIImage object
//    UIImage *newImage = [UIImage imageWithCGImage:CGImageCreateWithMask(imageRef, mask)];
//    CGImageRelease(imageRef);
//    CGImageRelease(mask);
//    
//    // Return the new grayscale image
//    return newImage;

    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    CGRect imageRect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw a white background
    CGContextSetRGBFillColor(ctx, 1.0f, 1.0f, 1.0f, 1.0f);
    CGContextFillRect(ctx, imageRect);
    
    // Draw the luminosity on top of the white background to get grayscale
    [self drawInRect:imageRect blendMode:kCGBlendModeLuminosity alpha:1.0f];
    
    // Apply the source image's alpha
    [self drawInRect:imageRect blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    
    UIImage* grayscaleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return grayscaleImage;
}

@end
