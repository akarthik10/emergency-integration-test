//
//  GGAttributesSettingsViewController.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 11.07.16.
//  Copyright © 2016 University of Massachusetts.
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

#import "GGAttributesSettingsViewController.h"
#import "GGApp.h"
#import "GGGNSManager.h"
#import "GGAttribute.h"
#import "GGAttributeDetailViewController.h"

@interface GGAttributesSettingsViewController () <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) GGApp *app;
@property (strong, nonatomic) NSArray *attributes;
@property (readwrite, nonatomic) BOOL loading;
@property (strong, nonatomic) NSString *error;
@property (weak, nonatomic) IBOutlet UITableView *table;

@end

@implementation GGAttributesSettingsViewController

-(IBAction)doneButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.error) {
        return 1;
    }
    return self.attributes.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.error) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"error"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"error"];
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.text = @"Retry Loading Preferences";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    }
    
    GGAttribute *attribute = [self.attributes objectAtIndex:indexPath.row];
    cell.textLabel.text = attribute.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.userInteractionEnabled = !self.loading;

    if (attribute.selectedValues.count > 0) {
        cell.detailTextLabel.text = attribute.selectedValuesString;
    }else{
        cell.detailTextLabel.text = nil;
    }

    if (self.loading) {
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.text = @"Loading ...";
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
    }

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.error) {
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        [self loadPreferences];
        return;
    }
    
    GGAttribute *attribute = [self.attributes objectAtIndex:indexPath.row];

    GGAttributeDetailViewController *detailVC = [[GGAttributeDetailViewController alloc] initWithNibName:@"GGAttributeDetailViewController" bundle:nil];
    detailVC.attribute = attribute;
    [self.navigationController pushViewController:detailVC animated:YES];
}


#pragma mark - Connection

-(void)setLoading:(BOOL)loading
{
    _loading = loading;
    if (loading) {
        UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        [activity startAnimating];
        self.navigationItem.titleView = activity;
    }else{
        self.navigationItem.titleView = nil;
        self.title = @"Preferences";
    }
    [self.table reloadData];
}


-(void)loadPreferences
{
    self.loading = YES;
    GGGNSManager *gns = [GGGNSManager manager];
    switch (gns.status) {
        case GGGNSStatusAccountLoaded:
        {
            self.navigationItem.prompt = nil;
            [self.app.dataManager downloadAttributesPreferencesWithCompletion:^(NSString *error) {
                self.loading = NO;
                self.error = error;
                self.attributes = self.app.dataManager.attributes;
                [self.table reloadData];
            }];
        }
            break;
        default:
            self.navigationItem.prompt = @"Not connected yet. Connecting ...";
            break;
    }
    [self.table reloadData];
}

-(void)gnsStatusChanged
{
    [self loadPreferences];
}

#pragma mark -

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.table deselectRowAtIndexPath:self.table.indexPathForSelectedRow animated:YES];
    [self.table reloadData];
    [self loadPreferences];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gnsStatusChanged) name:GGGNSStatusChangeNotification object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Preferences";
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.leftBarButtonItem = doneButton;

    self.app = [GGApp instance];
    self.attributes = self.app.dataManager.attributes;
    
    [self loadPreferences];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:GGGNSStatusChangeNotification object:nil];
}

@end
