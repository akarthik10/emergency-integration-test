//
//  GGDeveloperSettingsViewController.m
//  WindContours
//
//  Created by Görkem Güclü on 15.05.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "GGDeveloperSettingsViewController.h"
#import "GGApp.h"
#import "GGGNSStatusViewController.h"
#import "GGSimulationSettingsViewController.h"

#define trackingScreenName @"Developer Settings Screen"

typedef enum : NSUInteger {
    DeveloperSettingsTableSectionNotificationToken = 0,
    DeveloperSettingsTableSectionGroupSettings = 1,
    DeveloperSettingsTableSectionSettings = 2,
} DeveloperSettingsTableSection;

@interface GGDeveloperSettingsViewController ()

@property (nonatomic, strong) GGApp *app;
@property (nonatomic, strong) IBOutlet UITableView *table;

@property (nonatomic, readwrite) BOOL loadingGNSData;
@property (nonatomic, strong) NSString *gnsData;


@end

@implementation GGDeveloperSettingsViewController

#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == DeveloperSettingsTableSectionNotificationToken) {
        return 1;
    }else if (section == DeveloperSettingsTableSectionGroupSettings) {
        return 2;
    }else if (section == DeveloperSettingsTableSectionSettings) {
        return 2;
    }
    return 0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == DeveloperSettingsTableSectionNotificationToken) {
        return @"Notification Token";
    } else if(section == DeveloperSettingsTableSectionSettings) {
        return @"Settings";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == DeveloperSettingsTableSectionNotificationToken) {
        return @"Select to copy to clipboard.";
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
    
    if(indexPath.section == DeveloperSettingsTableSectionNotificationToken) {
        
        cell.textLabel.text = self.app.deviceToken;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.adjustsFontSizeToFitWidth = YES;
        
    } else if(indexPath.section == DeveloperSettingsTableSectionGroupSettings) {

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

        if (indexPath.row == 0) {
            // GNS
            cell.textLabel.text = @"GNS";
        }else if(indexPath.row == 1) {
            // Simulation
            cell.textLabel.text = @"Simulation settings";
        }
        
    } else if(indexPath.section == DeveloperSettingsTableSectionSettings) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCells"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"settingCells"];
        }
        
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if (indexPath.row == 0) {
            cell.textLabel.text = @"Keep Camera running";
            if ([GGConstants runningCamera]) {
                cell.detailTextLabel.text = @"On";
            }else{
                cell.detailTextLabel.text = @"Off";
            }
            
        }else if (indexPath.row == 1) {
            
            cell.textLabel.text = @"Receive Notification When New Location Uploaded";
            cell.textLabel.font = [UIFont systemFontOfSize:10];
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.minimumScaleFactor = 0.5;
            if ([GGConstants receiveNotificationWhenLocationUpdated]) {
                cell.detailTextLabel.text = @"On";
            }else{
                cell.detailTextLabel.text = @"Off";
            }
        }
        
        return cell;
    }
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == DeveloperSettingsTableSectionNotificationToken) {
        
        if (self.app.deviceToken) {
            UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
            pasteboard.string = self.app.deviceToken;
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Token copied!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }else{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No device token available. Please enable in Settings App." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        
    } else if(indexPath.section == DeveloperSettingsTableSectionGroupSettings) {
        
        if (indexPath.row == 0) {
            
            // GNS
            GGGNSStatusViewController *gnsVC = [[GGGNSStatusViewController alloc] initWithNibName:@"GGGNSStatusViewController" bundle:nil];
            [self.navigationController pushViewController:gnsVC animated:YES];
            
        }else if(indexPath.row == 1) {
        
            // Simulation
            GGSimulationSettingsViewController *simulationVC = [[GGSimulationSettingsViewController alloc] initWithNibName:@"GGSimulationSettingsViewController" bundle:nil];
            [self.navigationController pushViewController:simulationVC animated:YES];

        }

    } else if (indexPath.section == DeveloperSettingsTableSectionSettings) {
        
        if (indexPath.row == 0) {
            
            BOOL runningCamera = [GGConstants runningCamera];
            [GGConstants setRunningCamera:!runningCamera];
            
            if (runningCamera) {
                [self.app.camera setupCameraSession];
                [self.app.camera startCameraSession];
            }else{
                [self.app.camera stopCameraSession];
            }
            
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [self reloadTableSection:indexPath.section];
            
        }else if (indexPath.row == 1) {
            
            BOOL receiveNotificationWhenLocationUpdated = [GGConstants receiveNotificationWhenLocationUpdated];
            [GGConstants setReceiveNotificationWhenLocationUpdated:!receiveNotificationWhenLocationUpdated];
            
            [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
            [self reloadTableSection:indexPath.section];
        }
        
    }
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

    self.title = @"Developer Settings";
    
    self.app = [GGApp instance];

    self.table.estimatedRowHeight = 44.0;
    self.table.rowHeight = UITableViewAutomaticDimension;

}


@end
