//
//  ViewController.m
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

#import "ViewController.h"
#import "GGHazardListTableViewCell.h"
#import "GGHazardMapOverlay.h"
#import "GGHazardMapOverlayView.h"
#import "GGHazardPolygonOverlay.h"
#import "GGHazardCircleOverlay.h"
#import "GGHazardView.h"
#import "GGHazardAnnotationView.h"
#import "GGUserSavedAnnotation.h"
#import "GGUserSavedLocationAnnotationView.h"
#import "GGCarouselTimeframeView.h"
#import "GGSelectedTimeframeView.h"
#import "GGMapOverlayButton.h"
#import "GGAlertListSectionHeaderView.h"
#import "GGFilterSettingsView.h"
#import "GGWarningTypeGroup.h"
#import "GGHazardListViewController.h"
#import "GGHazardDetailsViewController.h"
#import "GGLoginViewController.h"
#import "GGAboutViewController.h"
#import "GGSelectLocationViewController.h"
#import "GGAttributesSettingsViewController.h"
#import "GGReportEventViewController.h"
#import "AppDelegate.h"
#import "GGGNSManager.h"

#define trackingScreenName @"Map Screen"

#define defaultZoomAltitude 3000
#define defaultArcValue 0.5
#define defaultRadiusValue 0.4
#define defaultSpacingValue 1.8

typedef enum : NSUInteger {
    GGListSectionActive = 0,
    GGListSectionExpired = 1
} GGListSection;

@interface ViewController () <GGSelectLocationDelegate, GGAppInternetConnectionDelegate, GGReportEventViewControllerDelegate, GGLoginDelegate, GGHazardListDelegate, GGHazardDetailsDelegate>

@property (nonatomic, strong) IBOutlet UIBarButtonItem *listButton;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, readwrite) CLLocationDistance mapAltitude;

@property (nonatomic, strong) NSArray *hazardViews;
@property (nonatomic, strong) NSArray *filteredHazardViews;

@property (nonatomic, strong) NSArray *activeHazardViews;
@property (nonatomic, strong) NSArray *expiredHazardViews;

@property (nonatomic, strong) NSArray *userLocationAnnotations;
@property (nonatomic, strong) NSArray *temporaryAnnotations;
@property (nonatomic, strong) NSArray *temporaryOverlays;
@property (nonatomic, strong) GGHazardView *temporarySelectedHazardView;
@property (nonatomic, strong) GGHazard *temporarySelectedHazard;
@property (nonatomic, strong) GGHazardAnnotation *selectedHazardAnnotation;

@property (nonatomic, strong) GGAnnotation *simulatedLocationAnnotation;
@property (nonatomic, strong) GGUserSavedAnnotation *selectedUserLocationAnnotation;

@property (nonatomic, strong) GGReportEventViewController *reportController;
@property (nonatomic, strong) GGHazardListViewController *listVC;

@property (nonatomic, strong) IBOutlet GGHazardInfoView *hazardInfoView;

@property (nonatomic, strong) IBOutlet GGMapOverlayButton *locationButton;
@property (nonatomic, strong) IBOutlet GGMapOverlayButton *reportButton;
@property (nonatomic, strong) IBOutlet GGMapOverlayButton *attributesButton;

@property (nonatomic, weak) IBOutlet UIToolbar *internetConnectionNotAvailableToolbar;

@end

@implementation ViewController


#pragma mark - Notifications

-(void)updateHazardAnnotationsOnMapNotificationReceived:(NSNotification *)notification
{
    [self updateHazardAnnotations];
    [self updateMap];
}


#pragma mark - IBAction


-(IBAction)refreshControlTriggered:(id)sender
{
    [self.app updateAlerts:YES];
}

-(IBAction)locationButtonPressed:(id)sender
{
    if (![self.app isLocationServicesEnabled]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Services off" message:@"Please grant access to location services. This allows the app to send you notifications when you change locations and get closer to dangerous hazard areas. Moreover, your location can be displayed on the map." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction* settingsAction = [UIAlertAction actionWithTitle:@"Settings" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
        }];
        [alert addAction:cancelAction];
        [alert addAction:settingsAction];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    switch (self.mapView.userTrackingMode) {
        case MKUserTrackingModeNone:
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
            break;
        case MKUserTrackingModeFollow:
            [self.mapView setUserTrackingMode:MKUserTrackingModeFollowWithHeading animated:YES];
            break;
        case MKUserTrackingModeFollowWithHeading:
            [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:YES];
            break;
        default:
            break;
    }
}



-(IBAction)listButtonPressed:(id)sender
{
    [self showList];
}

-(IBAction)reportWarningButtonPressed:(id)sender
{
    [self showReportController];
}

