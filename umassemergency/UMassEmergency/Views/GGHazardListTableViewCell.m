//
//  GGHazardListTableViewCell.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 08.04.15.
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

#import "GGHazardListTableViewCell.h"
#import <CoreGraphics/CoreGraphics.h>

@interface GGHazardListTableViewCell ()

@end

@implementation GGHazardListTableViewCell

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupLayout];
    }
    return self;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupLayout];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];

    [self setupLayout];
}

-(void)setupLayout
{
    self.titleLabel.numberOfLines = 0;
    
    self.distanceLabel.backgroundColor = [UIColor whiteColor];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"needle"]];
    arrowImageView.contentMode = UIViewContentModeCenter;
    arrowImageView.frame = self.compassView.bounds;
    [self.compassView addSubview:arrowImageView];
    self.compassView.hidden = YES;
}


-(void)updateCompass
{
    self.compassView.transform = CGAffineTransformMakeRotation(self.hazard.currentDirection);
}


-(void)setHazard:(GGHazard *)hazard
{
    _hazard = hazard;
    if (hazard) {
        if (hazard.headline) {
            self.titleLabel.text = [hazard.headline capitalizedStringWithLocale:[NSLocale systemLocale]];
        }else{
            self.titleLabel.text = @"Event name not available";
        }

        self.titleLabel.numberOfLines = 0;
        [self.titleLabel sizeToFit];
        
        if (hazard.summary) {
            self.summaryLabel.text = hazard.summary;
        }else{
            self.summaryLabel.text = @"Description not available";
        }
        
        
//        CLLocationDistance distanceInKM = hazard.currentDistance/1000;
        CLLocationDistance distanceInKM = hazard.currentDistanceToClosestPolygonPoint/1000;
        CLLocationDistance distanceInMiles = distanceInKM/1.609344; //0.62137119;
        self.distanceLabel.text = [NSString stringWithFormat:@"%.2f\nMi",distanceInMiles];
        self.distanceLabel.numberOfLines = 0;
        self.distanceLabel.backgroundColor = [UIColor whiteColor];
        self.distanceLabel.layer.cornerRadius = self.distanceLabel.frame.size.width/2;
        self.distanceLabel.layer.masksToBounds = YES;
        self.distanceLabel.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.distanceLabel.layer.borderWidth = 0.5;
        
        self.compassView.transform = CGAffineTransformMakeRotation(hazard.currentDirection);
        self.compassView.hidden = NO;
        
        NSString *effectiveDateString = [NSDate stringForDisplayFromDate:hazard.effectiveDate prefixed:YES alwaysDisplayTime:YES];
        NSString *expirationDateString = [NSDate stringForDisplayFromDate:hazard.expirationDate prefixed:YES alwaysDisplayTime:YES];
        
        if ([GGConstants inDeveloperMode]) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setLocale:[NSLocale currentLocale]];
            [dateFormatter setDateFormat:@"MMMM d, Y 'at' hh:mm:ss a v"];
            
            effectiveDateString = [dateFormatter stringFromDate:hazard.effectiveDate];
            expirationDateString = [dateFormatter stringFromDate:hazard.expirationDate];
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Begins: " attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:effectiveDateString attributes:@{NSForegroundColorAttributeName:[UIColor darkGreenColor]}]];
        self.effectiveDateLabel.attributedText = attributedString;

        attributedString = [[NSMutableAttributedString alloc] init];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:@"Ends: " attributes:@{NSForegroundColorAttributeName:[UIColor grayColor]}]];
        [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:expirationDateString attributes:@{NSForegroundColorAttributeName:[UIColor darkRedColor]}]];
        self.expirationDateLabel.attributedText = attributedString;
        
        BOOL expirationDateVisible = [hazard isExpirationDateVisible];
        self.expirationDateLabel.hidden = !expirationDateVisible;
        
        // Debug Hazard type
//        self.titleLabel.text = hazard.hazardType;
        
//        switch (hazard.type) {
//            case GGHazardTypeTornado:
//                self.iconView.image = [UIImage imageNamed:@"tornado-icon-small"];
//                break;
//            case GGHazardTypeStorm:
//                self.iconView.image = [UIImage imageNamed:@"storm-icon-small"];
//                break;
//            case GGHazardTypeFlooding:
//                self.iconView.image = [UIImage imageNamed:@"flood-icon-small"];
//                break;
//            default:
//                self.iconView.image = [UIImage imageNamed:@"warning-icon-small"];
//                break;
//        }
        
        self.iconView.image = hazard.iconSmall;
        
        self.iconView.backgroundColor = [UIColor superLightGrayColor];
//        self.iconView.backgroundColor = hazard.category.color;
//        self.iconView.layer.borderColor = hazard.category.color.CGColor;
        self.iconView.backgroundColor = hazard.type.color;
        self.iconView.layer.borderColor = hazard.type.color.CGColor;
//        self.iconView.layer.borderColor = [UIColor superLightGrayColor].CGColor;
        self.iconView.layer.borderWidth = 2;
        self.iconView.layer.cornerRadius = self.iconView.frame.size.width/2;

        
        switch (hazard.isActive) {
            case GGHazardActiveNow:
                self.activeIcon.backgroundColor = [UIColor statusActiveColor];
                break;
            case GGHazardActivePassed:
                self.activeIcon.backgroundColor = [UIColor statusExpiredColor];
                break;
            default:
                self.activeIcon.backgroundColor = [UIColor clearColor];
                break;
        }
        self.activeIcon.alpha = 0.5;
    }else{
        self.compassView.hidden = YES;
    }
}



@end
