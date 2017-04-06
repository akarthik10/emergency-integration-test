//
//  AppDelegate.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 01.03.15.
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

#import "AppDelegate.h"
#import "GGHazardNotification.h"
#import "GGGNSManager.h"
#import "GGDeveloperStatusBar.h"

@interface AppDelegate ()

@property (strong, nonatomic) GGApp *app;
@property (nonatomic, strong) ViewController *mapViewController;
@property (nonatomic, strong) NSMutableArray *notificationViews;
@property (nonatomic, readwrite) BOOL isShowingNotification;
@property (nonatomic, strong) GGDeveloperStatusBar *statusOverlay;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    XLog(@"");
    application.applicationIconBadgeNumber = 0;

    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.tintColor = [UIColor umassMaroonColor];

    self.notificationViews = [[NSMutableArray alloc] init];
    self.isShowingNotification = NO;
    self.app = [GGApp instance];
    self.app.deviceToken = [[NSUserDefaults standardUserDefaults] valueForKey:@"appDeviceToken"];
    
    [UINavigationBar appearance].barTintColor = [UIColor umassMaroonColor];
    [UINavigationBar appearance].barStyle = UIBarStyleBlackTranslucent;
    [UINavigationBar appearance].tintColor = [UIColor whiteColor];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    self.mapViewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    self.mapViewController.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"UMass Emergency" image:[UIImage imageNamed:@"cloud_warning"] selectedImage:[UIImage imageNamed:@"cloud_warning_full"]];
    UINavigationController *mapNavi = [[UINavigationController alloc] initWithRootViewController:self.mapViewController];
    
    self.window.rootViewController = mapNavi;
    
    // Configure tracker from GoogleService-Info.plist.
    NSError *configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    
    // Optional: configure GAI options.
    GAI *gai = [GAI sharedInstance];
    gai.dryRun = YES;
//    gai.trackUncaughtExceptions = YES;  // report uncaught exceptions
//    gai.dispatchInterval = 20;
//    gai.logger.logLevel = kGAILogLevelNone;  // remove before app release
//    gai.logger.logLevel = kGAILogLevelVerbose;  // remove before app release

    [self.window makeKeyAndVisible];
    
    self.statusOverlay = [[GGDeveloperStatusBar alloc] initWithFrame:application.statusBarFrame];
    self.statusOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.statusOverlay.windowLevel = UIWindowLevelStatusBar+1;
    self.statusOverlay.rootViewController = [UIViewController new];
    //    self.statusOverlay.backgroundColor = [UIColor blueColor];
    self.statusOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    [self hideCustomStatusBarAnimated:NO];
    
    [self.statusOverlay makeKeyAndVisible];
    [self.window makeKeyAndVisible];
    
    [self.window addObserver:self forKeyPath:@"frame" options:0 context:0];

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

//    [self testNotifictions];

    // check push notifications status
    BOOL remoteNotificationsEnabled = false, noneEnabled,alertsEnabled, badgesEnabled, soundsEnabled;
    remoteNotificationsEnabled = [UIApplication sharedApplication].isRegisteredForRemoteNotifications;
    
    UIUserNotificationSettings *userNotificationSettings = [UIApplication sharedApplication].currentUserNotificationSettings;
    
    noneEnabled = userNotificationSettings.types == UIUserNotificationTypeNone;
    alertsEnabled = userNotificationSettings.types & UIUserNotificationTypeAlert;
    badgesEnabled = userNotificationSettings.types & UIUserNotificationTypeBadge;
    soundsEnabled = userNotificationSettings.types & UIUserNotificationTypeSound;
    
    UILocalNotification *notificationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (notificationInfo) {
        XLog(@"app recieved notification from remote%@",notificationInfo);
        
        NSDictionary *userInfo = (NSDictionary *)notificationInfo;
        [self presentRemoteNotification:userInfo];

    }else{
        XLog(@"app did not recieve notification");
    }

    UILocalNotification *locationInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsLocationKey];
    if (locationInfo) {
        // app started because of location update
        CLLocationManager *locationManager = [[CLLocationManager alloc] init];
        CLLocation *location = locationManager.location;
        if ([GGConstants isLocationSimulated]) {
            location = [GGConstants simulatedLocation];
        }
        [[GGApp instance] updateLocationInBackground:location withCompletion:^(BOOL successful) {
            
            if (successful && [GGConstants receiveNotificationWhenLocationUpdated]) {
                NSDate *date = [NSDate dateWithTimeIntervalSinceNow:2];
                NSString *alertBody = [NSString stringWithFormat:@"%@ location update: %.3f,%.3f (%@)",successful ? @"Successful" : @"Failed", locationManager.location.coordinate.latitude,locationManager.location.coordinate.longitude,[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
                
                if ([GGConstants isLocationSimulated]) {
                    alertBody = [alertBody stringByAppendingFormat:@" (Overwritten by simulated location)"];
                }
                
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = date;
                localNotification.alertBody = alertBody;
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                localNotification.applicationIconBadgeNumber = 1;
                [application scheduleLocalNotification:localNotification];
            }
        }];
    }
    
    [self updateDeveloperStatus];

    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    self.app = [GGApp instance];
    [self.app stopTimer];
    GGGNSManager *gns = [GGGNSManager manager];
    [gns disconnectGNS];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.

    self.app = [GGApp instance];
    [self.app.locationManager stopUpdatingLocation];
    [self.app.locationManager startMonitoringSignificantLocationChanges];
    [self.app stopTimer];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    GGGNSManager *gns = [GGGNSManager manager];
    [gns disconnectGNS];
    self.app = [GGApp instance];
    [self.app startTimer];
    [self.app.locationManager startMonitoringSignificantLocationChanges];
    [self.app.locationManager startUpdatingLocation];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    if (self.statusOverlay.hidden) {
        [self hideCustomStatusBarAnimated:NO];
    }else{
        [self showCustomStatusBarAnimated:NO];
    }
}

#pragma mark - Observe Key Value

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    
    if (object == self.window) {
        if (self.statusOverlay.hidden) {
            [self hideCustomStatusBarAnimated:NO];
        }else{
            [self showCustomStatusBarAnimated:NO];
        }
    }
}

