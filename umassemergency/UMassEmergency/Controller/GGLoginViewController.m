//
//  GGLoginViewController.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 20.03.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//

#import "GGLoginViewController.h"
#import "GGApp.h"
#import "GGGNSManager.h"
#import <MessageUI/MessageUI.h>

#define trackingScreenName @"Login Screen"

@interface GGLoginViewController () <UITextFieldDelegate, MFMailComposeViewControllerDelegate, GGAppInternetConnectionDelegate>

@property (nonatomic, strong) GGApp *app;

@property (nonatomic, strong) UIBarButtonItem *loginBarButton;
@property (nonatomic, strong) UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (nonatomic, readwrite) BOOL loginSuccessful;
@property (nonatomic, readwrite) NSInteger loginTimeouts;

@end

@implementation GGLoginViewController


#pragma mark - IBAction

-(IBAction)loginButtonPressed:(id)sender
{
    [self login];
}

-(void)login
{
    if (!self.app.internetConnectionAvailable) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Internet required" message:@"You seem to be not connected to the internet. Please make sure you are connected, then try again. Thanks" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    
    [self.activityIndicator startAnimating];
    
    self.loginButton.enabled = NO;
    self.loginBarButton.enabled = NO;
    self.emailTextField.enabled = NO;
    
    NSString *email = self.emailTextField.text;
    
    if (self.loginSuccessful) {
        self.loginButton.enabled = YES;
        self.loginBarButton.enabled = YES;
        self.emailTextField.enabled = YES;
        [self loginSuccessful:email];
        return;
    }
    
    self.app.user.gnsUsername = [email lowercaseString];
    self.app.user.gnsPassword = [email lowercaseString];
    
    GGGNSManager *gns = [GGGNSManager manager];
    gns.username = self.app.user.gnsUsername;
    gns.password = self.app.user.gnsPassword;
    
    [gns disconnectGNS];
    [gns loadGNSAccountWithCompletion:^(NSString *error) {
        
        self.loginButton.enabled = YES;
        self.loginBarButton.enabled = YES;
        self.emailTextField.enabled = YES;
        
        if (error != nil && ![error isEqualToString:@""]) {
            // error
            
            [self.activityIndicator stopAnimating];
            
            self.loginSuccessful = NO;
            
            NSString *errorMessage = @"";
            if ([[error lowercaseString] localizedCaseInsensitiveContainsString:@"timeout"]) {
                
                // Timeout
                self.loginTimeouts++;
                if (self.loginTimeouts<3) {
                    // lets try again
                    [self performSelectorOnMainThread:@selector(login) withObject:nil waitUntilDone:NO];
                    return;
                }else{
                    self.loginTimeouts = 0;
                }
                errorMessage = @"Unable to connect to the server. Please verify that you have internet access and try again.";
                
            }else if ([[error lowercaseString] localizedCaseInsensitiveContainsString:@"private key not available on this device"]){
                
                errorMessage = @"Email address already used on another Device. Please try with a different email address.";
                
            }else if ([[error lowercaseString] localizedCaseInsensitiveContainsString:@"duplicate_error"]){
                
                errorMessage = @"Email address already used on another Device. Please try with a different email address.";
                
            }else if ([[error lowercaseString] localizedCaseInsensitiveContainsString:@"already_loading_account"]){
                return;
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];
            
        }else{
            
            [self.activityIndicator stopAnimating];
            [self.emailTextField resignFirstResponder];
            
            self.loginSuccessful = YES;
            [self loginSuccessful:email];
        }
    }];
}


-(void)loginSuccessful:(NSString *)email
{
    [self.activityIndicator stopAnimating];

    if (self.delegate && [self.delegate respondsToSelector:@selector(login:didLoginEmail:)]) {
        [self.delegate login:self didLoginEmail:email];
    }

//    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Connection Error" message:@"There was an error connecting to the server. Please try again." preferredStyle:UIAlertControllerStyleAlert];
//    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
//    UIAlertAction *retry = [UIAlertAction actionWithTitle:@"Retry" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//        [self loginSuccessful:email];
//    }];
//    [alert addAction:cancel];
//    [alert addAction:retry];
//    [self presentViewController:alert animated:YES completion:nil];
}


#pragma mark -

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL validEmail = [self validateEmailWithString:[self.emailTextField.text lowercaseString]];
    
    if (validEmail) {
        [self login];
    }
    
    return YES;
}


-(IBAction)textFieldEditingChanged:(UITextField *)theTextField
{
    [self checkLoginButton];
}


- (BOOL)validateEmailWithString:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}


-(void)checkLoginButton
{
    BOOL validEmail = [self validateEmailWithString:self.emailTextField.text];
    if (validEmail) {
        [self.emailTextField setReturnKeyType:UIReturnKeyGo];
        self.loginBarButton.enabled = YES;
    }else{
        [self.emailTextField setReturnKeyType:UIReturnKeyDefault];
        self.loginBarButton.enabled = NO;
    }
    
}


#pragma mark - Cancel Button

-(void)setCancelAllowed:(BOOL)cancelAllowed
{
    _cancelAllowed = cancelAllowed;
    [self checkCancelButton];
}

-(void)checkCancelButton
{
    if (self.cancelAllowed) {
        self.cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonPressed:)];
        self.navigationItem.leftBarButtonItem = self.loginBarButton;
    }else{
        self.navigationItem.leftBarButtonItem = nil;
    }
}


#pragma mark - Internet Connection

-(void)app:(GGApp *)app didChangeInternetConnectionStatus:(AFNetworkReachabilityStatus)status
{
    if (app.internetConnectionAvailable) {
        // internet connection available
        
    }else{
        // no internet connection available
        
    }
}


#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.emailTextField becomeFirstResponder];
    
    [self.app addInternetConnectionDelegate:self];
    
    [GGConstants sendTrackingScreenName:trackingScreenName];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.loginTimeouts = 0;
    self.loginSuccessful = NO;
    
    self.app = [GGApp instance];
    
    NSString *title = @"Please enter your email address here to register.\n";
    
    self.titleLabel.text = title;
    
    self.loginBarButton = [[UIBarButtonItem alloc] initWithTitle:@"Login" style:UIBarButtonItemStyleDone target:self action:@selector(loginButtonPressed:)];
    self.loginBarButton.enabled = NO;
    self.navigationItem.rightBarButtonItem = self.loginBarButton;
    
    self.emailTextField.delegate = self;
    
    [self checkCancelButton];
    
    if (self.email) {
        // user already has a username
        self.emailTextField.text = self.email;
        
        [self checkLoginButton];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.app removeInternetConnectionDelegate:self];
}

- (BOOL)shouldAutorotate {
    return NO;
}

-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
