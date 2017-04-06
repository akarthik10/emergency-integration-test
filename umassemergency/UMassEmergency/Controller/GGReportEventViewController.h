//
//  GGReportEventViewController.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 10.03.15.
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
#import "GGReport.h"

@protocol GGReportEventViewControllerDelegate;
@interface GGReportEventViewController : UIViewController

@property (assign, nonatomic) id<GGReportEventViewControllerDelegate> delegate;
@property (strong, nonatomic) GGReport *report;

-(void)setupCameraSession:(BOOL)forceRestart;

@end

@protocol GGReportEventViewControllerDelegate <NSObject>

-(void)reportEventViewControllerDidClose:(GGReportEventViewController *)controller;

@end
