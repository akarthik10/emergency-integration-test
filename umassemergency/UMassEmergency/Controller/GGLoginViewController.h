//
//  GGLoginViewController.h
//  UMassEmergency
//
//  Created by Görkem Güclü on 20.03.17.
//  Copyright © 2017 University of Massachusetts. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GGLoginDelegate;
@interface GGLoginViewController : UIViewController

@property (nonatomic, strong) NSString *email;
@property (nonatomic, assign) BOOL cancelAllowed;
@property (nonatomic, assign) id<GGLoginDelegate> delegate;

@end

@protocol GGLoginDelegate <NSObject>

-(void)login:(GGLoginViewController *)controller didLoginEmail:(NSString *)email;
-(void)loginDidCancel:(GGLoginViewController *)controller;

@end
