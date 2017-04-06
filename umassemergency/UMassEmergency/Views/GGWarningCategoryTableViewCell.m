//
//  GGWarningCategoryTableViewCell.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 13.12.15.
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

#import "GGWarningCategoryTableViewCell.h"

@implementation GGWarningCategoryTableViewCell


-(void)setWarningCategory:(GGWarningCategory *)warningCategory
{
    _warningCategory = warningCategory;
    if (warningCategory) {
        self.textLabel.text = warningCategory.name;
        self.imageView.image = warningCategory.iconSmall;
        if (warningCategory.color) {
            self.colorCircleView.backgroundColor = warningCategory.color;
            self.colorCircleView.hidden = NO;
        }else{
            self.colorCircleView.hidden = YES;
        }
    }else{
        self.colorCircleView.hidden = YES;
    }
}


- (void)awakeFromNib {
    // Initialization code
    
    [self setup];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setup];
    }
    return self;
}


-(void)setup
{
    self.colorCircleView = [[UIView alloc] initWithFrame:CGRectMake(self.contentView.frame.size.width-40, 10, 20, 20)];
    self.colorCircleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    self.colorCircleView.layer.cornerRadius = 10;
    self.colorCircleView.hidden = YES;
    [self.contentView addSubview:self.colorCircleView];
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