-(IBAction)settingsButtonPressed:(id)sender
{
    GGAttributesSettingsViewController *attributesVC = [[GGAttributesSettingsViewController alloc] initWithNibName:@"GGAttributesSettingsViewController" bundle:nil];
    UINavigationController *attributesNavi = [[UINavigationController alloc] initWithRootViewController:attributesVC];
    [self presentViewController:attributesNavi animated:YES completion:nil];
}

-(IBAction)aboutButtonPressed:(id)sender
{
    GGAboutViewController *aboutVC = [[GGAboutViewController alloc] initWithNibName:@"GGAboutViewController" bundle:nil];
    UINavigationController *aboutNavi = [[UINavigationController alloc] initWithRootViewController:aboutVC];
    [self presentViewController:aboutNavi animated:YES completion:nil];
}

#pragma mark - Gesture

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)userDidDragMap:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        self.mapAltitude = self.mapView.camera.altitude;
    }
}


#pragma mark - List

-(void)hazardList:(GGHazardListViewController *)controller didSelectHazard:(GGHazard *)hazard
{
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
    
    [self hideListAnimated:YES withCompletion:^{
        [self showHazardOnMapWithHazard:hazard animated:YES withCompletion:nil];
    }];
}

-(void)hazardList:(GGHazardListViewController *)controller didSelectHazardDetail:(GGHazard *)hazard
{
    [self showHazardDetailView:hazard onController:controller];
}

-(void)hazardListDidRefreshTable:(GGHazardListViewController *)controller
{
    [self reloadData];
}

-(void)hazardListNeedsDateUpdate:(GGHazardListViewController *)controller
{
    [self reloadData];
}

-(void)hazardListDidCancel:(GGHazardListViewController *)controller
{
    [self hideListAnimated:YES withCompletion:nil];
}


#pragma mark - Popover

-(void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController
{
    [self hideListAnimated:YES withCompletion:nil];
}


#pragma mark - Timeframe

-(void)setSelectedTimeframe:(GGTimeframe *)selectedTimeframe
{
    if (_selectedTimeframe) {
        // only if its not the first time play sound
        if(![_selectedTimeframe isEqual:selectedTimeframe]){
            // if its not the old one
            [self playWheelClickSound];
        }
    }
    _selectedTimeframe = selectedTimeframe;
}


#pragma mark - MapView Delegate

-(void)updateLocationButton
{
    if ([self.app isLocationServicesEnabled]) {

        [self.locationButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];

        switch (self.mapView.userTrackingMode) {
            case MKUserTrackingModeFollow:
                [self.locationButton setTintColor:[UIColor umassMaroonColor]];
                break;
            case MKUserTrackingModeFollowWithHeading:
                [self.locationButton setTintColor:[UIColor purpleColor]];
                break;
            case MKUserTrackingModeNone:
                [self.locationButton setTintColor:[UIColor lightGrayColor]];
                break;
        }
        self.locationButton.layer.borderColor = [self.locationButton tintColor].CGColor;

    }else{

        [self.locationButton setImage:[UIImage imageNamed:@"location-warning"] forState:UIControlStateNormal];

        [self.locationButton setTintColor:[UIColor lightGrayColor]];
        
    }
}


-(void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    [self updateLocationButton];
}

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    XLog(@"Map Altitude: %f",self.mapView.camera.altitude);
   
}

-(void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[GGHazardAnnotation class]]) {
        GGHazardAnnotation *anno = (GGHazardAnnotation *)view.annotation;
        self.selectedHazardAnnotation = anno;
        XLog(@"self.selectedHazardAnnotation: %@",self.selectedHazardAnnotation);
        [self showHazardInfo:anno.hazard animated:YES];
    }
}

-(void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    [self hideHazardInfoAnimated:YES];
    self.selectedHazardAnnotation = nil;
    XLog(@"self.selectedHazardAnnotation: %@",self.selectedHazardAnnotation);
}


