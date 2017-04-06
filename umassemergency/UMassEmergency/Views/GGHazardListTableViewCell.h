//
//  GGHazardListTableViewCell.h
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

#import <UIKit/UIKit.h>
#import "GGHazard.h"

@interface GGHazardListTableViewCell : UITableViewCell

@property (nonatomic, strong) GGHazard *hazard;

@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *summaryLabel;
@property (nonatomic, strong) IBOutlet UILabel *distanceLabel;
@property (nonatomic, strong) IBOutlet UIView *compassView;
@property (nonatomic, strong) IBOutlet UILabel *expirationDateLabel;
@property (nonatomic, strong) IBOutlet UILabel *effectiveDateLabel;
@property (nonatomic, strong) IBOutlet UIImageView *iconView;
@property (nonatomic, strong) IBOutlet UIView *activeIcon;

-(void)updateCompass;

@end
