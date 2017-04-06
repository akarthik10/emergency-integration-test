//
//  GGSelectSimulationLocationViewController.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 03.09.15.
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
#import "GGApp.h"
#import "GGSelectLocationViewController.h"

@protocol GGSelectSimulationLocationDelegate;
@interface GGSelectSimulationLocationViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, GGSelectLocationDelegate, MKMapViewDelegate>

@property (nonatomic, strong) GGApp *app;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, assign) id<GGSelectSimulationLocationDelegate> delegate;

@end

@protocol GGSelectSimulationLocationDelegate <NSObject>

-(void)simulationLocation:(GGSelectSimulationLocationViewController *)controller didSelectLocation:(GGLocation *)location;

@end
