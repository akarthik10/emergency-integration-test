//
//  GGDistanceCompassView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 05.11.15.
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

#import "GGDistanceCompassView.h"

@interface GGDistanceCompassView ()

@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) UIView *compassView;
@property (nonatomic, strong) UIImageView *arrowImageView;

@end

@implementation GGDistanceCompassView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)setDistanceInMiles:(BOOL)distanceInMiles
{
    _distanceInMiles = distanceInMiles;
    [self updateDistanceLabel];
}

-(void)setDirection:(CLLocationDirection)direction
{
    _direction = direction;
    self.compassView.transform = CGAffineTransformMakeRotation(direction);
}

-(void)setDistance:(CLLocationDistance)distance
{
    _distance = distance;
    [self updateDistanceLabel];
}

-(void)updateDistanceLabel
{
    NSString *unit = @"KM";
    CLLocationDistance distance = self.distance;
    if (self.distanceInMiles) {
        unit = @"Mi";
        distance = distance/1.609344; //0.62137119;
    }
    self.distanceLabel.text = [NSString stringWithFormat:@"%.2f\n%@",distance,unit];
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.distanceInMiles = YES;
        [self setup];
        [self updateDistanceLabel];

    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.distanceInMiles = YES;
        [self setup];
        [self updateDistanceLabel];
    }
    return self;
}


-(void)setup
{
    self.compassView = [[UIView alloc] initWithFrame:self.bounds];
    self.compassView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.compassView];

    self.arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needle"]];
    self.arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.arrowImageView.backgroundColor = [UIColor clearColor];
    self.arrowImageView.frame = self.compassView.bounds;
    [self.compassView addSubview:self.arrowImageView];

    self.distanceLabel = [[UILabel alloc] initWithFrame:CGRectInset(self.bounds, 4, 4)];
    self.distanceLabel.numberOfLines = 0;
    self.distanceLabel.font = [UIFont systemFontOfSize:9];
    self.distanceLabel.adjustsFontSizeToFitWidth = YES;
    self.distanceLabel.textAlignment = NSTextAlignmentCenter;
    self.distanceLabel.backgroundColor = [UIColor whiteColor];
    self.distanceLabel.layer.cornerRadius = self.distanceLabel.frame.size.width/2;
    self.distanceLabel.layer.masksToBounds = YES;
    self.distanceLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.distanceLabel.layer.borderWidth = 0.5;
    [self addSubview:self.distanceLabel];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    
    self.compassView.transform = CGAffineTransformMakeRotation(self.direction);
}

@end