-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GGHazardAnnotation class]]) {
        
        GGHazardAnnotation *hazardAnnotation = (GGHazardAnnotation *)annotation;
        GGHazard *hazard = hazardAnnotation.hazard;

        GGHazardAnnotationView *view = (GGHazardAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"hazard"];
        if (!view) {
            view = [[GGHazardAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"hazard"];
        }

        view.annotation = annotation;
        view.image = hazard.type.annotationIcon;
        
        return view;
        
    }else if ([annotation isKindOfClass:[GGUserSavedAnnotation class]]) {
        
        GGUserSavedAnnotation *userAnno = (GGUserSavedAnnotation *)annotation;
        GGLocation *userLocation = userAnno.location;
        
        GGUserSavedLocationAnnotationView *view = (GGUserSavedLocationAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"userLocation"];
        if (!view) {
            view = [[GGUserSavedLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"userLocation"];
        }
        
        view.annotation = annotation;
        view.canShowCallout = YES;
        view.location = userLocation;
        view.pinColor = MKPinAnnotationColorPurple;
        if (![annotation isEqual:self.simulatedLocationAnnotation]) {
            view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }

        return view;
    }
    
    return nil;
}



-(void)leftCalloutAccessoryButtonPressed:(id)sender
{
    XLog(@"");
}


-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    id<MKAnnotation> annotation = view.annotation;
    if ([annotation isKindOfClass:[GGHazardAnnotation class]]) {
        
        GGHazardAnnotation *hazardAnnotation = (GGHazardAnnotation *)annotation;
        GGHazard *hazard = hazardAnnotation.hazard;
        
        [self showHazardDetailView:hazard];
        
    }else if ([annotation isKindOfClass:[GGUserSavedAnnotation class]]) {
        
        GGUserSavedAnnotation *userAnno = (GGUserSavedAnnotation *)annotation;
        GGLocation *userLocation = userAnno.location;
        
        self.selectedUserLocationAnnotation = userAnno;

        CLLocation *previousLocation = userLocation;

        GGSelectLocationViewController *selectLocationVC = [[GGSelectLocationViewController alloc] initWithNibName:@"GGSelectLocationViewController" bundle:nil];
        selectLocationVC.delegate = self;
        selectLocationVC.previousLocation = previousLocation;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:selectLocationVC];
        [self presentViewController:navi animated:YES completion:nil];
    }
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


#pragma mark - Show Hazard

-(void)showHazardOnMapWithHazardID:(NSString *)hazardID animated:(BOOL)animated withCompletion:(void (^)(void))completionBlock
{
    GGHazard *hazard = [self.app.dataManager hazardWithHazardID:hazardID];
    [self showHazardOnMapWithHazard:hazard animated:animated withCompletion:completionBlock];
}

-(void)showHazardOnMapWithHazard:(GGHazard *)hazard animated:(BOOL)animated withCompletion:(void (^)(void))completionBlock
{
    [self showHazardOnMap:hazard];
    if (completionBlock) {
        completionBlock();
    }
}


-(void)showHazardOnMapWithHazardID:(NSString *)hazardID
{
    GGHazard *hazard = [self.app.dataManager hazardWithHazardID:hazardID];
    [self showHazardOnMap:hazard];
}

-(void)showHazardOnMap:(GGHazard *)hazard
{
    if (hazard) {
        
        NSString *hazardID = hazard.hazardID;
        
        self.temporarySelectedHazard = nil;

        [self updateHazardAnnotations];
        XLog(@"HazardID: %@",hazardID);

        GGHazardAnnotation *annotation = [self.hazardAnnotations valueForKey:hazardID];
        XLog(@"annotation: %@",annotation);

        GGTimeframe *timeframe = [self bestTimeframeForHazard:hazard];
        if (timeframe) {

            for (id<MKAnnotation> anno in self.mapView.annotations) {
                if ([anno isKindOfClass:[GGHazardAnnotation class]]) {
                    GGHazardAnnotation *hazardAnno = (GGHazardAnnotation *)anno;
                    if ([hazardAnno.hazard isEqual:hazard]) {
                        annotation = hazardAnno;
                        break;
                    }
                }
            }
            
            // hazard is in timeframe
            // => not temporary

            if ([GGConstants showPolygons]) {
                GGHazardView *hazardView = [self hazardViewForHazard:hazard];

                // show complete polygon
                [self.mapView showAnnotations:hazardView.annotations animated:NO];
                [self.mapView removeAnnotations:hazardView.annotations];
                
                // zoom out
                [self zoomOutOfMapWhenAltitudeBelow:defaultZoomAltitude animated:NO];
            }

            // Hazard is in the timeframe
            self.selectedHazardAnnotation = annotation;

            [self.mapView selectAnnotation:annotation animated:YES];
            [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];

            [self showHazardInfo:hazard animated:YES];
            
        }else{
            
            // hazard is not in any timeframe
            // => temporary
            self.temporarySelectedHazard = hazard;
            self.selectedHazardAnnotation = annotation;

            [self.mapView selectAnnotation:annotation animated:YES];
            [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];

            if ([GGConstants showPolygons]) {
                GGHazardView *hazardView = [self hazardViewForHazard:hazard];
                self.temporaryOverlays = hazardView.overlays;
                [self.mapView addOverlays:self.temporaryOverlays level:MKOverlayLevelAboveRoads];
                
                // show complete polygon
                [self.mapView showAnnotations:hazardView.annotations animated:NO];
                [self.mapView removeAnnotations:hazardView.annotations];
                
                // zoom out
                [self zoomOutOfMapWhenAltitudeBelow:defaultZoomAltitude animated:NO];
            }
            
        }

    }else{
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Hazard not available anymore" message:@"Hazard has been removed" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}


-(void)showHazardDetailView:(GGHazard *)hazard
{
    GGHazardDetailsViewController *detailVC = [[GGHazardDetailsViewController alloc] initWithNibName:@"GGHazardDetailsViewController" bundle:nil];
    detailVC.hazard = hazard;
    [self.navigationController pushViewController:detailVC animated:YES];
}


-(void)showHazardDetailView:(GGHazard *)hazard onController:(UIViewController *)controller
{
    GGHazardDetailsViewController *detailVC = [[GGHazardDetailsViewController alloc] initWithNibName:@"GGHazardDetailsViewController" bundle:nil];
    detailVC.hazard = hazard;
    detailVC.delegate = self;
    if (self.traitCollection.horizontalSizeClass == UIUserInterfaceSizeClassCompact) {
        [controller.navigationController pushViewController:detailVC animated:YES];
    }else{
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:detailVC];
        navi.modalPresentationStyle = UIModalPresentationFormSheet;
        [controller presentViewController:navi animated:YES completion:nil];
    }
}

-(void)hazardDetailDidCancel:(GGHazardDetailsViewController *)controller
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}


