//
//  GGGNSDataViewController.m
//  WindContours
//
//  Created by Görkem Güclü on 23.03.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//

#import "GGGNSDataViewController.h"
#import "GGApp.h"
#import "NSDictionary+GGSortedDictionary.h"
#import "GGGeoJSON.h"
#import <MapKit/MapKit.h>
#import "GGAnnotation.h"

@interface GGGNSDataViewController () <UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) GGApp *app;

@property (nonatomic, strong) MKMapView *mapView;

@end

@implementation GGGNSDataViewController


#pragma mark -

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([self.data isKindOfClass:[NSDictionary class]]) {

        // NSDictionary
        return ((NSDictionary *)self.data).allKeys.count;
    
    }else if([self.data isKindOfClass:[NSArray class]]) {
    
        // NSArray
        return ((NSArray *)self.data).count;
        
    }else if([self.data isKindOfClass:[NSString class]]) {
        // NSString
        return 1;
        
    }else if([self.data isKindOfClass:[NSNumber class]]) {
        // NSNumber
        return 1;
    }

    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    BOOL hasChildren = NO;
    cell.detailTextLabel.text = nil;
    cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;

    if ([self.data isKindOfClass:[NSDictionary class]]) {
        
        // NSDictionary
        NSString *key = [[((NSDictionary *)self.data) allKeysSortedAlphabeticallyAscending:YES] objectAtIndex:indexPath.row];
        hasChildren = YES;
        cell.textLabel.text = key;
        
        id data = [((NSDictionary *)self.data) valueForKey:key];
        if ([data isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = (NSString *)data;
            hasChildren = NO;
        }else if ([key isKindOfClass:[NSNumber class]]) {
            cell.detailTextLabel.text = [(NSNumber *)data stringValue];
            hasChildren = NO;
        }
        
    }else if([self.data isKindOfClass:[NSArray class]]) {
        
        // NSArray
        id key = [((NSArray *)self.data) objectAtIndex:indexPath.row];
        hasChildren = YES;
        if ([key isKindOfClass:[NSString class]]) {
            cell.textLabel.text = (NSString *)key;
            hasChildren = NO;
        }else if ([key isKindOfClass:[NSNumber class]]) {
            cell.textLabel.text = [(NSNumber *)key stringValue];
            hasChildren = NO;
        }else if ([key isKindOfClass:[NSArray class]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%lu children",(unsigned long)[(NSArray *)key count]];
        }else if ([key isKindOfClass:[NSDictionary class]]) {
            cell.textLabel.text = [NSString stringWithFormat:@"%lu children",(unsigned long)[(NSDictionary *)key allKeys].count];
        }
        
    }else if([self.data isKindOfClass:[NSString class]]) {
        // NSString
        cell.textLabel.text = (NSString *)self.data;
        
    }else if([self.data isKindOfClass:[NSNumber class]]) {
        // NSNumber
        cell.textLabel.text = [(NSNumber *)self.data stringValue];
    }

    
    if (hasChildren) {
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else{
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasChildren = NO;
    NSString *key = nil;
    id data = nil;
    if ([self.data isKindOfClass:[NSDictionary class]]) {
        
        // NSDictionary
        key = [[((NSDictionary *)self.data) allKeysSortedAlphabeticallyAscending:YES] objectAtIndex:indexPath.row];
        data = [((NSDictionary *)self.data) valueForKey:key];
        hasChildren = YES;
        
        if ([data isKindOfClass:[NSString class]]) {
            hasChildren = NO;
        }else if ([key isKindOfClass:[NSNumber class]]) {
            hasChildren = NO;
        }
        
    }else if([self.data isKindOfClass:[NSArray class]]) {
        
        // NSArray
        id key = [((NSArray *)self.data) objectAtIndex:indexPath.row];
        hasChildren = YES;
        data = key;
        
        if ([key isKindOfClass:[NSString class]]) {
            hasChildren = NO;
        }else if ([key isKindOfClass:[NSNumber class]]) {
            hasChildren = NO;
        }
    }
    
    if (hasChildren) {
        GGGNSDataViewController *gnsDataVC = [[GGGNSDataViewController alloc] initWithNibName:@"GGGNSDataViewController" bundle:nil];
        gnsDataVC.key = key;
        gnsDataVC.data = data;
        [self.navigationController pushViewController:gnsDataVC animated:YES];
    }
}


#pragma mark - Map View

-(void)setupMapView
{
    CGRect frame = CGRectMake(0, 0, self.table.frame.size.width, 300);
    self.mapView = [[MKMapView alloc] initWithFrame:frame];
    self.mapView.delegate = self;
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.mapView.showsUserLocation = YES;
    self.table.tableHeaderView = self.mapView;
}

-(void)addLocationToMap:(CLLocation *)location
{
    GGAnnotation *annotation = [[GGAnnotation alloc] initWithTitle:self.key andCoordinate:location.coordinate];
    [self.mapView addAnnotation:annotation];
    
    [self.mapView showAnnotations:self.mapView.annotations animated:NO];
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[GGAnnotation class]]) {
        MKPinAnnotationView *pin = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinAnnotation"];
        if (pin == nil) {
            pin = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinAnnotation"];
        }
        pin.canShowCallout = YES;
        pin.pinTintColor = [UIColor umassMaroonColor];
        return pin;
    }
    return nil;
}


#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.table deselectRowAtIndexPath:[self.table indexPathForSelectedRow] animated:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if (self.key) {
        self.title = self.key;
    }
    
    if (self.data) {

        if ([self.data isKindOfClass:[NSDictionary class]]) {
            // NSDictionary
            
            GGGeoJSON *geoJSON = [[GGGeoJSON alloc] initWithGeoJSON:self.data];
            if (geoJSON.numberOfPoints > 0) {
                // activate map
                if (geoJSON.point) {
                    [self setupMapView];
                    [self addLocationToMap:geoJSON.point];
                }
            }
            
        }else if([self.data isKindOfClass:[NSArray class]]) {
            // NSArray

        }else if([self.data isKindOfClass:[NSString class]]) {
            // NSString

        }else if([self.data isKindOfClass:[NSNumber class]]) {
            // NSNumber

        }else {
            // Something else
            self.data = @{};
        }

    }
}

@end
