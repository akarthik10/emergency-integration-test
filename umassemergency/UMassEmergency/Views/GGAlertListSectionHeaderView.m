//
//  GGAlertListSectionHeaderView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 20.12.15.
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

#import "GGAlertListSectionHeaderView.h"

@interface GGAlertListSectionHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *visibiltyButton;

@end

@implementation GGAlertListSectionHeaderView

-(IBAction)visibilityButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alertListSectionHeaderDidPressVisibilityButton:)]) {
        [self.delegate alertListSectionHeaderDidPressVisibilityButton:self];
    }
}


#pragma mark -

-(void)setTitle:(NSString *)title
{
    _title = title;
    self.titleLabel.text = title;
}

-(void)setVisibiltyButtonTitle:(NSString *)visibiltyButtonTitle
{
    _visibiltyButtonTitle = visibiltyButtonTitle;
    [self.visibiltyButton setTitle:visibiltyButtonTitle forState:UIControlStateNormal];
}


#pragma mark -

-(void)setup
{
    self.backgroundColor = [[UIColor superLightGrayColor] colorWithAlphaComponent:0.90];

    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    self.titleLabel.backgroundColor = [UIColor clearColor];
//    self.titleLabel.backgroundColor = [UIColor blueColor];
    self.titleLabel.frame = CGRectMake(10, 0, 180, self.bounds.size.height);
//    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0, 10, 0, 0);
//    CGRect paddedFrame = UIEdgeInsetsInsetRect(initialFrame, contentInsets);
//    self.titleLabel.frame = paddedFrame;
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin;

    self.visibiltyButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.visibiltyButton.backgroundColor = [UIColor clearColor];
//    self.visibiltyButton.backgroundColor = [UIColor redColor];
    self.visibiltyButton.frame = CGRectMake(self.bounds.size.width-70, 0, 70, self.bounds.size.height);
    self.visibiltyButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin;
    [self.visibiltyButton addTarget:self action:@selector(visibilityButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    [self addSubview:self.titleLabel];
    [self addSubview:self.visibiltyButton];
}

#pragma mark -

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

#pragma mark -

-(void)layoutSubviews
{
    [super layoutSubviews];
    
}

@end