-(void)showHazardInfo:(GGHazard *)hazard animated:(BOOL)animated
{
    if (hazard) {
        self.hazardInfoView.hazard = hazard;
        
        if (animated) {
            [UIView animateWithDuration:0.4
                                  delay:0.1
                                options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseOut
                             animations:^{
                                 self.hazardInfoView.alpha = 1;
                             }
                             completion:^(BOOL finished) {
                             }];
        }else{
            self.hazardInfoView.alpha = 1;
        }
        
    }
}

-(void)hideHazardInfoAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.4
                              delay:0.1
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseIn
                         animations:^{
                             self.hazardInfoView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                         }];
    }else{
        self.hazardInfoView.alpha = 0;
    }
}

#pragma mark - Temporary Hazard

-(void)setTemporarySelectedHazard:(GGHazard *)temporarySelectedHazard
{
    _temporarySelectedHazard = temporarySelectedHazard;
    if (temporarySelectedHazard) {
        
        if (self.temporaryAnnotations) {
            [self.mapView removeAnnotations:self.temporaryAnnotations];
        }
        if (self.temporaryOverlays) {
            [self.mapView removeOverlays:self.temporaryOverlays];
        }
        
        GGHazardAnnotation *annotation = [self.hazardAnnotations valueForKey:temporarySelectedHazard.hazardID];
        self.temporaryAnnotations = @[annotation];
        [self.mapView addAnnotations:self.temporaryAnnotations];
        
        if ([GGConstants showPolygons]) {
            GGHazardView *hazardView = [self hazardViewForHazard:self.temporarySelectedHazard];
            self.temporaryOverlays = hazardView.overlays;
            [self.mapView addOverlays:self.temporaryOverlays level:MKOverlayLevelAboveRoads];
        }

    }else{
        
        [self.mapView removeAnnotations:self.temporaryAnnotations];
        [self.mapView removeOverlays:self.temporaryOverlays];
        self.temporaryAnnotations = nil;
        self.temporaryOverlays = nil;
        
    }
}





#pragma mark - GGHazardInfoViewDelegate

-(void)infoViewPressed:(GGHazardInfoView *)view
{
    [self.mapView setCenterCoordinate:view.hazard.centerCoordinate animated:YES];
}

-(void)infoViewInfoButtonPressed:(GGHazardInfoView *)view
{
    [self showHazardDetailView:view.hazard];
}

-(void)infoViewCloseButtonPressed:(GGHazardInfoView *)view
{
    [self hideHazardInfoAnimated:YES];
    for (id<MKAnnotation> anno in [self.mapView selectedAnnotations]) {
        [self.mapView deselectAnnotation:anno animated:YES];
    }
}

#pragma mark - Zoom User Location

-(void)zoomUserLocation
{
    [self.mapView showAnnotations:[NSArray arrayWithObject:self.mapView.userLocation] animated:NO];
    [self zoomOutOfMapWhenAltitudeBelow:defaultZoomAltitude animated:YES];
}


#pragma mark - Zoom Out

-(void)zoomOutOfMapWhenAltitudeBelow:(NSInteger)altitude animated:(BOOL)animated
{
    if (self.mapView.camera.altitude < altitude) {
        MKMapCamera *camera = self.mapView.camera;
        camera.altitude = altitude;
        [self.mapView setCamera:camera animated:animated];
    }
}


#pragma mark - Alerts

-(void)appDidUpdateHazards:(GGApp *)app
{
    [self.listVC setUpdateDate:[NSDate now]];

    [self updateHazardAnnotations];
    
    [self updateMap];
    [self.listVC reloadListData];
}

-(GGTimeframe *)bestTimeframeForHazard:(GGHazard *)hazard
{
    NSArray *timeframes = [self timeframesForHazard:hazard];
    if (timeframes.count > 0) {
        NSArray *sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:YES]];
        NSArray *sortedArray = [timeframes sortedArrayUsingDescriptors:sortDescriptors];
        GGTimeframe *timeframe = sortedArray[0];
        return timeframe;
    }
    return nil;
}