#pragma mark - Notifications

-(GGHazard *)createHazardWithNotificationInfo:(NSDictionary *)info
{
    NSString *message = nil;
    NSDictionary *aps = [info objectForKey:@"aps"];
    NSString *alertID = [info objectForKey:@"casaAlertID"];
    NSDictionary *alertInfo = [info objectForKey:@"payload"];
    
    id alert = [aps objectForKey:@"alert"];
    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"body"];
    }
    
    GGHazard *hazard;
    if (alertInfo) {
        hazard = [GGHazard hazardWithDictionary:alertInfo];
        alertID = hazard.hazardID;
        //        if (![hazard isOlderThan12Hours]) {
        //            [self.app.dataManager addHazard:hazard];
        //        }
        [self.app.dataManager addHazard:hazard];
    }
    
    return hazard;
}

-(GGNotification *)notificationForNotificationInfo:(NSDictionary *)info
{
    NSString *message = nil;
    NSDictionary *aps = [info objectForKey:@"aps"];
    NSString *alertID = [info objectForKey:@"casaAlertID"];
    NSDictionary *alertInfo = [info objectForKey:@"casaJSONAlert"];
    
    id alert = [aps objectForKey:@"alert"];
    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"body"];
    }
    
    GGHazard *hazard;
    if (alertInfo) {
        hazard = [self createHazardWithNotificationInfo:info];
        if (hazard) {
            alertID = hazard.hazardID;
        }

        GGNotification *notificaiton = [[GGNotification alloc] initWithAlertID:alertID text:message sticky:NO];
        return notificaiton;

    }else if (alertID) {

        GGNotification *notificaiton = [[GGNotification alloc] initWithAlertID:alertID text:message sticky:NO];
        return notificaiton;

    }
    
    return nil;
}

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [self presentRemoteNotification:userInfo];
}

