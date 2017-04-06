//
//  GGSimulationSettingsViewController.m
//  WindContours
//
//  Created by Görkem Güclü on 16.05.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "GGSimulationSettingsViewController.h"
#import "GGApp.h"
#import "GGSelectSimulationLocationViewController.h"
#import "AppDelegate.h"

#define trackingScreenName @"Simulation Settings Screen"

typedef enum : NSUInteger {
    SimulationSettingsTableSectionTimeSimulation = 0,
    SimulationSettingsTableSectionLocationSimulation = 1,
} SimulationSettingsTableSection;

@interface GGSimulationSettingsViewController () <GGSelectSimulationLocationDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) GGApp *app;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end

@implementation GGSimulationSettingsViewController

#pragma mark - IBAction

-(IBAction)datePickerValueChanged:(id)sender
{
    NSDate *date = self.datePicker.date;
    [GGConstants setSimulatedTime:date];
    if ([GGConstants isSimulatedTimeAdvancing]) {
        NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:[GGConstants simulatedTime]];
        [GGConstants setSimulatedTimeInterval:interval];
    }
}

#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == SimulationSettingsTableSectionTimeSimulation) {
        if ([GGConstants isTimeSimulated]) {
            return 3;
        }
        return 1;
    }else if (section == SimulationSettingsTableSectionLocationSimulation) {
        if ([GGConstants isLocationSimulated]) {
            return 2;
        }
        return 1;
    }
    return 0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == SimulationSettingsTableSectionTimeSimulation) {
        return @"Simulate time and date";
    } else if(section == SimulationSettingsTableSectionLocationSimulation) {
        return @"Simulate location (GNS only)";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if(section == SimulationSettingsTableSectionTimeSimulation) {
        return @"Enable to simulate specific time and date";
    } else if(section == SimulationSettingsTableSectionLocationSimulation) {
        return @"Enable to simulate a specific user location (to write in GNS)";
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textColor = [UIColor blackColor];
    
    if(indexPath.section == SimulationSettingsTableSectionTimeSimulation) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"timeSimulation"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"timeSimulation"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if (indexPath.row == 0) {
            
            cell.textLabel.text = @"Time simulation";
            if ([GGConstants isTimeSimulated]) {
                cell.detailTextLabel.text = @"On";
            }else{
                cell.detailTextLabel.text = @"Off";
            }
            
        }else if(indexPath.row == 1) {
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            cell.textLabel.text = nil;
            cell.detailTextLabel.text = nil;
            self.datePicker.frame = CGRectMake(0, 0, cell.frame.size.width, self.datePicker.frame.size.height);
            [cell.contentView addSubview:self.datePicker];
            
        }else if(indexPath.row == 2) {
            
            cell.textLabel.text = @"Time advances";
            
            if ([GGConstants isSimulatedTimeAdvancing]) {
                cell.detailTextLabel.text = @"On";
            }else{
                cell.detailTextLabel.text = @"Off";
            }
            
        }
        
        return cell;
        
    } else if(indexPath.section == SimulationSettingsTableSectionLocationSimulation) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locSimulation"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"locSimulation"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Location simulation";
            if ([GGConstants isLocationSimulated]) {
                cell.detailTextLabel.text = @"On";
            }else{
                cell.detailTextLabel.text = @"Off";
            }
            
        }else if(indexPath.row == 1) {
            
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"locSimulationCoordinates"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"locSimulationCoordinates"];
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
            
            cell.textLabel.text = @"Select simulation location";
            GGLocation *location = [GGConstants simulatedLocation];
            if (location) {
                if (location.name) {
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"Selected: %@",location.name];
                }else{
                    NSString *coordinatesString = [NSString stringWithFormat:@"Selected: %f,%f",location.coordinate.latitude,location.coordinate.longitude];
                    cell.detailTextLabel.text = coordinatesString;
                }
            }
            return cell;
        }
        return cell;
    }
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SimulationSettingsTableSectionTimeSimulation) {
        
        if (indexPath.row == 0) {
            BOOL isTimeSimulated = [GGConstants isTimeSimulated];
            if (isTimeSimulated) {
                [GGConstants setIsTimeSimulated:!isTimeSimulated];
            }else{
                [GGConstants setIsTimeSimulated:YES];
                [GGConstants setSimulatedTime:self.datePicker.date];
            }
            self.datePicker.hidden = ![GGConstants isTimeSimulated];
            
            [self reloadTableSection:indexPath.section];
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            
        }else if (indexPath.row == 2) {
            
            BOOL isSimulatedTimeAdvancing = [GGConstants isSimulatedTimeAdvancing];
            [GGConstants setIsSimulatedTimeAdvancing:!isSimulatedTimeAdvancing];
            NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:[GGConstants simulatedTime]];
            [GGConstants setSimulatedTimeInterval:interval];
            [self reloadTableSection:indexPath.section];
            
        }

        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate updateDeveloperStatus];

    } else if (indexPath.section == SimulationSettingsTableSectionLocationSimulation) {
        
        if (indexPath.row == 0) {
            
            BOOL isLocationSimulated = [GGConstants isLocationSimulated];
            [GGConstants setIsLocationSimulated:!isLocationSimulated];
            
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [self reloadTableSection:indexPath.section];
            
        }else if (indexPath.row == 1) {
            
            GGSelectSimulationLocationViewController *vc = [[GGSelectSimulationLocationViewController alloc] initWithNibName:@"GGSelectSimulationLocationViewController" bundle:nil];
            vc.delegate = self;
            [self.navigationController pushViewController:vc animated:YES];
            
        }
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == SimulationSettingsTableSectionTimeSimulation && indexPath.row == 1) {
        return self.datePicker.frame.size.height;
    }
    return UITableViewAutomaticDimension;
}

#pragma mark - Select Simulation Location

-(void)simulationLocation:(GGSelectSimulationLocationViewController *)controller didSelectLocation:(GGLocation *)location
{
    [GGConstants setSimulatedLocation:location];
    [self.app updateLocationInBackground:location withCompletion:nil];
    
    [self reloadTableSection:SimulationSettingsTableSectionLocationSimulation];
}

#pragma mark -

-(void)reloadTableSection:(NSUInteger)index
{
    if ([self.table numberOfSections] > index) {
        [self.table reloadSections:[NSIndexSet indexSetWithIndex:index] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}


#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.table deselectRowAtIndexPath:[self.table indexPathForSelectedRow] animated:YES];
    
    [GGConstants sendTrackingScreenName:trackingScreenName];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Simulation Settings";
    
    self.app = [GGApp instance];
    
    self.table.estimatedRowHeight = 44.0;
    self.table.rowHeight = UITableViewAutomaticDimension;
    
    self.datePicker = [[UIDatePicker alloc] init];
    [self.datePicker addTarget:self action:@selector(datePickerValueChanged:) forControlEvents:UIControlEventValueChanged];
    BOOL isTimeSimulated = [GGConstants isTimeSimulated];
    self.datePicker.hidden = !isTimeSimulated;
    if (isTimeSimulated) {
        NSDate *date = [GGConstants simulatedTime];
        if (date) {
            self.datePicker.date = date;
        }
    }
}



@end
