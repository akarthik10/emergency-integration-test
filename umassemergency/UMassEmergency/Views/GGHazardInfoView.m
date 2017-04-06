//
//  GGHazardInfoView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 15.11.15.
//  Copyright © 2015 University of Massachusetts.
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

#import "GGHazardInfoView.h"
#import <QuartzCore/QuartzCore.h>

@interface GGHazardInfoView ()

@property (nonatomic, strong) UIView *blurView;
@property (nonatomic, strong) UIButton *overlayButton;

@end

@implementation GGHazardInfoView

-(IBAction)overlayButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(infoViewPressed:)]) {
        [self.delegate infoViewPressed:self];
    }
}

-(IBAction)infoButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(infoViewInfoButtonPressed:)]) {
        [self.delegate infoViewInfoButtonPressed:self];
    }
}

-(IBAction)closeButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(infoViewCloseButtonPressed:)]) {
        [self.delegate infoViewCloseButtonPressed:self];
    }
}

#pragma mark -

-(void)setHazard:(GGHazard *)hazard
{
    _hazard = hazard;
    if (hazard) {
        
        self.imageView.image = hazard.type.icon;
        self.titleLabel.text = hazard.headline;

        self.textView.text = hazard.summary;
        if (!hazard.summary || [hazard.summary isEqualToString:@""]) {
            self.textView.text = hazard.headline;
        }
        
        switch (hazard.isActive) {
            case GGHazardActiveNow:
                self.statusLabel.text = @"Active";
                self.statusLabel.textColor = [UIColor statusActiveColor];
                break;
            case GGHazardActivePassed:
                self.statusLabel.text = @"Expired";
                self.statusLabel.textColor = [UIColor statusExpiredColor];
                break;
                
            default:
                self.statusLabel.text = @"";
                self.statusLabel.textColor = [UIColor blackColor];
                break;
        }
    }
}


-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
 
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.backgroundColor = [UIColor clearColor];
    self.blurView = [[UIToolbar alloc] init];
    self.blurView.frame = self.bounds;
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.blurView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.blurView.layer.borderWidth = 0.5;
    [self insertSubview:self.blurView atIndex:0];
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    
    self.textView.textContainer.lineFragmentPadding = 0;
    self.textView.textContainerInset = UIEdgeInsetsZero;
    self.textView.userInteractionEnabled = NO;
    
    self.statusLabel.userInteractionEnabled = NO;

    self.overlayButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.overlayButton addTarget:self action:@selector(overlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.overlayButton.frame = self.bounds;
    self.overlayButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self insertSubview:self.overlayButton aboveSubview:self.blurView];
    
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.blurView.frame = CGRectInset(self.bounds, -1, -1);
}

@end
