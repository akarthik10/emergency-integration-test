//
//  GGGNSStatusViewController.m
//  WindContours
//
//  Created by Görkem Güclü on 15.05.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "GGGNSStatusViewController.h"
#import "GGApp.h"
#import "GGGNSManager.h"
#import "GGUserCredentialsViewController.h"
#import "GGGNSDataViewController.h"
#import "NSString+GGJSONObject.h"

#define tableContentOffsetAddition 350.0
#define trackingScreenName @"GNS Status Screen"

typedef enum : NSUInteger {
    GNSStatusTableSectionGNSGUID = 0,
    GNSStatusTableSectionGNSData = 1,
    GNSStatusTableSectionGNSReload = 2,
    GNSStatusTableSectionGNSCredentials = 3,
    GNSStatusTableSectionGNSServer = 4,
    GNSStatusTableSectionGNSPort = 5,
    AboutTableSectionBackend = 6,
} GNSStatusTableSection;

@interface GGGNSStatusViewController () <UITextFieldDelegate, GGUserCredentialsDelegate>

@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) GGApp *app;

@property (nonatomic, readwrite) BOOL loadingGNSData;
@property (nonatomic, strong) NSString *gnsData;
@property (nonatomic, strong) UITextField *gnsHostTextField;
@property (nonatomic, strong) UITextField *gnsPortTextField;
@property (nonatomic, strong) UIButton *gnsPortDoneButton;

@property (nonatomic, strong) UITextField *backendHostTextField;

@end

@implementation GGGNSStatusViewController

#pragma mark - IBAction

-(IBAction)gnsDoneButtonPressed:(id)sender
{
    self.table.contentSize = CGSizeMake(self.table.contentSize.width, self.table.contentSize.height-tableContentOffsetAddition);
    
    [self.gnsPortTextField resignFirstResponder];
    [self saveGNSPortAddress:self.gnsPortTextField.text];
}


#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 7;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == GNSStatusTableSectionGNSData) {
        // GNS information
        NSDictionary *data = [self.gnsData jsonObject];
        if ([data isKindOfClass:[NSDictionary class]] && data.allKeys.count > 0) {
            return 2;
        }
        return 1;
    }else if (section == GNSStatusTableSectionGNSReload) {
        // reload gns info
        return 1;
    }else if (section == GNSStatusTableSectionGNSGUID) {
        // GNS GUID & connection status & username
        return 3;
    }else if (section == GNSStatusTableSectionGNSCredentials) {
        // GNS Credentials
        return 1;
    }else if (section == GNSStatusTableSectionGNSServer) {
        return 1;
    }else if (section == GNSStatusTableSectionGNSPort) {
        return 1;
    }else if (section == AboutTableSectionBackend) {
        return 1;
    }
    return 0;
}


-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == GNSStatusTableSectionGNSServer) {
        return @"GNS Host";
    } else if(section == GNSStatusTableSectionGNSPort) {
        return @"GNS Port";
    } else if(section == AboutTableSectionBackend) {
        return @"Backend";
    }
    return nil;
}

