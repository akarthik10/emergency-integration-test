//
//  GGThumbnailBarView.m
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

#import "GGThumbnailBarView.h"

@interface GGThumbnailBarView ()

@property (nonatomic, strong) NSMutableArray *thumbnails;
@property (nonatomic, strong) NSMutableArray *thumbnailButtons;

@end

@implementation GGThumbnailBarView

-(NSArray<GGMediaAsset *> *)mediaAssets
{
    return self.thumbnails;
}

#pragma mark - 

-(IBAction)buttonSelected:(id)sender
{
    UIButton *selectedButton = (UIButton *)sender;
    NSUInteger index = [self.thumbnailButtons indexOfObject:selectedButton];
    GGMediaAsset *thumbnail = [self.thumbnails objectAtIndex:index];
    if (self.thumbnailDelegate && [self.thumbnailDelegate respondsToSelector:@selector(thumbnailBar:didSelectThumbnail:)]) {
        [self.thumbnailDelegate thumbnailBar:self didSelectThumbnail:thumbnail];
    }
}


#pragma mark -

-(void)addThumbnail:(GGMediaAsset *)thumbnail animated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [thumbnail loadImageWithCompletion:^(UIImage *image) {
        if (image) {
            [button setImage:image forState:UIControlStateNormal];
        }
    }];
    button.alpha = 0;
    button.layer.borderColor = [UIColor whiteColor].CGColor;
    button.layer.borderWidth = 0.5;
    button.layer.masksToBounds = YES;
    button.clipsToBounds = NO;
    button.backgroundColor = [UIColor yellowColor];
    button.imageView.contentMode = UIViewContentModeScaleAspectFill;
    button.contentMode = UIViewContentModeScaleAspectFill;
    button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentFill;
    button.contentVerticalAlignment = UIControlContentVerticalAlignmentFill;
    [button addTarget:self action:@selector(buttonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat height = self.frame.size.height;
    CGFloat x = self.thumbnailButtons.count * height;
    button.frame = CGRectMake(x, 0, height, height);

    [self addSubview:button];

    self.contentSize = CGSizeMake(x+height, height);
    
    [self.thumbnailButtons addObject:button];
    [self.thumbnails addObject:thumbnail];
    
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            button.alpha = 1;
            
        } completion:completion];
    }else{
        button.alpha = 1;
    }
    
}

-(void)removeThumbnail:(UIImage *)image
{
    
}

-(void)removeThumbnailAtIndex:(NSInteger *)index
{
    
}


#pragma mark - 

-(void)setup
{
    self.alwaysBounceHorizontal = YES;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];

    self.thumbnails = [[NSMutableArray alloc] init];
    self.thumbnailButtons = [[NSMutableArray alloc] init];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

@end
