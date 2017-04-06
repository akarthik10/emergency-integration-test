//
//  GGWarningType.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 06.01.16.
//  Copyright © 2016 University of Massachusetts.
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

#import "GGWarningType.h"

@implementation GGWarningType


-(UIImage *)annotationIcon
{
    if (_annotationIcon) {
        return _annotationIcon;
    }
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    view.frame = CGRectMake(0, 0, self.iconSmall.size.width+10, self.iconSmall.size.width+10);
    view.opaque = NO;
    
    UIView *background = [[UIView alloc] init];
    background.backgroundColor = self.color;
    background.frame = view.bounds;
    background.layer.cornerRadius = background.frame.size.width/2;
    background.layer.borderColor = [UIColor blackColor].CGColor;
    background.layer.borderWidth = 1;
    background.layer.masksToBounds = YES;
    background.opaque = NO;
    [view addSubview:background];
    
//    UIImage *backgroundImage = [GGWarningType imageWithView:view];
    UIImage *backgroundImage = view.image;
//    UIImage *annotation = [self imageByCombiningImage:backgroundImage withImage:self.iconSmall];
    _annotationIcon = [UIImage imageByCombiningImage:backgroundImage withImage:self.iconSmall];
    
    return _annotationIcon;
}

//- (UIImage *)imageByCombiningImage:(UIImage*)firstImage withImage:(UIImage*)secondImage {
//    UIImage *image = nil;
//    
//    CGSize newImageSize = CGSizeMake(MAX(firstImage.size.width, secondImage.size.width), MAX(firstImage.size.height, secondImage.size.height));
//    if ((UIGraphicsBeginImageContextWithOptions) != NULL) {
//        UIGraphicsBeginImageContextWithOptions(newImageSize, NO, [[UIScreen mainScreen] scale]);
//    } else {
//        UIGraphicsBeginImageContext(newImageSize);
//    }
//    [firstImage drawAtPoint:CGPointMake(roundf((newImageSize.width-firstImage.size.width)/2),
//                                        roundf((newImageSize.height-firstImage.size.height)/2))];
//    [secondImage drawAtPoint:CGPointMake(roundf((newImageSize.width-secondImage.size.width)/2),
//                                         roundf((newImageSize.height-secondImage.size.height)/2))];
//    image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    
//    return image;
//}


@end