-(void)presentRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *aps = [userInfo objectForKey:@"aps"];
    NSString *message = @"";
    id alert = [aps objectForKey:@"alert"];
    if ([alert isKindOfClass:[NSString class]]) {
        message = alert;
    } else if ([alert isKindOfClass:[NSDictionary class]]) {
        message = [alert objectForKey:@"body"];
    }
    
    GGHazard *hazard;
    if (userInfo) {
        hazard = [self createHazardWithNotificationInfo:userInfo];
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Notification received" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleCancel handler:nil]];
    [self.window.rootViewController presentViewController:alertController animated:YES completion:nil];
    [self.app updateAlerts:YES];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    NSString *newToken = [deviceToken description];
    newToken = [newToken stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    newToken = [newToken stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    XLog(@"My token is: %@", newToken);
    
    [[NSUserDefaults standardUserDefaults] setValue:newToken forKey:@"appDeviceToken"];
    self.app.deviceToken = newToken;

    [self.app uploadDeviceTokenWithCompletion:nil];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    XLog(@"Failed to get token, error: %@", error);
}


#pragma mark - In-App Notifications

-(void)testNotifictions
{
    GGNotification *n1 = [[GGNotification alloc] initWithAlertID:@"20151222202000000" text:@"Notification 1 Notification 1 Notification 1 Notification 1 Notification 1 Notification 1 Notification 1" sticky:NO];
    GGNotification *n2 = [[GGNotification alloc] initWithAlertID:@"STORM_CASA_5_20140508-205806_45.00dBZ_2" text:@"Notification 2" sticky:NO];
    GGNotification *n3 = [[GGNotification alloc] initWithAlertID:@"AlertID" text:@"Notification 3" sticky:NO];
    GGNotification *n4 = [[GGNotification alloc] initWithAlertID:@"AlertID" text:@"Notification 4" sticky:NO];
    GGNotification *n5 = [[GGNotification alloc] initWithAlertID:@"AlertID" text:@"Notification 5" sticky:NO];
    [self createNotificationView:n1];
    [self createNotificationView:n2];
    [self createNotificationView:n3];
    [self createNotificationView:n4];
    [self createNotificationView:n5];
    
    [self showNextNotification];
}

-(void)createNotificationView:(GGNotification *)notification
{
    GGNotificationView *notificationView = [[GGNotificationView alloc] init];
    notificationView.userInteractionEnabled = YES;
    notificationView.notification = notification;
    notificationView.frame = CGRectMake(0, -110, self.window.frame.size.width, 110);
    notificationView.delegate = self;
    [self.notificationViews addObject:notificationView];
    [self showNextNotification];
}

-(void)showNextNotification
{
    XLog(@"Start Pending Notifications: %li",(long)self.notificationViews.count);
    if (!self.isShowingNotification && self.notificationViews.count > 0) {
        GGNotificationView *notificationView = [self.notificationViews objectAtIndex:0];

        [self.window addSubview:notificationView];
        [self.notificationViews removeObject:notificationView];
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        self.isShowingNotification = YES;
        [UIView animateWithDuration:0.8
                              delay:0.5
                            options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             
                             notificationView.frame = CGRectMake(0, 0, notificationView.frame.size.width, notificationView.frame.size.height);
                             
                         } completion:^(BOOL finished) {
                             
                             if (finished) {
                                 if (!notificationView.notification.sticky) {
                                     int64_t delayInSeconds = 6;
                                     dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                                     dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                                         [self hideNotification:notificationView];
                                     });
                                 }
                             }
                         }];
    }
}

-(void)notificationDidClose:(GGNotificationView *)view
{
    [view.layer removeAllAnimations];
    [self hideNotification:view afterDelay:0];
}

-(void)notificationDidGetPressed:(GGNotificationView *)view
{
    if (self.mapViewController.presentedViewController) {
        [self.mapViewController dismissViewControllerAnimated:YES completion:^{
            [self.mapViewController showHazardOnMapWithHazardID:view.notification.alertID animated:YES withCompletion:nil];
        }];
    }else{
        [self.mapViewController showHazardOnMapWithHazardID:view.notification.alertID animated:YES withCompletion:nil];
    }
}

-(void)hideNotification:(GGNotificationView *)notification
{
    [self hideNotification:notification afterDelay:0];
}

-(void)hideNotification:(GGNotificationView *)notification afterDelay:(NSTimeInterval)delay
{
    [UIView animateWithDuration:0.8
                          delay:delay
                        options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         
                         notification.frame = CGRectMake(0, -notification.frame.size.height, self.window.frame.size.width, notification.frame.size.height);
                         
                     } completion:^(BOOL finished) {
                         
                         [notification removeFromSuperview];
                         XLog(@"End Pending Notifications: %li",(long)self.notificationViews.count);
                         
                         self.isShowingNotification = NO;
                         [self showNextNotification];
                     }];
}


#pragma mark - Developer status

-(void)updateDeveloperStatus
{
    if ([GGConstants isTimeSimulated]) {
        
        [self setDeveloperStatusLabelText:@"simulating time" andBackgroundColor:[UIColor yellowColor]];
        
    }else {
        
        [self setDeveloperStatusLabelText:nil andBackgroundColor:nil];
        
    }
}

-(void)setDeveloperStatusLabelText:(NSString *)text andBackgroundColor:(UIColor *)color
{
    self.statusOverlay.statusLabel.text = text;
    
    if (text) {
        // show
        self.statusOverlay.backgroundColor = color;
        [self showCustomStatusBarAnimated:YES];
    }else{
        // hide
        self.statusOverlay.backgroundColor = [UIColor clearColor];
        [self hideCustomStatusBarAnimated:YES];
    }
}

-(void)showCustomStatusBarAnimated:(BOOL)animated
{
    self.statusOverlay.hidden = NO;
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.statusOverlay.frame = statusBarFrame;
        } completion:nil];
    }else{
        self.statusOverlay.frame = statusBarFrame;
    }
}

-(void)hideCustomStatusBarAnimated:(BOOL)animated
{
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    
    if (animated) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.statusOverlay.frame = CGRectMake(0, -20, statusBarFrame.size.width, statusBarFrame.size.height);
        } completion:^(BOOL finished) {
            self.statusOverlay.hidden = YES;
        }];
    }else{
        self.statusOverlay.frame = CGRectMake(0, -20, statusBarFrame.size.width, statusBarFrame.size.height);
        self.statusOverlay.hidden = YES;
    }
}

@end