-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == GNSStatusTableSectionGNSGUID) {
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
    
    if(indexPath.section == GNSStatusTableSectionGNSData) {
        
        if (indexPath.row == 0) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.textLabel.text = self.gnsData;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.font = [UIFont systemFontOfSize:11];
            
        }else if (indexPath.row == 1) {
            
            cell.selectionStyle = UITableViewCellSelectionStyleDefault;
            cell.textLabel.text = @"Details";
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
            cell.textLabel.numberOfLines = 0;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
        }
        
    } else if(indexPath.section == GNSStatusTableSectionGNSReload) {
        
        cell.textLabel.text = @"Reload GNS Data";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
    } else if(indexPath.section == GNSStatusTableSectionGNSGUID) {
        
        if (indexPath.row == 0) {
            NSString *username = self.app.user.gnsUsername;
            if (username) {
                cell.textLabel.text = username;
            }else{
                cell.textLabel.text = @"Username not available";
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.numberOfLines = 1;
            
        }else if (indexPath.row == 1) {
            GGGNSManager *gns = [GGGNSManager manager];
            NSString *guid = gns.guid;
            if (guid) {
                cell.textLabel.text = guid;
            }else{
                cell.textLabel.text = @"GUID not available";
            }
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.numberOfLines = 1;
            
        }else if (indexPath.row == 2) {
            
            GGGNSManager *gns = [GGGNSManager manager];
            cell.textLabel.text = gns.connected ? @"GNS Connected" : @"GNS not connected";
            cell.textLabel.textAlignment = NSTextAlignmentCenter;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            cell.textLabel.numberOfLines = 1;
            if (gns.connected) {
                cell.textLabel.textColor = [UIColor greenColor];
            }else{
                cell.textLabel.textColor = [UIColor redColor];
            }
        }
        
    } else if(indexPath.section == GNSStatusTableSectionGNSCredentials) {
        
        cell.textLabel.text = @"Enter GNS Credentials";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        
    } else if(indexPath.section == GNSStatusTableSectionGNSServer) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gnsServer"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gnsServer"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.gnsHostTextField.frame = CGRectInset(cell.contentView.bounds, 50, 0);
        [cell.contentView addSubview:self.gnsHostTextField];
        return cell;
        
    } else if(indexPath.section == GNSStatusTableSectionGNSPort) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"gnsPort"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"gnsPort"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        self.gnsPortTextField.frame = CGRectInset(cell.contentView.bounds, 50, 0);
        self.gnsPortDoneButton.frame = CGRectMake(0, 0, 70, cell.contentView.bounds.size.height);
        cell.accessoryView = self.gnsPortDoneButton;
        [cell.contentView addSubview:self.gnsPortTextField];
        return cell;

    } else if(indexPath.section == AboutTableSectionBackend) {
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"backendCells"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"backendCells"];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
        
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"backendURL"];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"backendURL"];
            }
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.backendHostTextField.frame = CGRectInset(cell.contentView.bounds, 50, 0);
            [cell.contentView addSubview:self.backendHostTextField];
            return cell;
        }
        return cell;

    }
    
    return cell;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == GNSStatusTableSectionGNSData) {
        
        if (indexPath.row == 1) {
            
            NSDictionary *data = [self.gnsData jsonObject];
            if (![data isKindOfClass:[NSDictionary class]]) {
                data = [NSDictionary dictionaryWithObject:data forKey:@"overview"];
            }
            
            GGGNSDataViewController *gnsDataVC = [[GGGNSDataViewController alloc] initWithNibName:@"GGGNSDataViewController" bundle:nil];
            gnsDataVC.key = @"Details";
            gnsDataVC.data = data;
            [self.navigationController pushViewController:gnsDataVC animated:YES];
        }
        
    }else if (indexPath.section == GNSStatusTableSectionGNSReload) {
        
        [self reloadGNSData];
        
    }else if (indexPath.section == GNSStatusTableSectionGNSGUID) {
        
        if (indexPath.row == 0) {
            NSString *username = self.app.user.gnsUsername;
            if (username) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = username;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Username copied!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
        }else if (indexPath.row == 1) {
            GGGNSManager *gns = [GGGNSManager manager];
            NSString *guid = gns.guid;
            if (guid) {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                pasteboard.string = guid;
            }
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GUID copied!" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    }else if (indexPath.section == GNSStatusTableSectionGNSCredentials) {
        
        [self presentGNSCredentialsViewController];
        
    }
}


#pragma mark -

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.table.contentSize = CGSizeMake(self.table.contentSize.width, self.table.contentSize.height+tableContentOffsetAddition);

    NSIndexPath *indexPath;
    if ([textField isEqual:self.gnsHostTextField]) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:GNSStatusTableSectionGNSServer];
    }else if ([textField isEqual:self.gnsPortTextField]) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:GNSStatusTableSectionGNSPort];
    }else if ([textField isEqual:self.backendHostTextField]) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:AboutTableSectionBackend];
    }
    if (indexPath) {
        CGRect frame = [self.table rectForRowAtIndexPath:indexPath];
        [self.table setContentOffset:CGPointMake(0, frame.origin.y-100) animated:YES];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    self.table.contentSize = CGSizeMake(self.table.contentSize.width, self.table.contentSize.height-tableContentOffsetAddition);

    [textField resignFirstResponder];
    
    if ([textField isEqual:self.gnsHostTextField]) {
        [self saveGNSHostAddress:self.gnsHostTextField.text];
    }else if ([textField isEqual:self.gnsPortTextField]) {
        [self saveGNSPortAddress:self.gnsPortTextField.text];
    }else if ([textField isEqual:self.backendHostTextField]) {
        [self saveBackendHostAddress:self.backendHostTextField.text];
    }
    
    return YES;
}


-(void)saveGNSHostAddress:(NSString *)host
{
    if ([host isEqualToString:@""]) {
        [GGConstants setGNSHost:[GGConstants gnsDefaultHost]];
        self.gnsHostTextField.text = [GGConstants gnsDefaultHost];
    }else{
        [GGConstants setGNSHost:host];
        self.gnsHostTextField.text = host;
    }
    
    GGGNSManager *gns = [GGGNSManager manager];
    [gns disconnectGNS];
    [gns createGNSConntectionWithCompletion:nil];
}

-(void)saveGNSPortAddress:(NSString *)port
{
    if ([port isEqualToString:@""]) {
        [GGConstants setGNSPort:[GGConstants gnsDefaultPort]];
        self.gnsPortTextField.text = [NSString stringWithFormat:@"%li",(long)[GGConstants gnsDefaultPort]];
    }else{
        [GGConstants setGNSPort:[port integerValue]];
        self.gnsPortTextField.text = port;
    }
    
    GGGNSManager *gns = [GGGNSManager manager];
    [gns disconnectGNS];
    [gns createGNSConntectionWithCompletion:nil];
}

