//
//  GGMediaAsset.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 24.08.16.
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

#import "GGMediaAsset.h"
#import <AVFoundation/AVFoundation.h>
#import <Photos/Photos.h>

@interface GGMediaAsset ()

@property (nonatomic, strong) UIImage *image;

@end

@implementation GGMediaAsset

-(void)loadImageWithCompletion:(void (^)(UIImage *image))completion
{
    if (self.url) {
        
        if (_image) {
            completion(_image);
            return;
        }
        
        if (self.isVideo) {

            [[[NSOperationQueue alloc] init] addOperationWithBlock:^{
               
                AVURLAsset *asset = [AVURLAsset URLAssetWithURL:self.url options:nil];
                AVAssetImageGenerator *imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
                [imageGenerator setAppliesPreferredTrackTransform:TRUE];
                UIImage *image = [UIImage imageWithCGImage:[imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil]];
                
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    completion(image);
                }];
                
            }];
            
        }else{
            
            if ([self.url.scheme isEqualToString:@"assets-library"]) {
                // Photo
                PHFetchResult *result = [PHAsset fetchAssetsWithALAssetURLs:@[self.url] options:nil];
                if (result.count > 0) {
                    PHAsset *asset = [result firstObject];
                    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:PHImageManagerMaximumSize contentMode:PHImageContentModeDefault options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                        
                        completion(result);
                        
                    }];
                }
                
            }else{
                // Disc
                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.url]];
                completion(image);
            }
        }
    }
}



#pragma mark -

- (instancetype)initWithImage:(UIImage *)image
{
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (instancetype)initWithURL:(NSURL *)url
{
    self = [super init];
    if (self) {
        self.url = url;
    }
    return self;
}

@end
