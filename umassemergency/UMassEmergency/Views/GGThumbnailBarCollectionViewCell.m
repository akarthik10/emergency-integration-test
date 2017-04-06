//
//  GGThumbnailBarCollectionViewCell.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 03.12.16.
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

#import "GGThumbnailBarCollectionViewCell.h"

@interface GGThumbnailBarCollectionViewCell ()

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation GGThumbnailBarCollectionViewCell

-(void)setIsUploading:(BOOL)isUploading
{
    _isUploading = isUploading;
    if (isUploading) {
        [self.activityIndicator startAnimating];
        self.progressView.hidden = NO;
    }else{
        [self.activityIndicator stopAnimating];
        self.progressView.hidden = YES;
    }
}

-(void)setUploadProgress:(double)uploadProgress
{
    _uploadProgress = uploadProgress;
    self.progressView.progress = uploadProgress;
}

-(void)setMediaAsset:(GGMediaAsset *)mediaAsset
{
    _mediaAsset = mediaAsset;
    if (mediaAsset) {
        [mediaAsset loadImageWithCompletion:^(UIImage *image) {
            self.imageView.image = image;
        }];
        self.titleLabel.hidden = YES;
    }else{
        self.imageView.image = nil;
        self.titleLabel.hidden = NO;
    }
}

#pragma mark - 

-(void)setup
{
//    self.layer.borderColor = [UIColor whiteColor].CGColor;
//    self.layer.borderWidth = 0.5;
    
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.imageView.translatesAutoresizingMaskIntoConstraints = YES;
    self.imageView.layer.masksToBounds = YES;
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.backgroundColor = [UIColor clearColor];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"Select Photo";
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.numberOfLines = 0;
    self.titleLabel.font = [UIFont systemFontOfSize:20];
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicator.center = self.imageView.center;
    [self.activityIndicator hidesWhenStopped];
    
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    CGRect progressViewFrame = self.progressView.frame;
    progressViewFrame = CGRectMake(0, self.bounds.size.height-progressViewFrame.size.height-5, self.bounds.size.width, progressViewFrame.size.height);
    self.progressView.frame = progressViewFrame;
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.hidden = YES;

    [self addSubview:self.imageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.activityIndicator];
    [self addSubview:self.progressView];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

@end