-(void)saveBackendHostAddress:(NSString *)host
{
    if ([host isEqualToString:@""]) {
        [GGConstants setBackendURL:[GGConstants backendDefaultHost]];
        self.backendHostTextField.text = [GGConstants backendDefaultHost];
    }else{
        [GGConstants setBackendURL:host];
        self.backendHostTextField.text = host;
    }
}

#pragma mark - GNS Credentials

-(void)presentGNSCredentialsViewController
{
    GGUserCredentialsViewController *userCredentialsVC = [[GGUserCredentialsViewController alloc] initWithNibName:@"GGUserCredentialsViewController" bundle:nil];
    userCredentialsVC.delegate = self;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:userCredentialsVC];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

-(void)userCredentials:(GGUserCredentialsViewController *)controller didCreateAccount:(NSString *)username password:(NSString *)password
{
    [self dismissViewControllerAnimated:YES completion:nil];
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

-(void)userCredentialsDidCancel:(GGUserCredentialsViewController *)controller
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - GNS Data

-(void)reloadGNSData
{
    if (![GGConstants inDeveloperMode]) {
        return;
    }
    
    self.loadingGNSData = YES;
    self.gnsData = @"loading...";
    [self reloadTableSection:GNSStatusTableSectionGNSData];
    [self reloadTableSection:GNSStatusTableSectionGNSGUID];
    [self.table deselectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:GNSStatusTableSectionGNSReload] animated:YES];
    
    GGGNSManager *gns = [GGGNSManager manager];
    [gns loadGNSAccountWithCompletion:^(NSString *error) {
        
        if (error) {
            
            self.gnsData = [NSString stringWithFormat:@"Error: %@",error];
            self.loadingGNSData = NO;
            //            [self.table reloadSections:indexSet withRowAnimation:UITableViewRowAnimationFade];
            [self reloadTableSection:GNSStatusTableSectionGNSData];
            [self reloadTableSection:GNSStatusTableSectionGNSGUID];
            XLog(@"Error loading GNS account: %@",error);
            
        }else{
            
            [gns readAllFieldsWithCompletion:^(NSString *json, NSString *error) {
                
                if (error) {
                    
                    self.gnsData = [NSString stringWithFormat:@"Error: %@",error];
                    
                    self.loadingGNSData = NO;
                    XLog(@"Reading GNS Data failed: %@",error);
                    [self reloadTableSection:GNSStatusTableSectionGNSData];
                    [self reloadTableSection:GNSStatusTableSectionGNSGUID];
                    
                }else{
                    self.gnsData = json;
                    
                    self.loadingGNSData = NO;
                    XLog(@"GNS Data loaded");
                    [self reloadTableSection:GNSStatusTableSectionGNSData];
                    [self reloadTableSection:GNSStatusTableSectionGNSGUID];
                }
                
            }];
        }
        
    }];
}


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
    
    [self reloadGNSData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

    self.title = @"GNS Status";

    self.app = [GGApp instance];
    
    self.gnsData = @"";
    self.loadingGNSData = NO;
    
    self.table.estimatedRowHeight = 44.0;
    self.table.rowHeight = UITableViewAutomaticDimension;

    self.gnsHostTextField = [[UITextField alloc] init];
    self.gnsHostTextField.text = [GGConstants gnsHost];
    self.gnsHostTextField.delegate = self;
    self.gnsHostTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.gnsHostTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.gnsHostTextField.placeholder = [GGConstants gnsDefaultHost];
    self.gnsHostTextField.returnKeyType = UIReturnKeyDone;
    
    self.gnsPortTextField = [[UITextField alloc] init];
    self.gnsPortTextField.text = [NSString stringWithFormat:@"%@",[NSNumber numberWithInteger:[GGConstants gnsPort]]];
    self.gnsPortTextField.delegate = self;
    self.gnsPortTextField.placeholder = [NSString stringWithFormat:@"%li",(long)[GGConstants gnsDefaultPort]];
    self.gnsPortTextField.keyboardType = UIKeyboardTypeNumberPad;
    self.gnsPortTextField.returnKeyType = UIReturnKeyDone;
    
    self.gnsPortDoneButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.gnsPortDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [self.gnsPortDoneButton addTarget:self action:@selector(gnsDoneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];

    self.backendHostTextField = [[UITextField alloc] init];
    self.backendHostTextField.text = [GGConstants backendURL];
    self.backendHostTextField.delegate = self;
    self.backendHostTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.backendHostTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.backendHostTextField.placeholder = [GGConstants backendURL];
    self.backendHostTextField.returnKeyType = UIReturnKeyDone;
}


@end
