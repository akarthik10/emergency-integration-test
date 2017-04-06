//
//  GGGNSManager.h
// UMassEmergenxy
//
//  Created by Görkem Güclü on 22.01.17.
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

#import <Foundation/Foundation.h>
#import "GGUser.h"

typedef enum : NSUInteger {
    GGGNSStatusNotConnected,
    GGGNSStatusConnecting,
    GGGNSStatusConnected,
    GGGNSStatusAccountNotLoaded,
    GGGNSStatusLoadingAccount,
    GGGNSStatusAccountLoaded,
} GGGNSStatus;

static NSString *GGGNSStatusChangeNotification = @"GGGNSStatusChangeNotification";

@interface GGGNSManager : NSObject

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@property (nonatomic, strong) NSString *guid;

@property (nonatomic, readonly) GGGNSStatus status;
@property (nonatomic, readonly) BOOL connected;
@property (nonatomic, readwrite) BOOL isConnecting;
@property (nonatomic, readwrite) BOOL isLoadingAccount;

+(GGGNSManager *)manager;

-(void)createGNSConntectionWithCompletion:(void (^)(BOOL successfull))completionBlock;
-(void)disconnectGNS;

-(void)loadGNSAccountWithCompletion:(void (^)(NSString *error))completionBlock;
-(void)loadGNSAccount:(NSString *)username password:(NSString *)password completion:(void (^)(NSString *error))completionBlock;

-(void)readAllFieldsWithCompletion:(void (^)(NSString *json, NSString *error))completionBlock;
-(void)readField:(NSString *)fieldName completion:(void (^)(NSString *result, NSString *error))completionBlock;
-(void)writeField:(NSString *)fieldName value:(id)value completion:(void (^)(NSString *error))completionBlock;

@end
