//
//  GGUserLocationViewController.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 17.04.15.
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

#import "GGUserLocationViewController.h"
#import "GGAnnotation.h"

@interface GGUserLocationViewController ()

@property (nonatomic, strong) NSArray *locationAnnotations;

@end

@implementation GGUserLocationViewController



#pragma mark -

-(void)updateMap
{
    [self.mapView removeAnnotations:self.locationAnnotations];
    if (self.user) {
        NSMutableArray *annotations = [[NSMutableArray alloc] init];
        NSUInteger counter = 0;
        for (CLLocation *location in self.user.locations) {
            NSString *title = [NSString stringWithFormat:@"Location %li",(long)counter];
            
            GGAnnotation *anno = [[GGAnnotation alloc] initWithTitle:title andCoordinate:location.coordinate];
            [annotations addObject:anno];
            
            counter++;
        }
        self.locationAnnotations = annotations;
    }
    [self.mapView addAnnotations:self.locationAnnotations];
}


#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.locationAnnotations.count == 1) {
        [self.mapView showAnnotations:self.locationAnnotations animated:NO];
        MKMapCamera *camera = self.mapView.camera;
        camera.altitude = 7000;
        [self.mapView setCamera:camera animated:YES];
    }else{
        [self.mapView showAnnotations:self.locationAnnotations animated:YES];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.locationAnnotations = [NSArray array];
    
    if (self.user) {
        self.title = self.user.name;
        
    }
 
    [self updateMap];
}




@end
