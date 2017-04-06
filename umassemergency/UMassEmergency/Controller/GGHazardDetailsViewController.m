//
//  GGHazardDetailsViewController.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 13.05.15.
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

#import "GGHazardDetailsViewController.h"
#import "GGHazardView.h"
#import "GGHazardAnnotationView.h"
#import "GGHazardPolygonOverlay.h"
#import "GGHazardCircleOverlay.h"
#import "GGDistanceCompassView.h"

#define trackingScreenName @"Hazard Detail Screen"
#define defaultZoomAltitude 3000

typedef enum : NSUInteger {
    HazardDetailTableSectionName = 0,
    HazardDetailTableSectionSummary = 1,
    HazardDetailTableSectionDescription = 2,
    HazardDetailTableSectionDates = 3,
} HazardDetailTableSection;

@interface GGHazardDetailsViewController ()

@property (nonatomic, strong) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) GGHazardView *hazardView;
@property (nonatomic, strong) NSArray *overlays;
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, strong) GGApp *app;
@property (nonatomic, strong) GGDistanceCompassView *distanceCompassView;

@end

@implementation GGHazardDetailsViewController

-(IBAction)dismissButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hazardDetailDidCancel:)]) {
        [self.delegate hazardDetailDidCancel:self];
    }
}

#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 4;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == HazardDetailTableSectionName) {
        return 1;
    }else if (section == HazardDetailTableSectionSummary) {
        return 1;
    }else if (section == HazardDetailTableSectionDescription) {
        if (self.hazard.longDescription) {
            return 1;
        }
        return 0;
    }else if (section == HazardDetailTableSectionDates) {
        if (self.hazard.effectiveDate && self.hazard.expirationDate) {
            return 2;
        }else if (self.hazard.effectiveDate || self.hazard.expirationDate) {
            return 1;
        }
        return 0;
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == HazardDetailTableSectionName) {
        return @"";
    }else if (section == HazardDetailTableSectionSummary) {
        return @"";
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (indexPath.section == HazardDetailTableSectionName) {

        cell.textLabel.text = self.hazard.headline;
        cell.textLabel.font = [UIFont systemFontOfSize:12];
        
    }else if (indexPath.section == HazardDetailTableSectionSummary) {

        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.hazard.summary;
        cell.textLabel.font = [UIFont systemFontOfSize:12];

    }else if (indexPath.section == HazardDetailTableSectionDescription) {
        
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.text = self.hazard.longDescription;
        cell.textLabel.font = [UIFont systemFontOfSize:12];

    }else if (indexPath.section == HazardDetailTableSectionDates) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"time"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"time"];
        }

//        cell.textLabel.font = [UIFont systemFontOfSize:10];
        cell.textLabel.font = [UIFont systemFontOfSize:11];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:11];

        NSString *titleText = @"";
        NSString *detailText = @"";
        
        if (self.hazard.effectiveDate && self.hazard.expirationDate) {
            
            if (indexPath.row == 0) {
                titleText = @"Begin";
                detailText = [NSDateFormatter localizedStringFromDate:self.hazard.effectiveDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
            }else if (indexPath.row == 1) {
                titleText = @"End";
                detailText = [NSDateFormatter localizedStringFromDate:self.hazard.expirationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
            }
        }else{
            if (self.hazard.effectiveDate) {
                titleText = @"Begin";
                detailText = [NSDateFormatter localizedStringFromDate:self.hazard.effectiveDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
            }else if (self.hazard.expirationDate) {
                titleText = @"End";
                detailText = [NSDateFormatter localizedStringFromDate:self.hazard.expirationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterShortStyle];
            }
        }

        cell.textLabel.text = titleText;
        cell.detailTextLabel.text = detailText;

        return cell;
    }
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == HazardDetailTableSectionName) {
        
    }else if (indexPath.section == HazardDetailTableSectionSummary) {
        return UITableViewAutomaticDimension;
    }else if (indexPath.section == HazardDetailTableSectionDescription) {
        return UITableViewAutomaticDimension;
    }
    return UITableViewAutomaticDimension;
}

-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewAutomaticDimension;
}

