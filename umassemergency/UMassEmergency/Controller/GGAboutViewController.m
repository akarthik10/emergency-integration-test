//
//  GGAboutViewController.m
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

#import "GGAboutViewController.h"
#import "GGGNSManager.h"
#import "GGGNSDataViewController.h"
#import "NSString+GGJSONObject.h"
#import "GGDeveloperSettingsViewController.h"
#import "GGApp.h"

#define trackingScreenName @"About Screen"

typedef enum : NSUInteger {
    AboutTableSectionImprint = 0,
    AboutTableSectionDeveloper = 1,
} AboutTableSection;

@interface GGAboutViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;

@property (nonatomic, strong) GGApp *app;

@property (nonatomic, readwrite) BOOL developerMode;

@end

@implementation GGAboutViewController

-(IBAction)developerButtonPressed:(id)sender
{
    self.developerMode = NO;
}

-(IBAction)normalButtonPressed:(id)sender
{
    self.developerMode = YES;
}

-(IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.developerMode) {
        return 1;
    }
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == AboutTableSectionImprint) {
        return 1;
    }else if (section == AboutTableSectionDeveloper) {
        return 1;
    }
    return 0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == AboutTableSectionImprint) {
        return @"Imprint";
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

    if (indexPath.section == AboutTableSectionImprint) {
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.text = @"UMass Emergency\n\nLorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam aliquet ex felis, eu lobortis massa dictum et. Vestibulum pulvinar malesuada odio, ac ornare turpis hendrerit et. Mauris vehicula nunc eu ullamcorper imperdiet. Nunc vestibulum tincidunt justo, id congue sem commodo at. Aliquam condimentum finibus consectetur. Nunc euismod auctor eros ut venenatis. Cras imperdiet finibus massa, eget iaculis nibh tempus sed. Etiam aliquet eros eros, sit amet aliquet dui hendrerit nec. Vivamus ut lorem ornare, pulvinar risus vehicula, semper eros. Interdum et malesuada fames ac ante ipsum primis in faucibus. Proin ac nunc nec mi scelerisque imperdiet nec eget nisl. Nullam placerat nunc arcu, a tempus massa egestas vel. Etiam quis elit ultricies, congue lorem sit amet, elementum purus. Ut malesuada at neque ac volutpat.";
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:10];

    } else if(indexPath.section == AboutTableSectionDeveloper) {

        cell.textLabel.text = @"Developer Settings";
        cell.textLabel.textAlignment = NSTextAlignmentLeft;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == AboutTableSectionImprint) {
        
    }else if (indexPath.section == AboutTableSectionDeveloper) {
        
        GGDeveloperSettingsViewController *developerVC = [[GGDeveloperSettingsViewController alloc] initWithNibName:@"GGDeveloperSettingsViewController" bundle:nil];
        [self.navigationController pushViewController:developerVC animated:YES];
    }
}


#pragma mark - Developer


-(void)setDeveloperMode:(BOOL)developerMode
{
    _developerMode = developerMode;
    
    [GGConstants setInDeveloperMode:developerMode];
    
    if (developerMode) {
        UIBarButtonItem *developerButton = [[UIBarButtonItem alloc] initWithTitle:@"Developer" style:UIBarButtonItemStylePlain target:self action:@selector(developerButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:developerButton];
    }else{
        UIBarButtonItem *normalButton = [[UIBarButtonItem alloc] initWithTitle:@"Normal" style:UIBarButtonItemStylePlain target:self action:@selector(normalButtonPressed:)];
        [self.navigationItem setRightBarButtonItem:normalButton];
    }
    
    [self.table reloadData];
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
    // Do any additional setup after loading the view, typically from a nib.
    
    self.app = [GGApp instance];

    self.table.estimatedRowHeight = 44.0;
    self.table.rowHeight = UITableViewAutomaticDimension;
    
    NSString *majorVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *minorVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    self.title = [NSString stringWithFormat:@"About %@ (%@)",majorVersion,minorVersion];
    self.tabBarItem.title = @"About";
    
    if ([self isModal]) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(doneButtonPressed:)];
        [self.navigationItem setLeftBarButtonItem:doneButton];
    }

    self.developerMode = [GGConstants inDeveloperMode];
}



@end
