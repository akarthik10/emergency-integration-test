//
//  GGSelectLocationViewController.h
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
#import <MapKit/MapKit.h>
#import "GGApp.h"

/*
 
 Select Location
 Users can search for a city or area or use the map to define an area
 
 */

@protocol GGSelectLocationDelegate;
@interface GGSelectLocationViewController : UIViewController <MKMapViewDelegate, UISearchBarDelegate, UISearchResultsUpdating, UISearchControllerDelegate, UISearchDisplayDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UILabel *toolbarLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *trashButton;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) id<GGSelectLocationDelegate> delegate;
@property (nonatomic, strong) CLLocation *selectedLocation;
@property (nonatomic, strong) CLLocation *previousLocation;

@end

@protocol GGSelectLocationDelegate <NSObject>

-(void)selectLocationDidCancel:(GGSelectLocationViewController *)controller;
-(void)selectLocation:(GGSelectLocationViewController *)controller didSelectLocation:(CLLocation *)location;
@optional
-(void)selectLocation:(GGSelectLocationViewController *)controller didSelectDeleteLocation:(CLLocation *)location;


@end