#pragma mark -

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GGHazardAnnotation class]]) {
        
        GGHazardAnnotation *hazardAnnotation = (GGHazardAnnotation *)annotation;
        GGHazard *hazard = hazardAnnotation.hazard;
        
        GGHazardAnnotationView *view = (GGHazardAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"hazard"];
        if (!view) {
            view = [[GGHazardAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"hazard"];
        }else{
            view.annotation = annotation;
        }
        
        view.image = hazard.type.annotationIcon;
        
        return view;
    }
    
    return nil;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    if ([overlay isKindOfClass:[GGHazardPolygonOverlay class]]) {
        
        CGFloat alpha = 0.6;
        
        GGHazardPolygonOverlay *polygon = (GGHazardPolygonOverlay *)overlay;
        GGHazard *hazard = polygon.hazardPolygon.hazard;
        GGWarningType *type = hazard.type;
        MKPolygonRenderer *renderer = [[MKPolygonRenderer alloc] initWithPolygon:polygon];
        renderer.strokeColor = [[UIColor grayColor] colorWithAlphaComponent:alpha];
        renderer.fillColor = [type.color colorWithAlphaComponent:alpha];
        renderer.lineWidth = 2;
        return renderer;
        
    }else if ([overlay isKindOfClass:[GGHazardCircleOverlay class]]) {
        
        CGFloat alpha = 0.6;
        
        GGHazardCircleOverlay *circle = (GGHazardCircleOverlay *)overlay;
        GGHazard *hazard = circle.hazardPolygon.hazard;
        GGWarningType *type = hazard.type;
        MKCircleRenderer *renderer = [[MKCircleRenderer alloc] initWithCircle:circle];
        renderer.fillColor = [type.color colorWithAlphaComponent:alpha];
        renderer.strokeColor = [type.color colorWithAlphaComponent:alpha];
        return renderer;
        
    }
    
    return nil;
}


-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    XLog(@"Altitude: %f",self.mapView.camera.altitude);
}

#pragma mark -

-(void)setHazard:(GGHazard *)hazard
{
    _hazard = hazard;
    if (hazard) {
        [self updateHazard:hazard];
    }
    [self.table reloadData];
}

-(void)updateHazard:(GGHazard *)hazard
{
    self.title = hazard.headline;

    [self.mapView removeAnnotations:self.annotations];
    [self.mapView removeOverlays:self.overlays];

    self.hazardView = [[GGHazardView alloc] initWithHazard:hazard];
    self.overlays = self.hazardView.overlays;
    self.annotations = self.hazardView.annotations;

    [self.mapView addOverlays:self.overlays level:MKOverlayLevelAboveRoads];
//    [self.mapView addAnnotations:self.annotations];
    [self.mapView addAnnotation:self.hazardView.centerAnnotation];
    
    // show all annotations or center annotation
    if (self.annotations.count > 0) {
        [self.mapView showAnnotations:self.annotations animated:NO];
    }else{
        [self.mapView showAnnotations:@[self.hazardView.centerAnnotation] animated:NO];
    }

    // zoom out
    if (self.mapView.camera.altitude < defaultZoomAltitude) {
        MKMapCamera *camera = self.mapView.camera;
        camera.altitude = defaultZoomAltitude;
        [self.mapView setCamera:camera animated:NO];
    }
    [self.mapView removeAnnotations:self.annotations];

    [self updateDistanceCompassView];
}

-(void)app:(GGApp *)app didUpdateLocations:(NSArray *)locations
{
    [self updateDistanceCompassView];
}

-(void)app:(GGApp *)app didUpdateHeading:(CLHeading *)heading
{
    [self updateDistanceCompassView];
}

-(void)updateDistanceCompassView
{
//    self.distanceCompassView.distance = self.hazard.currentDistance/1000;
    self.distanceCompassView.distance = self.hazard.currentDistanceToClosestPolygonPoint/1000;
    self.distanceCompassView.direction = self.hazard.currentDirection;
}



#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [GGConstants sendTrackingScreenName:trackingScreenName];

    [self.app addLocationDelegate:self];
    [self updateDistanceCompassView];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.annotations = [NSArray array];
    self.overlays = [NSArray array];
    
    self.mapView = [[MKMapView alloc] init];
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    self.mapView.frame = CGRectMake(0, 0, self.table.frame.size.width, self.view.bounds.size.height/2);
    self.table.tableHeaderView = self.mapView;
        
    if (self.hazard) {
        [self updateHazard:self.hazard];
    }

    self.app = [GGApp instance];
    self.distanceCompassView = [[GGDistanceCompassView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    self.distanceCompassView.center = self.view.center;
    
    UIBarButtonItem *distanceCompassBarButton = [[UIBarButtonItem alloc] initWithCustomView:self.distanceCompassView];
    [self.navigationItem setRightBarButtonItem:distanceCompassBarButton];

    if ([self isModal]) {
        if (self.navigationController.viewControllers.count == 1) {
            UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissButtonPressed:)];
            [self.navigationItem setLeftBarButtonItem:dismissButton];
        }
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.app removeLocationDelegate:self];
}

#pragma mark -

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.mapView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2);
    self.table.tableHeaderView = self.mapView;
}


@end