-(NSArray *)timeframesForHazard:(GGHazard *)hazard
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (GGTimeframe *timeframe in self.timeframes) {
        if ([hazard isInTimeframe:timeframe]) {
            [array addObject:timeframe];
        }
    }
    return array;
}

-(NSArray *)hazards:(NSArray *)hazards withinTimeframe:(GGTimeframe *)timeframe
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (GGHazard *hazard in hazards) {
        
        if ([hazard isInTimeframe:timeframe]) {
            [array addObject:hazard];
        }
    }
    return array;
}


-(NSArray *)createHazardViews:(NSArray *)hazards
{
    NSMutableArray *hazardViews = [[NSMutableArray alloc] init];
    
    NSInteger hazardCount = 0;
    for (GGHazard *hazard in hazards) {
        
        if (!hazard.hazardID) {
            hazard.hazardID = [NSString stringWithFormat:@"Hazard: %li",(long)hazardCount];
        }
        
        GGHazardView *hazardView = [[GGHazardView alloc] initWithHazard:hazard];
        [hazardViews addObject:hazardView];
        hazardCount++;
    }
    
    return hazardViews;
}

-(NSArray *)hazardViews:(NSArray *)views forActiveType:(GGHazardActive)type
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (GGHazardView *hazardView in views) {
        GGHazard *hazard = hazardView.hazard;
        if (type == hazard.isActive) {
            [array addObject:hazardView];
        }
    }
    return array;
}


-(NSArray *)sortHazardViewsBySelectedPreference:(NSArray *)hazardViews
{
    NSArray *sortedHazardViews = hazardViews;
    
//    if (self.sortListSegmentedControl.selectedSegmentIndex == 0) {
//
//        // by date
//        sortedHazardViews = [self sortHazardViewsByDate:hazardViews];
//        
//    }else if (self.sortListSegmentedControl.selectedSegmentIndex == 1) {
//        
//        // by distance
//        sortedHazardViews = [self sortHazardViewsByDistance:hazardViews];
//    }
    if (self.listVC.listSortedBy == GGListSortedByDate) {
        
        // by date
        sortedHazardViews = [self sortHazardViewsByDate:hazardViews];
        
    }else if (self.listVC.listSortedBy == GGListSortedByDistance) {
        
        // by distance
        sortedHazardViews = [self sortHazardViewsByDistance:hazardViews];
    }
    
    return sortedHazardViews;
}


-(NSArray *)sortHazardViewsByDistance:(NSArray *)hazardViews
{
    NSArray *hazards = hazardViews;
    if (hazards && hazards.count > 0) {
        NSArray *sortedHazards = [hazards sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            GGHazardView *hazardView1 = (GGHazardView *)obj1;
            GGHazardView *hazardView2 = (GGHazardView *)obj2;
            CLLocationDistance distance1 = [hazardView1.hazard currentDistance];
            CLLocationDistance distance2 = [hazardView2.hazard currentDistance];
            if (distance1 < distance2) {
                return NSOrderedAscending;
            }else if (distance1 > distance2) {
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        }];
        return sortedHazards;
    }
    return hazards;
}


-(NSArray *)sortHazardViewsByDate:(NSArray *)hazardViews
{
    NSArray *hazards = hazardViews;
    if (hazards && hazards.count > 0) {
        NSArray *sortedHazards = [hazards sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            GGHazardView *hazardView1 = (GGHazardView *)obj1;
            GGHazardView *hazardView2 = (GGHazardView *)obj2;
            NSDate *date1 = [hazardView1.hazard effectiveDate];
            NSDate *date2 = [hazardView2.hazard effectiveDate];
            return [date1 compare:date2];
        }];
        // reverse
        sortedHazards = [[sortedHazards reverseObjectEnumerator] allObjects];
        return sortedHazards;
    }
    return hazards;
}

#pragma mark - Update

-(void)updateMap
{
    GGTimeframe *timeFrame = self.selectedTimeframe;
    if (timeFrame) {
        [self updateMapForTimeframe:timeFrame];
    }
}


-(void)updateMapForTimeframe:(GGTimeframe *)timeframe
{
    NSString *selectedHazardID = self.selectedHazardAnnotation.hazard.hazardID;
    NSString *temporaryHazardID;
    if (self.temporarySelectedHazard) {
        temporaryHazardID = self.temporarySelectedHazard.hazardID;
    }
    
    [self.mapView removeAnnotations:self.annotations];
    [self.mapView removeOverlays:self.overlays];
    
    [self.annotations removeAllObjects];
    [self.overlays removeAllObjects];
    
    // filtered
    self.filteredHazardViews = [self hazardViewsForTimeframe:timeframe];
    for (GGHazardView *hazardView in self.filteredHazardViews) {
        
        if ([GGConstants showPolygons]) {
            [self.overlays addObjectsFromArray:hazardView.overlays];
        }
        [self.annotations addObjectsFromArray:hazardView.subHazardCenterAnnotations];
    }
    
    [self.mapView addOverlays:self.overlays level:MKOverlayLevelAboveRoads];
    [self.mapView addAnnotations:self.annotations];
    
    self.temporarySelectedHazard = nil;

    if (temporaryHazardID){
        self.temporarySelectedHazard = [self.app.dataManager hazardWithHazardID:temporaryHazardID];
    }

    if (selectedHazardID) {
        GGHazardAnnotation *annotation = [self.hazardAnnotations valueForKey:selectedHazardID];
        [self.mapView selectAnnotation:annotation animated:NO];
        self.selectedHazardAnnotation = annotation;
    }
    
    [self updateUserAnnotations];
    
    [self.listVC reloadListData];
}


