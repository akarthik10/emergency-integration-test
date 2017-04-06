//
//  GGMapOverlayButton.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 20.12.15.
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

#import "GGMapOverlayButton.h"

@interface GGMapOverlayButton ()

@end

@implementation GGMapOverlayButton


#pragma mark -

-(void)setup
{
    self.clipsToBounds = YES;
        
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 0.2;
}


+(instancetype)buttonWithType:(UIButtonType)buttonType
{
    GGMapOverlayButton *button = (GGMapOverlayButton *)[super buttonWithType:buttonType];
    [button setup];
    return button;
}


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


-(void)tintColorDidChange
{
    [super tintColorDidChange];
    
    self.layer.borderColor = self.tintColor.CGColor;
}

@end
