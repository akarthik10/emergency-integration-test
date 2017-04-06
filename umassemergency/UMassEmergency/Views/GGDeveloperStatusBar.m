//
//  GGDeveloperStatusBar.m
//  WindContours
//
//  Created by Görkem Güclü on 13.06.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "GGDeveloperStatusBar.h"

@interface GGDeveloperStatusBar ()

@property (nonatomic, strong) NSTimer *timer;

@end

@implementation GGDeveloperStatusBar

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
    self.statusLabel = [[UILabel alloc] init];
    self.statusLabel.backgroundColor = [UIColor clearColor];
    self.statusLabel.font = [UIFont systemFontOfSize:12];
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
    self.statusLabel.textAlignment = NSTextAlignmentLeft;

    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.font = [UIFont systemFontOfSize:11];
    self.timeLabel.adjustsFontSizeToFitWidth = YES;
    self.timeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
    [self addSubview:self.statusLabel];
    [self addSubview:self.timeLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat timeLabelWidth = 120;
    CGFloat margin = 5;
    
    CGRect frame = self.frame;
    self.statusLabel.frame = CGRectMake(margin, 0, frame.size.width-timeLabelWidth-2*margin, frame.size.height);
    self.timeLabel.frame = CGRectMake(frame.size.width-timeLabelWidth-margin, 0, timeLabelWidth, frame.size.height);
}

-(void)updateTime
{
    NSDate *date = [NSDate now];
    NSString *time = [NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    self.timeLabel.text = time;
}

#pragma mark - 


-(void)startTimer
{
    [self stopTimer];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

-(void)stopTimer
{
    if ([self.timer isValid]) {
        [self.timer invalidate];
    }
    self.timer = nil;
}

-(void)timerFired:(NSTimer *)timer
{
    [self updateTime];
}

@end