-(void)updateHazardAnnotations
{
    [self.hazardAnnotations removeAllObjects];
    
    NSArray *hazards = self.app.dataManager.hazards;
    
    // create hazardViews
    NSArray *hazardViews = [self createHazardViews:hazards];
    
    // sort
    hazardViews = [self sortHazardViewsBySelectedPreference:hazardViews];

    self.activeHazardViews = [self hazardViews:hazardViews forActiveType:GGHazardActiveNow];
    self.activeHazardViews = [self sortHazardViewsBySelectedPreference:self.activeHazardViews];

    self.expiredHazardViews = [self hazardViews:hazardViews forActiveType:GGHazardActivePassed];
    self.expiredHazardViews = [self sortHazardViewsBySelectedPreference:self.expiredHazardViews];

    for (GGHazardView *hazardView in hazardViews) {
        [self.hazardAnnotations setValue:hazardView.centerAnnotation forKey:hazardView.hazard.hazardID];
    }
    
    self.hazardViews = hazardViews;
    [self reloadData];
}


-(void)updateUserAnnotations
{
    if (self.userLocationAnnotations && self.userLocationAnnotations.count > 0) {
        [self.mapView removeAnnotations:self.userLocationAnnotations];
    }
    
    NSMutableArray *userLocationAnnotations = [[NSMutableArray alloc] init];
    if ([GGConstants isLocationSimulated]) {
        GGLocation *location = [GGConstants simulatedLocation];
        GGUserSavedAnnotation *anno = [[GGUserSavedAnnotation alloc] initWithTitle:@"Simulated Location" andCoordinate:location.coordinate];
        [userLocationAnnotations addObject:anno];
        self.simulatedLocationAnnotation = anno;
    }
    self.userLocationAnnotations = userLocationAnnotations;
    [self.mapView addAnnotations:self.userLocationAnnotations];
}


-(NSArray *)hazardViewsForTimeframe:(GGTimeframe *)timeframe
{
    NSArray *hazards = self.app.dataManager.hazards;
    NSArray *filteredHazards = [self hazards:hazards withinTimeframe:timeframe];
    NSArray *filteredHazardViews = [self createHazardViews:filteredHazards];
    filteredHazardViews = [self sortHazardViewsBySelectedPreference:filteredHazardViews];
    return filteredHazardViews;
}


-(GGHazardView *)hazardViewForHazard:(GGHazard *)hazard
{
    for (GGHazardView *view in self.hazardViews) {
        if ([view.hazard isEqual:hazard]) {
            return view;
        }
    }
    return nil;
}



#pragma mark - List

-(void)showList
{
    [GGConstants sendTrackingScreenName:@"List Screen (Map)"];
    
    [self updateHazardAnnotations];
    
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:self.listVC];
    navi.modalPresentationStyle = UIModalPresentationPopover;
    navi.popoverPresentationController.barButtonItem = self.listButton;
//    navi.popoverPresentationController.delegate = self;
    navi.preferredContentSize = CGSizeMake(0, self.view.bounds.size.height);
    [self presentViewController:navi animated:YES completion:^{
        [self.listVC reloadListData];
    }];
}


-(void)hideListAnimated:(BOOL)animated withCompletion:(void (^)(void))completionBlock
{
    [GGConstants sendTrackingScreenName:trackingScreenName];
    
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer.width = 1.0;
    UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    spacer2.width = 1.0;
    
    [self.navigationItem setRightBarButtonItems:@[self.listButton, spacer] animated:NO];
    
    [self dismissViewControllerAnimated:animated completion:completionBlock];
}


#pragma mark - App Location

-(void)app:(GGApp *)app didUpdateLocations:(NSArray *)locations
{
    [self reloadData];
}

-(void)app:(GGApp *)app didUpdateHeading:(CLHeading *)heading
{
    [self.listVC updateHeading];
}

-(void)app:(GGApp *)app didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    [self updateLocationButton];
}

