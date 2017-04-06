//
//  GGCarouselTimeframeView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 11.07.15.
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

#import "GGCarouselTimeframeView.h"
#import <CoreGraphics/CoreGraphics.h>

@interface GGCarouselTimeframeView ()

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation GGCarouselTimeframeView


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

-(void)setup
{
    self.timeLabel = [[UILabel alloc] initWithFrame:self.bounds];
    self.timeLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    self.timeLabel.numberOfLines = 0;
    self.timeLabel.font = [UIFont systemFontOfSize:11];
//    self.timeLabel.layer.cornerRadius = 5;
    self.timeLabel.layer.borderWidth = 1;
    self.timeLabel.clipsToBounds = YES;
    self.timeLabel.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.timeLabel];

    self.selected = NO;
}

-(void)setSelected:(BOOL)selected
{
    _selected = selected;
    if (selected) {
//        self.timeLabel.backgroundColor = [UIColor lightGrayColor];
        self.timeLabel.layer.borderColor = [UIColor casaBrandDarkColor].CGColor;
    }else{
//        self.timeLabel.backgroundColor = [UIColor whiteColor];
        self.timeLabel.layer.borderColor = [UIColor clearColor].CGColor;
    }
}

-(void)setTimeframe:(GGTimeframe *)timeframe
{
    _timeframe = timeframe;
    if (timeframe) {
        self.timeLabel.text = timeframe.title;
    }else{
        self.timeLabel.text = nil;
    }
}

-(void)tintColorDidChange
{
    self.timeLabel.textColor = self.tintColor;
}

@end
