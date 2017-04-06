//
//  GGNotificationView.m
//  BusTrack
//
//  Created by Görkem Güclü on 05.03.15.
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

#import "GGNotificationView.h"

@interface GGNotificationView ()

@property (nonatomic, strong) UIView *backgroundView;

@end

@implementation GGNotificationView

-(IBAction)textButtonDidTouchDown:(id)sender
{
    self.backgroundColor = [UIColor colorWithRed:0.929 green:0.925 blue:0.925 alpha:1.000];
}

-(IBAction)textButtonPressed:(id)sender
{
    self.backgroundColor = [UIColor whiteColor];
    if (self.delegate && [self.delegate respondsToSelector:@selector(notificationDidGetPressed:)]) {
        [self.delegate notificationDidGetPressed:self];
    }
}

-(IBAction)closeButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(notificationDidClose:)]) {
        [self.delegate notificationDidClose:self];
    }
}


-(void)setNotification:(GGNotification *)notification
{
    _notification = notification;
    if (notification) {
        self.textLabel.text = notification.alertText;
//        [self.textButton setTitle:notification.alertText forState:UIControlStateNormal];
    }
}

#pragma mark -


#pragma mark -


- (instancetype)init
{
    self = [super init];
    if (self) {
        
        [self setupView];
        
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupView];
        
    }
    return self;
}

- (instancetype)initWithNotification:(GGNotification *)notification
{
    self = [super init];
    if (self) {
        
        [self setupView];
        self.notification = notification;
        
    }
    return self;
}

-(void)setupView
{
    self.backgroundColor = [UIColor clearColor];
    self.userInteractionEnabled = YES;
    self.clipsToBounds = YES;
    
    self.backgroundView = [[UIView alloc] initWithFrame:self.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.85];
//    self.backgroundView.backgroundColor = [UIColor notificationBackgroundColor];
    
    self.textLabel = [[UILabel alloc] init];
    self.textLabel.font = [UIFont systemFontOfSize:14];
    self.textLabel.textColor = [UIColor whiteColor];
    self.textLabel.numberOfLines = 0;
    self.textLabel.adjustsFontSizeToFitWidth = YES;
    self.textLabel.backgroundColor = [UIColor clearColor];
//    self.textLabel.backgroundColor = [UIColor redColor];
    
    self.textButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.textButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    self.textButton.titleLabel.numberOfLines = 0;
    self.textButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.textButton.titleLabel.adjustsFontSizeToFitWidth = YES;
//    self.textButton.backgroundColor = [UIColor redColor];
    [self.textButton addTarget:self action:@selector(textButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.textButton addTarget:self action:@selector(textButtonDidTouchDown:) forControlEvents:UIControlEventTouchDown];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.image = [UIImage imageNamed:@"casa-logo-small"];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.imageView.contentMode = UIViewContentModeCenter;
    self.imageView.backgroundColor = [UIColor whiteColor];
    
    self.closeButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.closeButton addTarget:self action:@selector(closeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.closeButton setImage:[UIImage imageNamed:@"close-icon"] forState:UIControlStateNormal];
    [self.closeButton setImage:[UIImage imageNamed:@"close-empty-icon"] forState:UIControlStateNormal];
    [self.closeButton setTintColor:[UIColor whiteColor]];
//    self.closeButton.backgroundColor = [UIColor yellowColor];
    
    [self addSubview:self.backgroundView];
    [self addSubview:self.textLabel];
    [self addSubview:self.textButton];
    [self addSubview:self.imageView];
    [self addSubview:self.closeButton];
}


-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.frame.size.width;

    self.backgroundView.frame = self.bounds;
    
    self.textButton.frame = self.bounds;
    
    self.imageView.frame = CGRectMake(5, 40, 40, 40);
    self.imageView.layer.cornerRadius = 10;
    self.textLabel.frame = CGRectMake(50, 20, width-50-50, 80);
    self.closeButton.frame = CGRectMake(width-55, 40, 50, 40);
}

@end
