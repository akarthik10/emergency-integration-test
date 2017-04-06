//
//  GGSnapButton.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 23.08.16.
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

#import "GGSnapButton.h"
#import <QuartzCore/QuartzCore.h>

typedef enum : NSUInteger {
    GGSnapButtonModePhoto,
    GGSnapButtonModeVideo,
} GGSnapButtonMode;

@interface GGSnapButton () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIVisualEffectView *blurView;
@property (nonatomic, strong) UIView *buttonInsideView;
@property (nonatomic, strong) UIView *stopRecordingView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, readwrite) GGSnapButtonMode mode;

@end

@implementation GGSnapButton

#pragma mark -

-(NSString *)title
{
    return self.label.text;
}

-(void)setTitle:(NSString *)title
{
    self.label.text = title;
}

#pragma mark - 

-(void)showPhotoButton
{
    self.mode = GGSnapButtonModePhoto;
    self.label.text = @"Tap\n&\nSend";
    self.label.textColor = [UIColor blackColor];
    self.label.hidden = NO;
    [self layoutSnapButtonNormal];
}

-(void)showVideoButton
{
    self.mode = GGSnapButtonModeVideo;
    self.stopRecordingView.hidden = YES;
    self.stopRecordingView.hidden = YES;
    self.buttonInsideView.hidden = NO;
    self.label.hidden = NO;
    self.label.text = @"Record\n&\nSend";
    self.label.textColor = [UIColor whiteColor];
    [self layoutSnapButtonNormal];
}

-(void)showRecordingButton
{
    self.mode = GGSnapButtonModeVideo;
    self.stopRecordingView.hidden = NO;
    self.buttonInsideView.hidden = YES;
    self.label.hidden = YES;
}

#pragma mark -

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self layoutSnapButtonPressed];
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self layoutSnapButtonNormal];
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self layoutSnapButtonNormal];
}

-(void)snapButtonPressed:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(snapButtonDidPress:)]) {
            [self.delegate snapButtonDidPress:self];
        }
    }
}

-(void)snapButtonLongPressed:(UILongPressGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(snapButtonDidEndLongPress:)]) {
            [self.delegate snapButtonDidEndLongPress:self];
        }

    }else if(sender.state == UIGestureRecognizerStateBegan) {

        if (self.delegate && [self.delegate respondsToSelector:@selector(snapButtonDidBeginLongPress:)]) {
            [self.delegate snapButtonDidBeginLongPress:self];
        }
    }
}

#pragma mark -

-(void)layoutSnapButtonPressed
{
    self.buttonInsideView.backgroundColor = [UIColor lightGrayColor];
    if (self.mode == GGSnapButtonModePhoto) {
        self.buttonInsideView.backgroundColor = [UIColor lightGrayColor];
    }else{
        self.buttonInsideView.backgroundColor = [UIColor darkRedColor];
    }
}

-(void)layoutSnapButtonNormal
{
    if (self.mode == GGSnapButtonModePhoto) {
        self.buttonInsideView.backgroundColor = [UIColor whiteColor];
    }else{
        self.buttonInsideView.backgroundColor = [UIColor redColor];
    }
}


-(void)setupLayout
{
    self.backgroundColor = [UIColor clearColor];
    
    self.blurView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleLight]];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.blurView.frame = self.bounds;
    self.blurView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.blurView];
    
    self.buttonInsideView = [[UIView alloc] init];
    self.buttonInsideView.frame = CGRectInset(self.bounds, 10, 10);
    self.buttonInsideView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.buttonInsideView];

    self.stopRecordingView = [[UIView alloc] init];
    self.stopRecordingView.frame = CGRectMake(0, 0, self.bounds.size.width/2, self.bounds.size.width/2);
    self.stopRecordingView.center = self.buttonInsideView.center;
    self.stopRecordingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.stopRecordingView.hidden = YES;
    self.stopRecordingView.backgroundColor = [UIColor redColor];
    [self addSubview:self.stopRecordingView];

    self.label = [[UILabel alloc] initWithFrame:self.buttonInsideView.frame];
    self.label.numberOfLines = 0;
    self.label.font = [UIFont boldSystemFontOfSize:12];
    self.label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.label];
    
    [self layoutSnapButtonNormal];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapButtonPressed:)];
    tapGesture.delegate = self;
    [self addGestureRecognizer:tapGesture];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(snapButtonLongPressed:)];
    longPress.delegate = self;
    longPress.minimumPressDuration = 0.5;
    [self addGestureRecognizer:longPress];
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self setupLayout];
}

+(instancetype)buttonWithType:(UIButtonType)buttonType
{
    GGSnapButton *snapButton = [super buttonWithType:buttonType];
    [snapButton setupLayout];
    return snapButton;
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.layer.masksToBounds = YES;
    self.layer.cornerRadius = self.frame.size.width/2;
    self.blurView.frame = self.bounds;
    
    CGRect innerFrame = CGRectInset(self.bounds, 10, 10);
    self.buttonInsideView.frame = innerFrame;
    self.buttonInsideView.layer.cornerRadius = innerFrame.size.width/2;

    self.stopRecordingView.frame = CGRectMake(0, 0, self.bounds.size.width/3, self.bounds.size.width/3);
    self.stopRecordingView.center = self.buttonInsideView.center;
}

@end
