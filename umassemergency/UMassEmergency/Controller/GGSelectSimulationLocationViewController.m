//
//  GGSelectSimulationLocationViewController.m
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

#import "GGSelectSimulationLocationViewController.h"
#import "GGAnnotation.h"

#define trackingScreenName @"Select Simulation Location"

typedef enum : NSUInteger {
    SelectSimulationLocationTableSectionCurrentSelected = 0,
    SelectSimulationLocationTableSectionPrepared = 1,
    SelectSimulationLocationTableSectionCustom = 2,
} SelectSimulationLocationTableSection;

@interface GGSelectSimulationLocationViewController ()

@property (nonatomic, weak) IBOutlet UITableView *table;

@end

@implementation GGSelectSimulationLocationViewController


#pragma mark - TableViewDelegate

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SelectSimulationLocationTableSectionCurrentSelected) {
        return 1;
    }else if (section == SelectSimulationLocationTableSectionCustom) {
        return 1;
    }else if (section == SelectSimulationLocationTableSectionPrepared) {
        return self.app.dataManager.simulationLocations.count;
    }
    return 0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == SelectSimulationLocationTableSectionCurrentSelected) {
        return @"Current selected location";
    }else if (section == SelectSimulationLocationTableSectionPrepared) {
        return @"Select Location";
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.detailTextLabel.text = nil;
    
    if (indexPath.section == SelectSimulationLocationTableSectionCurrentSelected) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {

            GGLocation *location = [GGConstants simulatedLocation];
            if (location) {
                cell.textLabel.text = location.name;
                cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
            }else{
                cell.textLabel.text = @"No Simulation Location Selected";
            }
        }
        
    }else if (indexPath.section == SelectSimulationLocationTableSectionCustom) {

        if (indexPath.row == 0) {
            cell.textLabel.text = @"Select custom location";
            cell.detailTextLabel.text = nil;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        }

    }else if (indexPath.section == SelectSimulationLocationTableSectionPrepared) {

        GGLocation *location = [self.app.dataManager.simulationLocations objectAtIndex:indexPath.row];
        cell.textLabel.text = location.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f",location.coordinate.latitude,location.coordinate.longitude];
        
        GGLocation *simulatedLocation = [GGConstants simulatedLocation];
        if (simulatedLocation != nil && [location isEqual:simulatedLocation]) {
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        }

    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SelectSimulationLocationTableSectionCustom) {
        
        GGSelectLocationViewController *select = [[GGSelectLocationViewController alloc] initWithNibName:@"GGSelectLocationViewController" bundle:nil];
        GGLocation *location = [GGConstants simulatedLocation];
        if (CLLocationCoordinate2DIsValid(location.coordinate)) {
            select.selectedLocation = location;
        }
        select.delegate = self;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:select];
        [self presentViewController:navi animated:YES completion:nil];

        
    }else if(indexPath.section == SelectSimulationLocationTableSectionPrepared) {
        
        GGLocation *location = [self.app.dataManager.simulationLocations objectAtIndex:indexPath.row];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(simulationLocation:didSelectLocation:)]) {
            [self.delegate simulationLocation:self didSelectLocation:location];
        }

        [self updateMap];

    }else if(indexPath.section == SelectSimulationLocationTableSectionCurrentSelected) {
        return;
    }
    
    [tableView reloadSections:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)] withRowAnimation:UITableViewRowAnimationFade];
}


#pragma mark -

-(void)selectLocation:(GGSelectLocationViewController *)controller didSelectLocation:(CLLocation *)location
{
    if ([self isModal]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    GGLocation *ggLocation = [[GGLocation alloc] initWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
    ggLocation.name = @"Custom Simulation Location";
    [GGConstants setSimulatedLocation:ggLocation];
    [self.app updateLocationInBackground:ggLocation withCompletion:nil];
    
    [self.table reloadData];

    [self updateMap];
}

-(void)selectLocationDidCancel:(GGSelectLocationViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Map

-(void)updateMap
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    
    GGLocation *location = [GGConstants simulatedLocation];
    if (location) {
        NSString *title = location.name;
        if (!title) {
            title = @"Simulated location";
        }
        GGAnnotation *anno = [[GGAnnotation alloc] initWithTitle:title andCoordinate:location.coordinate];
        [self.mapView addAnnotation:anno];
    }
    
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
    MKMapCamera *camera = self.mapView.camera;
    camera.altitude = 7000;
    [self.mapView setCamera:camera animated:YES];
}



#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [GGConstants sendTrackingScreenName:trackingScreenName];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.table deselectRowAtIndexPath:[self.table indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.app = [GGApp instance];
    
    self.table.delegate = self;
    self.table.dataSource = self;
    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 200)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.delegate = self;
    
    self.table.tableHeaderView = self.mapView;
    
    [self updateMap];
}

- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

@end