-(void)reloadData
{
    self.hazardViews = [self sortHazardViewsBySelectedPreference:self.hazardViews];
    
    self.activeHazardViews = [self hazardViews:self.hazardViews forActiveType:GGHazardActiveNow];
    self.expiredHazardViews = [self hazardViews:self.hazardViews forActiveType:GGHazardActivePassed];
    
    self.listVC.activeHazardViews = self.activeHazardViews;
    self.listVC.expiredHazardViews = self.expiredHazardViews;
    self.listVC.hazardViews = self.hazardViews;
    
    [self.listVC reloadListData];
}

#pragma mark - App Internet Connection

-(void)app:(GGApp *)app didChangeInternetConnectionStatus:(AFNetworkReachabilityStatus)status
{
    if ([self.app internetConnectionAvailable]) {
        // connected
        self.internetConnectionNotAvailableToolbar.hidden = YES;
    }else{
        // not connected
        self.internetConnectionNotAvailableToolbar.hidden = NO;
    }
    
    [self.app updateAlerts:YES];
    
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
}


#pragma mark - Timer

-(void)app:(GGApp *)app timerDidFire:(NSUInteger)timerCounter
{
}


#pragma mark - Credentials

-(void)userCredentials:(GGUserCredentialsViewController *)controller didCreateAccount:(NSString *)username password:(NSString *)password
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [self createAccountForUsername:username password:password];
}

-(void)userCredentialsDidCancel:(GGUserCredentialsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


-(void)createAccountForUsername:(NSString *)username password:(NSString *)password
{
    self.app.user.gnsUsername = username;
    self.app.user.gnsPassword = password;
    
    GGGNSManager *gns = [GGGNSManager manager];
    gns.username = username;
    gns.password = password;
    [gns loadGNSAccountWithCompletion:^(NSString *error) {

        if (error) {

            XLog(@"Error: %@",error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed" message:[NSString stringWithFormat:@"There was an error creating your account: %@",error] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];

        }else{
            XLog(@"Account created");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Account created" message:@"Your account has been created successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
    }];
}

#pragma mark - GNS

-(void)gnsStatusChanged
{

}


#pragma mark - Simulated Location

-(void)showLocationServicesEventually
{
    BOOL modalPresent = self.presentedViewController != nil;
    if (!modalPresent) {
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.app.locationManager requestAlwaysAuthorization];
        }
    }
}


#pragma mark - Login

-(void)showLoginViewControllerEventually
{
    NSString *username = self.app.user.gnsUsername;
    if (!username) {
        GGLoginViewController *loginVC = [[GGLoginViewController alloc] initWithNibName:@"GGLoginViewController" bundle:nil];
        loginVC.cancelAllowed = NO;
        loginVC.delegate = self;
        loginVC.email = username;
        UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:loginVC];
        [self presentViewController:navi animated:NO completion:nil];
    }
}

-(void)login:(GGLoginViewController *)controller didLoginEmail:(NSString *)email
{
//    BOOL termsAccepted = [GGUser termsAccepted];
//    if (!termsAccepted) {
//        GGTermsViewController *termsVC = [self termsViewController];
//        [controller.navigationController pushViewController:termsVC animated:YES];
//    }else{
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)loginDidCancel:(GGLoginViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Sound

-(void)playWheelClickSound
{
    if ([GGConstants shouldPlaySound]) {
        NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"click1" ofType:@"m4a"];
        SystemSoundID soundID;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:soundPath], &soundID);
        AudioServicesPlaySystemSound (soundID);
    }
}

#pragma mark - Report

-(void)showReportController
{
    self.reportController.report = [[GGReport alloc] init];
    
    [self.navigationController pushViewController:self.reportController animated:NO];
}

-(void)hideReportController
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)reportEventViewControllerDidClose:(GGReportEventViewController *)controller
{
    [self hideReportController];
}


