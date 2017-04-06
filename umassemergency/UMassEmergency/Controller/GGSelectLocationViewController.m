//
//  GGSelectLocationViewController.m
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

#import "GGSelectLocationViewController.h"
#import "GGAnnotation.h"

#define trackingScreenName @"Locations: Select Location Screen"

@interface GGSelectLocationViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) NSArray *searchResults;
//@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIImageView *targetIcon;

@end

@implementation GGSelectLocationViewController

#pragma mark - IBAction

-(IBAction)deleteButtonPressed:(id)sender
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Delete Confirmation" message:@"Are you sure you want to delete this location?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Delete", nil];
    [alertView show];
}

-(IBAction)doneButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectLocation:didSelectLocation:)]) {
        [self.delegate selectLocation:self didSelectLocation:self.selectedLocation];
    }
}

-(IBAction)cancelButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(selectLocationDidCancel:)]) {
        [self.delegate selectLocationDidCancel:self];
    }
}



#pragma mark - AlertViewDelegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.cancelButtonIndex == buttonIndex) {
        // nothing happens
    }else{
        if (self.delegate && [self.delegate respondsToSelector:@selector(selectLocation:didSelectDeleteLocation:)]) {
            [self.delegate selectLocation:self didSelectDeleteLocation:self.previousLocation];
        }
    }
}


#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchResults.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
//    CLPlacemark *placemark = [self.searchResults objectAtIndex:indexPath.row];
//    NSDictionary *addressDictionary = placemark.addressDictionary;

    MKMapItem *mapItem = [self.searchResults objectAtIndex:indexPath.row];
    MKPlacemark *placemark = mapItem.placemark;
    NSDictionary *addressDictionary = placemark.addressDictionary;
    NSArray *formattedAddressArray = [addressDictionary valueForKey:@"FormattedAddressLines"];
    if (formattedAddressArray && formattedAddressArray.count > 0) {
        if (formattedAddressArray.count > 1) {
            cell.textLabel.text = formattedAddressArray[0];
            cell.detailTextLabel.text = formattedAddressArray[1];
        }else{
            cell.textLabel.text = formattedAddressArray[0];
        }
    }else{
        cell.textLabel.text = placemark.name;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CLPlacemark *placemark = [self.searchResults objectAtIndex:indexPath.row];
    MKMapItem *mapItem = [self.searchResults objectAtIndex:indexPath.row];
    MKPlacemark *placemark = mapItem.placemark;
    [self.searchDisplayController setActive:NO animated:YES];
    
//    MKCoordinateRegion region = self.mapView.region;
//    region.center = placemark.region.center;
//    region.span.longitudeDelta /= 8.0;
//    region.span.latitudeDelta /= 8.0;
    
    MKPlacemark *mapPlacemark = [[MKPlacemark alloc] initWithPlacemark:placemark];

//    [self.mapView setRegion:region animated:YES];
//    [self.mapView addAnnotation:mapPlacemark];
    [self.mapView showAnnotations:[NSArray arrayWithObject:mapPlacemark] animated:NO];
    MKMapCamera *camera = self.mapView.camera;
//    XLog(@"Altitude: %f",camera.altitude);
//    camera.altitude = camera.altitude*8;
//    XLog(@"Altitude: %f",camera.altitude);
    camera.altitude = 7000;
    [self.mapView setCamera:camera animated:YES];

    [self.mapView removeAnnotation:placemark];
    self.selectedLocation = placemark.location;
}


#pragma mark - Search

-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    XLog(@"");
//    NSString *searchString = @"some address, state, and zip";
    NSString *searchString = searchController.searchBar.text;
    [self updateSearchResultsForText:searchString];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    [self updateSearchResultsForText:searchText];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)updateSearchResultsForText:(NSString *)searchString
{
    /*
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:searchString
                 completionHandler:^(NSArray* placemarks, NSError* error){
                     if (placemarks && placemarks.count > 0) {
//                         CLPlacemark *topResult = [placemarks objectAtIndex:0];
                         self.searchResults = placemarks;
                         [self.searchDisplayController.searchResultsTableView reloadData];
                         
                         
                     }
                 }
     ];
     */
    
    MKLocalSearchRequest* request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = searchString;
//    request.region = MKCoordinateRegionMakeWithDistance(loc, kSearchMapBoundingBoxDistanceInMetres, kSearchMapBoundingBoxDistanceInMetres);
    
    MKLocalSearch* search = [[MKLocalSearch alloc] initWithRequest:request];
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSArray *placemarks = response.mapItems;
        if (placemarks && placemarks.count > 0) {
            self.searchResults = placemarks;
            [self.searchDisplayController.searchResultsTableView reloadData];
        }
    }];
}

