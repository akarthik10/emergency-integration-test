//
//  ViewController.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 01.03.15.
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
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GGAnnotation.h"
#import "GGApp.h"
#import "GGHazardDetailsViewController.h"
#import "GGUserCredentialsViewController.h"
#import "GGTimeframe.h"
#import "GGCreateNotificationViewController.h"
#import "GGHazardInfoView.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : UIViewController <MKMapViewDelegate,GGAppLocationDelegate, GGUserCredentialsDelegate, UIGestureRecognizerDelegate, GGAppTimerDelegate, GGCreateNotificationDelegate, GGAppDataDelegate, GGHazardInfoViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *mapView;

@property (nonatomic, strong) GGApp *app;

@property (nonatomic, strong) NSMutableDictionary *hazardAnnotations;

@property (nonatomic, strong) NSMutableArray *overlays;
@property (nonatomic, strong) NSMutableArray *annotations;

@property (nonatomic, strong) NSArray *timeframes;
@property (nonatomic, strong) GGTimeframe *selectedTimeframe;


-(void)showHazardOnMap:(GGHazard *)hazard;
-(void)showHazardOnMapWithHazardID:(NSString *)hazardID;
-(void)showHazardDetailView:(GGHazard *)hazard;

-(void)showHazardOnMapWithHazardID:(NSString *)hazardID animated:(BOOL)animated withCompletion:(void (^)(void))completionBlock;
-(void)showHazardOnMapWithHazard:(GGHazard *)hazard animated:(BOOL)animated withCompletion:(void (^)(void))completionBlock;

-(void)updateMap;

@end

