//
//  GGSelectedTimeframeView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 17.12.15.
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

#import "GGSelectedTimeframeView.h"

@interface GGSelectedTimeframeView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIToolbar *blurView;

@end

@implementation GGSelectedTimeframeView


-(void)setTitle:(NSString *)title
{
    [self setTitle:title animated:NO];
}

-(void)setTitle:(NSString *)title animated:(BOOL)animated
{
    self.titleLabel.text = title;
    
    if (animated) {
        [self animateTimeLabels];
    }
}

-(void)setSubitle:(NSString *)subtitle
{
    self.subtitleLabel.text = subtitle;
}

-(void)setTimeframe:(GGTimeframe *)timeframe
{
    _timeframe = timeframe;
    if (timeframe) {
        
        [self updateTimeLabelsAnimated:YES];
        
    }else{
        self.titleLabel.text = @"";
        self.subtitleLabel.text = @"";
    }
}


-(void)updateTimeLabelsAnimated:(BOOL)animated
{
    if (self.timeframe) {
        
        self.titleLabel.text = self.timeframe.title;
        
        NSDate *beginDate = self.timeframe.beginDate;
        NSDate *endDate = self.timeframe.endDate;
        
        NSString *beginString = [NSDateFormatter localizedStringFromDate:beginDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
        NSString *endString = [NSDateFormatter localizedStringFromDate:endDate dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];

        self.subtitleLabel.text = [NSString stringWithFormat:@"%@ - %@",beginString,endString];
        
        if (animated) {
            [self animateTimeLabels];
        }
    }
}

#pragma mark -

-(void)animateTimeLabels
{
    [UIView animateWithDuration:0.15
                          delay:0
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                     animations:^{
                        
                         self.titleLabel.alpha = 0.3;
                         self.titleLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
//                         self.subtitleLabel.alpha = 0.3;
//                         self.subtitleLabel.transform = CGAffineTransformMakeScale(1.2, 1.2);
                         
                     } completion:^(BOOL finished) {

                         [UIView animateWithDuration:0.25
                                               delay:0
                                             options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                                          animations:^{
                                              
                                              self.titleLabel.alpha = 1;
                                              self.titleLabel.transform = CGAffineTransformIdentity;
//                                              self.subtitleLabel.alpha = 1;
//                                              self.subtitleLabel.transform = CGAffineTransformIdentity;
                                              
                                          } completion:^(BOOL finished) {
                                              
                                              self.titleLabel.alpha = 1;
                                              self.titleLabel.transform = CGAffineTransformIdentity;
//                                              self.subtitleLabel.alpha = 1;
//                                              self.subtitleLabel.transform = CGAffineTransformIdentity;

                                          }];

                     }];
}


#pragma mark -

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

-(void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

-(void)setup
{
    self.backgroundColor = [UIColor clearColor];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.text = @"test";
    
    self.subtitleLabel = [[UILabel alloc] init];
    self.subtitleLabel.textAlignment = NSTextAlignmentCenter;
    self.subtitleLabel.backgroundColor = [UIColor clearColor];
    self.subtitleLabel.font = [UIFont systemFontOfSize:10];
    self.subtitleLabel.text = @"test";
    
    self.blurView = [[UIToolbar alloc] initWithFrame:self.bounds];
    self.blurView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.blurView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.blurView.layer.borderWidth = 0.5;
    [self addSubview:self.blurView];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];

    self.titleLabel.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height*0.5);
    self.subtitleLabel.frame = CGRectMake(0, self.frame.size.height*0.5, self.frame.size.width, self.frame.size.height*0.5);
    self.blurView.frame = CGRectInset(self.bounds, -1, -1);

//    self.titleLabel.frame = CGRectMake(0, 0, 100, 25);
//    self.subtitleLabel.frame = CGRectMake(0, 25, 100, 25);

}

@end
