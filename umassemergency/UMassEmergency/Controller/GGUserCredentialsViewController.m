//
//  GGUserCredentialsViewController.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 07.06.15.
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

#import "GGUserCredentialsViewController.h"

typedef enum : NSUInteger {
    TableCellEmail,
    TableCellPassword,
    TableCellPassword2,
} TableCell;

@interface GGUserCredentialsViewController ()

@property (nonatomic, readwrite) BOOL credentialsComplete;

@property (nonatomic, strong) GGApp *app;

@property (nonatomic, strong) UITextField *emailTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (nonatomic, strong) UITextField *password2TextField;

@end

@implementation GGUserCredentialsViewController

-(IBAction)createButtonPressed:(id)sender
{
    [self createAccount];
}

-(IBAction)cancelButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(userCredentialsDidCancel:)]) {
        [self.delegate userCredentialsDidCancel:self];
    }
}

#pragma mark - Table

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 3;
    }else if (section == 1) {
        return 1;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    
    
    if (indexPath.section == 0) {

        cell.selectionStyle = UITableViewCellSelectionStyleNone;

        if (indexPath.row == TableCellEmail) {
//            cell.textLabel.text = @"Email";

//            self.emailTextField.frame = CGRectMake(cell.textLabel.frame.size.width, 0, cell.contentView.frame.size.width-cell.textLabel.frame.size.width, cell.contentView.frame.size.height);
            self.emailTextField.frame = cell.contentView.frame;
            XLog(@"Email frame: %@",NSStringFromCGRect(self.emailTextField.frame));
            [cell.contentView addSubview:self.emailTextField];
            
        }else if (indexPath.row == TableCellPassword) {

//            cell.textLabel.text = @"Password";

//            self.passwordTextField.frame = CGRectMake(cell.textLabel.frame.size.width, 0, cell.contentView.frame.size.width-cell.textLabel.frame.size.width, cell.contentView.frame.size.height);
            self.passwordTextField.frame = cell.contentView.frame;
            XLog(@"Password frame: %@",NSStringFromCGRect(self.passwordTextField.frame));
            [cell.contentView addSubview:self.passwordTextField];

        }else if (indexPath.row == TableCellPassword2) {

//            cell.textLabel.text = @"Confirm Password";

//            self.password2TextField.frame = CGRectMake(cell.textLabel.frame.size.width, 0, cell.contentView.frame.size.width-cell.textLabel.frame.size.width, cell.contentView.frame.size.height);
            self.password2TextField.frame = cell.contentView.frame;
            XLog(@"Password2 frame: %@",NSStringFromCGRect(self.password2TextField.frame));
            [cell.contentView addSubview:self.password2TextField];

        }
        
    } else if(indexPath.section == 1) {
        
        if (self.credentialsComplete) {
            cell.textLabel.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        }else{
            cell.textLabel.textColor = [UIColor grayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
        
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"Create Account";
    }
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        
        if (self.credentialsComplete) {
            [self createAccount];
        }
        
    }
}


-(void)createAccount
{
    NSString *email = self.emailTextField.text;
    NSString *password = self.passwordTextField.text;

    if (self.delegate && [self.delegate respondsToSelector:@selector(userCredentials:didCreateAccount:password:)]) {
        [self.delegate userCredentials:self didCreateAccount:email password:password];
    }
}


-(void)checkTextFields
{
    self.credentialsComplete = NO;

    if (![self.emailTextField.text isEqualToString:@""] && ![self.passwordTextField.text isEqualToString:@""] && ![self.password2TextField.text isEqualToString:@""]) {
        
        NSString *password = self.passwordTextField.text;
        NSString *password2 = self.password2TextField.text;
        
        if ([password isEqualToString:password2]) {
            self.credentialsComplete = YES;
        }
    }
    
//    [self.table reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
}


#pragma mark - text field delegate

-(void)textFieldValueChanged:(UITextField *)textField
{
    [self checkTextFields];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.table scrollRectToVisible:textField.frame animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}



#pragma mark - scroll view

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.emailTextField resignFirstResponder];
    [self.passwordTextField resignFirstResponder];
    [self.password2TextField resignFirstResponder];
}


#pragma mark -


-(void)setCredentialsComplete:(BOOL)credentialsComplete
{
    _credentialsComplete = credentialsComplete;
    self.navigationItem.rightBarButtonItem.enabled = credentialsComplete;
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.credentialsComplete = NO;
    
    self.title = @"Account Creation";

    self.app = [GGApp instance];
    
    self.emailTextField = [[UITextField alloc] init];
    self.emailTextField.placeholder = @"Enter your email address";
    self.emailTextField.delegate = self;
    UIView *paddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.emailTextField.leftView = paddingView;
    self.emailTextField.leftViewMode = UITextFieldViewModeAlways;
    self.emailTextField.secureTextEntry = NO;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.returnKeyType = UIReturnKeyDone;
    self.emailTextField.adjustsFontSizeToFitWidth = YES;
    
    self.passwordTextField = [[UITextField alloc] init];
    self.passwordTextField.placeholder = @"Enter a password";
    self.passwordTextField.delegate = self;
    UIView *paddingView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.passwordTextField.leftView = paddingView2;
    self.passwordTextField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.passwordTextField.returnKeyType = UIReturnKeyDone;
    self.passwordTextField.adjustsFontSizeToFitWidth = YES;
    
    self.password2TextField = [[UITextField alloc] init];
    self.password2TextField.placeholder = @"Confirm password";
    self.password2TextField.delegate = self;
    UIView *paddingView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 20)];
    self.password2TextField.leftView = paddingView3;
    self.password2TextField.leftViewMode = UITextFieldViewModeAlways;
    self.password2TextField.secureTextEntry = YES;
    self.password2TextField.autocorrectionType = UITextAutocorrectionTypeNo;
    self.password2TextField.returnKeyType = UIReturnKeyDone;
    self.password2TextField.adjustsFontSizeToFitWidth = YES;

    [self.emailTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.passwordTextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.password2TextField addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    UIBarButtonItem *createButton = [[UIBarButtonItem alloc] initWithTitle:@"Create" style:UIBarButtonItemStyleDone target:self action:@selector(createButtonPressed:)];
    createButton.enabled = NO;
    [self.navigationItem setRightBarButtonItem:createButton];
    
    NSString *username = self.app.user.gnsUsername;
    NSString *password = self.app.user.gnsPassword;
    
    if (username && password) {
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
        [self.navigationItem setLeftBarButtonItem:cancelButton];
    }
    
    self.emailTextField.text = username;
    self.passwordTextField.text = password;
    self.password2TextField.text = password;
    
}



@end
