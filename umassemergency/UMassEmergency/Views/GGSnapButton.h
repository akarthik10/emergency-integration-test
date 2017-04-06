//
//  GGSnapButton.h
//  UMassEmergency
//
//  Created by Görkem Güclü on 23.08.16.
//  Copyright © 2016 University of Massachusetts.
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

@protocol GGSnapButtonDelegate;
@interface GGSnapButton : UIButton

@property (nonatomic, assign) id<GGSnapButtonDelegate> delegate;
@property (nonatomic, strong) NSString *title;

-(void)showPhotoButton;
-(void)showVideoButton;
-(void)showRecordingButton;

@end

@protocol GGSnapButtonDelegate <NSObject>

-(void)snapButtonDidPress:(GGSnapButton *)button;
@optional
-(void)snapButtonDidBeginLongPress:(GGSnapButton *)button;
-(void)snapButtonDidEndLongPress:(GGSnapButton *)button;

@end
