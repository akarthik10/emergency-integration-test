//
//  GGAlertListSectionHeaderView.h
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

#import <UIKit/UIKit.h>

@protocol GGAlertListSectionHeaderDelegate;
@interface GGAlertListSectionHeaderView : UIView

@property (nonatomic, assign) id<GGAlertListSectionHeaderDelegate> delegate;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *visibiltyButtonTitle;
@property (nonatomic, readwrite) NSInteger section;

@end

@protocol GGAlertListSectionHeaderDelegate <NSObject>

-(void)alertListSectionHeaderDidPressVisibilityButton:(GGAlertListSectionHeaderView *)view;

@end
