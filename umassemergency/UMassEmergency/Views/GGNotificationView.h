//
//  GGNotificationView.h
//  BusTrack
//
//  Created by Görkem Güclü on 05.03.15.
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
#import "GGNotification.h"

@protocol GGNotificationViewDelegate;
@interface GGNotificationView : UIView

@property (nonatomic, weak) id<GGNotificationViewDelegate> delegate;

@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UIButton *textButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) GGNotification *notification;

- (instancetype)initWithNotification:(GGNotification *)notification;

@end

@protocol GGNotificationViewDelegate <NSObject>

-(void)notificationDidClose:(GGNotificationView *)view;
-(void)notificationDidGetPressed:(GGNotificationView *)view;

@end
