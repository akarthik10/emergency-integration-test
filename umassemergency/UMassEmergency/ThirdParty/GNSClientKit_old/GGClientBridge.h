//
//  GGClientBridge.h
//  WindContours
//
//  Created by Görkem Güclü on 22.05.15.
//  Copyright (c) 2015 Görkem Güclü. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMassEmergency-Swift.h"
//#import "BasicTCPClient-Swift.h"

@interface GGClientBridge : NSObject

@property (nonatomic, strong) BasicTCPClient *client;

@end
