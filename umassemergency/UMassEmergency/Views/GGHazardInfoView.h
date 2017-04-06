//
//  GGHazardInfoView.h
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

#import <UIKit/UIKit.h>
#import "GGHazard.h"
#import "GGDistanceCompassView.h"

@protocol GGHazardInfoViewDelegate;
@interface GGHazardInfoView : UIView

@property (nonatomic,strong) GGHazard *hazard;

@property (nonatomic, assign) id<GGHazardInfoViewDelegate> delegate;
@property (nonatomic, weak) IBOutlet UILabel *titleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UITextView *textView;
@property (nonatomic, weak) IBOutlet UILabel *statusLabel;


@end

@protocol GGHazardInfoViewDelegate <NSObject>

-(void)infoViewPressed:(GGHazardInfoView *)view;
-(void)infoViewInfoButtonPressed:(GGHazardInfoView *)view;
-(void)infoViewCloseButtonPressed:(GGHazardInfoView *)view;

@end
