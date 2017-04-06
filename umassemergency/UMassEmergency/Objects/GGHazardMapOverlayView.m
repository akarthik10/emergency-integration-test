//
//  GGHazardMapOverlayView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 21.04.15.
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

#import "GGHazardMapOverlayView.h"

@interface GGHazardMapOverlayView ()

@property (nonatomic, strong) UIImage *overlayImage;

@end

@implementation GGHazardMapOverlayView

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay overlayImage:(UIImage *)overlayImage {
    self = [super initWithOverlay:overlay];
    if (self) {
        _overlayImage = overlayImage;
    }
    
    return self;
}

- (void)drawMapRect:(MKMapRect)mapRect zoomScale:(MKZoomScale)zoomScale inContext:(CGContextRef)context {

    if (!self.overlayImage) {
        XLog(@"");
        return;
    }
    
//    CGSize size = CGSizeMake(self.overlayImage.size.width*self.overlayImage.scale, self.overlayImage.size.height*self.overlayImage.scale);
//
//    UIGraphicsBeginImageContext(size);
//    CGContextDrawImage(UIGraphicsGetCurrentContext(),CGRectMake(0.,0., size.width, size.height),self.overlayImage.CGImage);
//    UIImage *flippedImage = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    CGImageRef imageReference = flippedImage.CGImage;
    
    CGImageRef imageReference = self.overlayImage.CGImage;

    MKMapRect theMapRect = self.overlay.boundingMapRect;
    CGRect theRect = [self rectForMapRect:theMapRect];
    CGRect clipRect = [self rectForMapRect:mapRect];

    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, 0.0, -theRect.size.height);
    CGContextDrawImage(context, theRect, imageReference);
    CGContextAddRect(context, clipRect);
    CGContextClip(context);
    
    CGContextDrawImage(context, theRect, imageReference);
}

@end