#pragma mark -

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    [self updateMap];
    [self updateUserAnnotations];
    [self reloadData];
    
    [self showLocationServicesEventually];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [GGConstants sendTrackingScreenName:trackingScreenName];
    
    [self updateLocationButton];

    [self.app addLocationDelegate:self];
    [self.app addTimerDelegate:self];
    [self.app addInternetConnectionDelegate:self];
    
    if ([GGConstants runningCamera] && !self.app.camera.captureSession.isRunning) {
        [self.app.camera setupCameraSession];
        [self.app.camera startCameraSession];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gnsStatusChanged) name:GGGNSStatusChangeNotification object:nil];

    [self showLoginViewControllerEventually];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.tabBarItem.title = @"UMass Emergency";
    self.title = @"UMass Emergency";
    self.navigationItem.titleView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"report_icon_small"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate]];

    self.app = [GGApp instance];
    [self.app addDataDelegate:self];
    
    self.queue = [[NSOperationQueue alloc] init];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.hazardAnnotations = [[NSMutableDictionary alloc] init];
    self.annotations = [[NSMutableArray alloc] init];
    self.overlays = [[NSMutableArray alloc] init];
    self.temporaryAnnotations = [[NSArray alloc] init];
    
    self.listVC = [[GGHazardListViewController alloc] initWithNibName:@"GGHazardListViewController" bundle:nil];
    self.listVC.delegate = self;
    
    self.mapAltitude = 7000;
    self.mapView.showsUserLocation = YES;
    if ([GGConstants isLocationSimulated]) {
        [self.mapView setUserTrackingMode:MKUserTrackingModeNone animated:NO];
        MKMapCamera *camera = [MKMapCamera cameraLookingAtCenterCoordinate:[GGConstants simulatedLocation].coordinate fromEyeCoordinate:[GGConstants simulatedLocation].coordinate eyeAltitude:self.mapAltitude];
        self.mapView.camera = camera;
    }else{
        [self.mapView setUserTrackingMode:MKUserTrackingModeFollow animated:NO];
    }
    
    self.timeframes = self.app.dataManager.timeframes;

    self.selectedTimeframe = self.timeframes[3];

    UIBarButtonItem *aboutButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"info"] landscapeImagePhone:[UIImage imageNamed:@"info"] style:UIBarButtonItemStylePlain target:self action:@selector(aboutButtonPressed:)];
    [self.navigationItem setLeftBarButtonItems:@[aboutButton]];
    
    self.listButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"list"] style:UIBarButtonItemStylePlain target:self action:@selector(listButtonPressed:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.listButton, nil]];
 
    [self hideListAnimated:NO withCompletion:nil];

    self.locationButton = [GGMapOverlayButton buttonWithType:UIButtonTypeSystem];
    self.locationButton.frame = CGRectMake(0, 0, 70, 44);
    [self.locationButton addTarget:self action:@selector(locationButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.locationButton setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
    [self.mapView addSubview:self.locationButton];
    [self updateLocationButton];

    self.reportButton = [GGMapOverlayButton buttonWithType:UIButtonTypeSystem];
    self.reportButton.frame = CGRectMake(0, 0, 70, 70);
    [self.reportButton addTarget:self action:@selector(reportWarningButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.reportButton setImage:[UIImage imageNamed:@"report_icon"] forState:UIControlStateNormal];
    self.reportButton.tintColor = [UIColor whiteColor];
    self.reportButton.backgroundColor = [UIColor umassMaroonColor];
    self.reportButton.imageEdgeInsets = UIEdgeInsetsMake(10, 14, 18, 14);
    self.reportButton.layer.cornerRadius = self.reportButton.frame.size.width/2;
    [self.mapView addSubview:self.reportButton];

    self.attributesButton = [GGMapOverlayButton buttonWithType:UIButtonTypeSystem];
    self.attributesButton.frame = CGRectMake(0, 0, 70, 44);
    [self.attributesButton addTarget:self action:@selector(settingsButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.attributesButton setImage:[UIImage imageNamed:@"preferences_full"] forState:UIControlStateNormal];
    [self.mapView addSubview:self.attributesButton];

    [self.mapView addSubview:self.hazardInfoView];
    self.hazardInfoView.delegate = self;
    [self hideHazardInfoAnimated:NO];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateHazardAnnotationsOnMapNotificationReceived:) name:GGUpdateHazardsOnMapNotification object:nil];

    self.reportController = [[GGReportEventViewController alloc] initWithNibName:@"GGReportEventViewController" bundle:nil];
    self.reportController.delegate = self;
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.app removeLocationDelegate:self];
    [self.app removeTimerDelegate:self];
    [self.app removeInternetConnectionDelegate:self];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:GGGNSStatusChangeNotification object:nil];
}



#pragma mark -

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGFloat tempHeight = self.internetConnectionNotAvailableToolbar.hidden ? 0 : self.internetConnectionNotAvailableToolbar.frame.size.height;
    
    self.attributesButton.frame = CGRectMake(15, self.mapView.frame.origin.y+self.mapView.frame.size.height-self.attributesButton.frame.size.height-15-tempHeight, self.attributesButton.frame.size.width, self.attributesButton.frame.size.height);

    CGRect reportButtonFrame = self.reportButton.frame;
    reportButtonFrame.origin.x = self.mapView.center.x - self.reportButton.frame.size.width/2;
    reportButtonFrame.origin.y = self.mapView.frame.origin.y+self.mapView.frame.size.height-self.reportButton.frame.size.height-15-tempHeight;
    self.reportButton.frame = reportButtonFrame;

    self.locationButton.frame = CGRectMake(self.mapView.frame.size.width-self.locationButton.frame.size.width-15, self.mapView.frame.origin.y+self.mapView.frame.size.height-self.locationButton.frame.size.height-15-tempHeight, self.locationButton.frame.size.width, self.locationButton.frame.size.height);

    self.hazardInfoView.frame = CGRectMake(0, 0, self.mapView.frame.size.width, self.hazardInfoView.frame.size.height);
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GGUpdateHazardsOnMapNotification object:nil];
    [self.app removeDataDelegate:self];
}

@end