-(void)checkPlacemarkForLocation:(CLLocation *)location
{
    CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
    [geoCoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks && placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSDictionary *addressDictionary = placemark.addressDictionary;
            NSArray *formattedAddressArray = [addressDictionary valueForKey:@"FormattedAddressLines"];
            if (formattedAddressArray && formattedAddressArray.count > 0) {
                if (formattedAddressArray.count > 1) {
                    self.toolbarLabel.text = [NSString stringWithFormat:@"%@\n%@",formattedAddressArray[0],formattedAddressArray[1]];
                }else{
                    self.toolbarLabel.text = formattedAddressArray[0];
                }
            }else{
                self.toolbarLabel.text = placemark.name;
            }
        }
    }];
}

-(void)setSelectedLocation:(CLLocation *)selectedLocation
{
    _selectedLocation = selectedLocation;
    if (selectedLocation) {
        XLog(@"isBeingPresented: %@",self.isBeingPresented ? @"YES" : @"NO");
        XLog(@"navigationController.isBeingPresented: %@",self.isBeingPresented ? @"YES" : @"NO");
        if ([self isModal]) {
            // is presented, so dont talk to delegate until user says done or cancel
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(selectLocation:didSelectLocation:)]) {
                [self.delegate selectLocation:self didSelectLocation:self.selectedLocation];
            }
        }
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }else{
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
}


#pragma mark - Map

-(void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    CLLocationCoordinate2D centre = [mapView centerCoordinate];
//    XLog(@"%f,%f",centre.latitude,centre.longitude);
    [self updateMapCentre];
}


- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}


- (void)didDragMap:(UIGestureRecognizer*)gestureRecognizer
{
//    [self updateMapCentre];
    self.toolbarLabel.text = @"";
    
//    if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
//        XLog(@"drag ended");
//    }
}

-(void)updateMapCentre
{
    CLLocationCoordinate2D centre = [self.mapView centerCoordinate];
    XLog(@"%f,%f",centre.latitude,centre.longitude);
    CLLocation *centreLocation = [[CLLocation alloc] initWithLatitude:centre.latitude longitude:centre.longitude];
    [self checkPlacemarkForLocation:centreLocation];
    self.selectedLocation = centreLocation;
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
    
    [self.navigationItem setPrompt:@"Drag and move the map to your desired location"];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    self.mapView.showsUserLocation = YES;
    self.mapView.delegate = self;
    
    self.searchResults = [NSArray array];
    
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;

    if ([self isModal]) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:doneButton];
        self.navigationItem.rightBarButtonItem.enabled = NO;
        
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
    
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didDragMap:)];
    [panRec setDelegate:self];
    [self.mapView addGestureRecognizer:panRec];
    
    self.targetIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"target"]];
    self.targetIcon.frame = CGRectMake(0, 0, 30, 30);
    self.targetIcon.alpha = 0.8;
    [self.view addSubview:self.targetIcon];
    
    self.toolbarLabel.numberOfLines = 0;
    self.toolbarLabel.backgroundColor = [UIColor clearColor];

    if (self.previousLocation) {
        GGAnnotation *anno = [[GGAnnotation alloc] initWithTitle:@"Current" andCoordinate:self.previousLocation.coordinate];
        [self.mapView addAnnotation:anno];
        [self.mapView showAnnotations:@[anno] animated:NO];
        MKMapCamera *camera = self.mapView.camera;
        camera.altitude = 15000;
        [self.mapView setCamera:camera animated:NO];        
    }else{
        NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
        [array removeObject:self.trashButton];
        self.toolbar.items = array;
    }

    if (self.selectedLocation) {
        [self.mapView setCamera:[MKMapCamera cameraLookingAtCenterCoordinate:self.selectedLocation.coordinate fromEyeCoordinate:self.selectedLocation.coordinate eyeAltitude:15000]];
        MKMapCamera *camera = self.mapView.camera;
        camera.altitude = 15000;
        [self.mapView setCamera:camera animated:NO];
    }
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.navigationItem setPrompt:nil];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.targetIcon.center = self.mapView.center;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)isModal {
    return self.presentingViewController.presentedViewController == self
    || (self.navigationController != nil && self.navigationController.presentingViewController.presentedViewController == self.navigationController)
    || [self.tabBarController.presentingViewController isKindOfClass:[UITabBarController class]];
}

@end
