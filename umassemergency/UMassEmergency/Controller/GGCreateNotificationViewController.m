//
//  GGCreateNotificationViewController.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 23.08.15.
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

#import "GGCreateNotificationViewController.h"

typedef enum : NSUInteger {
    GGCreateNotificationTableSectionTextFields,
    GGCreateNotificationTableSectionCreateButton,
    GGCreateNotificationTableSectionList,
} GGCreateNotificationTableSection;

@interface GGCreateNotificationViewController ()

@property (nonatomic, strong) UITextField *alertText;
@property (nonatomic, strong) UITextField *alertID;
@property (nonatomic, strong) UISwitch *stickySwitch;

@property (nonatomic, strong) NSMutableArray *notifications;

@end

@implementation GGCreateNotificationViewController


#pragma mark -

-(IBAction)cancelButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(createNotificationDidCancel:)]) {
        [self.delegate createNotificationDidCancel:self];
    }
}

-(IBAction)editButtonPressed:(id)sender
{
    [self.table setEditing:!self.table.editing animated:YES];
}


#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == GGCreateNotificationTableSectionTextFields) {
        return 3;
    } else if(section == GGCreateNotificationTableSectionCreateButton) {
        return 1;
    } else if(section == GGCreateNotificationTableSectionList) {
        NSUInteger count = self.notifications.count;
        if (count > 0) {
            return count;
        }
        return 1;
    }
    return 0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == GGCreateNotificationTableSectionTextFields) {
        return @"New Notification";
    }else if (section == GGCreateNotificationTableSectionList) {
        return @"Saved Notifications";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == GGCreateNotificationTableSectionTextFields) {
        return @"If Alert ID added, pressing the notification at the top of the screen will move the map to the corresponding alert with the same Alert ID";
    }
    return nil;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GGCreateNotificationTableSectionTextFields) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"textFieldCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textFieldCell"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row == 0) {
            
            self.alertText.frame = CGRectInset(cell.contentView.frame, 20, 0);
            [cell.contentView addSubview:self.alertText];
            
        }else if (indexPath.row == 1) {

            self.alertID.frame = CGRectInset(cell.contentView.frame, 20, 0);
            [cell.contentView addSubview:self.alertID];

        }else if (indexPath.row == 2) {
            
            cell.textLabel.text = @"Notification stays until closed by user";
            cell.accessoryView = self.stickySwitch;
        }
        
        return cell;

    }else if (indexPath.section == GGCreateNotificationTableSectionCreateButton) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"createCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"createCell"];
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"Create Notification";
        
        return cell;

    }else if (indexPath.section == GGCreateNotificationTableSectionList) {

        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notificationCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"notificationCell"];
        }
        
        if (self.notifications.count > 0) {
            GGNotification *notification = [self.notifications objectAtIndex:indexPath.row];
            cell.textLabel.text = notification.alertText;
            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ (%@)",notification.alertID,notification.sticky ? @"stays until closed" : @"hides automatically"];
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        }else{
            cell.textLabel.text = @"0 saved notifications";
            cell.detailTextLabel.text = nil;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }


        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    return cell;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GGCreateNotificationTableSectionTextFields) {
        
    }else if (indexPath.section == GGCreateNotificationTableSectionCreateButton) {
        
        NSString *alertText = self.alertText.text;
        NSString *alertID = self.alertID.text;
        BOOL sticky = self.stickySwitch.on;
        
        GGNotification *notification = [[GGNotification alloc] initWithAlertID:alertID text:alertText sticky:sticky];
        [self addNotification:notification];
        
        [self.table deselectRowAtIndexPath:indexPath animated:YES];
        
    }else if (indexPath.section == GGCreateNotificationTableSectionList) {
        
        if (self.notifications.count > 0) {
            GGNotification *notification = [self.notifications objectAtIndex:indexPath.row];
            if (self.delegate && [self.delegate respondsToSelector:@selector(createNotification:didCreateNotification:)]) {
                [self.delegate createNotification:self didCreateNotification:notification];
            }
        }
    }
}


-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GGCreateNotificationTableSectionList) {
        return YES;
    }
    return NO;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GGCreateNotificationTableSectionList) {
        GGNotification *notification = [self.notifications objectAtIndex:indexPath.row];
        [self removeNotification:notification];
    }
}

#pragma mark -

-(void)addNotification:(GGNotification *)notification
{
    [self.notifications addObject:notification];
    [self saveNotifications];
    
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:GGCreateNotificationTableSectionList] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)removeNotification:(GGNotification *)notification
{
    NSUInteger index = [self.notifications indexOfObject:notification];
    [self.notifications removeObject:notification];

    if (self.notifications.count > 0) {
        [self.table deleteRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:index inSection:GGCreateNotificationTableSectionList]] withRowAnimation:UITableViewRowAnimationMiddle];
    }else{
        [self.table reloadSections:[NSIndexSet indexSetWithIndex:GGCreateNotificationTableSectionList] withRowAnimation:UITableViewRowAnimationAutomatic];
        self.table.editing = NO;
    }
    
    [self saveNotifications];
}

-(void)loadSavedNotifications
{
    NSMutableArray *notifications = [[NSMutableArray alloc] init];
    NSString *savedNotificationsPlistPath = [self savedNotificationsPlistPath];
    NSArray *savedNotifications = [NSArray arrayWithContentsOfFile:savedNotificationsPlistPath];
    if (savedNotifications) {
        for (NSDictionary *savedNotification in savedNotifications) {
            NSString *alertID = [savedNotification valueForKey:@"alertID"];
            NSString *alertText = [savedNotification valueForKey:@"alertText"];
            NSNumber *sticky = [savedNotification valueForKey:@"sticky"];
            GGNotification *notification = [[GGNotification alloc] initWithAlertID:alertID text:alertText sticky:[sticky boolValue]];
            [notifications addObject:notification];
        }
    }
    self.notifications = notifications;
}


-(void)saveNotifications
{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (GGNotification *notification in self.notifications) {
        [array addObject:[notification dictionaryRepresentation]];
    }
    
    if ([array writeToFile:[self savedNotificationsPlistPath] atomically:YES]) {
        XLog(@"written");
    }else{
        XLog(@"NOT written");
    }
}

-(NSString *)savedNotificationsPlistPath
{
    NSString *tempFolder = NSTemporaryDirectory();
    NSString *savedNotificationsPlistPath = [tempFolder stringByAppendingPathComponent:@"notifications.plist"];
    return savedNotificationsPlistPath;
}

#pragma mark -

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self loadSavedNotifications];
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:GGCreateNotificationTableSectionList] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = @"Simulate Notifications";
    
    self.notifications = [[NSMutableArray alloc] init];
    
    self.alertText = [[UITextField alloc] init];
    self.alertText.placeholder = @"Alert Text";
    
    self.alertID = [[UITextField alloc] init];
    self.alertID.placeholder = @"Alert ID (optional)";
    
    self.stickySwitch = [[UISwitch alloc] init];
    self.stickySwitch.on = NO;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonPressed:)];
    [self.navigationItem setRightBarButtonItem:editButton];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
