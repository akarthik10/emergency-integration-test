//
//  GGGNSManager.m
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

#import "GGGNSManager.h"
#import "UMassEmergency-Swift.h"

@interface GGGNSManager ()

@property (nonatomic, strong) ClientBridge *clientBridge;
@property (nonatomic, strong) NSOperationQueue *queue;

@end

static GGGNSManager *manager = nil;

@implementation GGGNSManager


#pragma mark - load GNS account

-(void)loadGNSAccountWithCompletion:(void (^)(NSString *error))completionBlock
{
    NSString *username = self.username;
    NSString *password = self.password;
    
    if (!username) {
        
        if (completionBlock) {
            completionBlock(@"No GNS username/email");
        }
        return;
    }
    
    [self loadGNSAccount:username password:password completion:completionBlock];
}

-(void)loadGNSAccount:(NSString *)username password:(NSString *)password completion:(void (^)(NSString *error))completionBlock
{
    if (self.guid) {
        
        if (completionBlock) {
            completionBlock(nil);
        }
        return;
    }
    
    if (self.isLoadingAccount) {
        if (completionBlock) {
            completionBlock(@"already_loading_account");
        }
        return;
    }
    
    self.isLoadingAccount = YES;

    [self createGNSConntectionWithCompletion:^(BOOL successfull) {
        
        if (self.status == GGGNSStatusNotConnected) {
            
            self.isLoadingAccount = NO;
            if (completionBlock) {
                completionBlock(@"timeout");
            }
            return;
        }
        [self setStatus:GGGNSStatusLoadingAccount];
        
        // create background thread
        [self.queue addOperationWithBlock:^{
            
            [self.clientBridge lookupOrCreateAccount:username password:password returnBlock:^(NSString *result, NSString *error) {
                
                __weak GGGNSManager *weakSelf = self;
                // jump back to main thread
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    
                    __strong GGGNSManager *strongSelf = weakSelf;
                    
                    if (error != nil && ![error isEqualToString:@""]) {

                        XLog(@"lookupOrCreateAccount Error: %@",error);

                        // error, account not loaded
                        strongSelf.guid = nil;
                        
                        [self setStatus:GGGNSStatusAccountNotLoaded];
                        
                        strongSelf.isLoadingAccount = NO;
                        
                        if (completionBlock) {
                            completionBlock(error);
                        }

                    }else{

                        XLog(@"lookupOrCreateAccount Result: %@",result);

                        if (![strongSelf.clientBridge.guidString isEqualToString:@""]) {
                            strongSelf.guid = strongSelf.clientBridge.guidString;
                        }
                        
                        XLog(@"GUID: %@",strongSelf.guid);
                        
                        [self setStatus:GGGNSStatusAccountLoaded];

                        strongSelf.isLoadingAccount = NO;

                        if (completionBlock) {
                            completionBlock(nil);
                        }
                    }
                    
                }];
                
            }];
            
        }];
        
    }];
}

#pragma mark - Read GNS

-(void)readField:(NSString *)fieldName completion:(void (^)(NSString *result, NSString *error))completionBlock
{
    if (!self.guid) {
        if (completionBlock) {
            completionBlock(nil,@"No GUID");
        }
        return;
    }

    __weak GGGNSManager *weakSelf = self;
    // create background thread
    [self.queue addOperationWithBlock:^{
        
        GGGNSManager *strongSelf = weakSelf;
        [strongSelf.clientBridge readField:fieldName completion:^(NSString *result, NSString *error) {
            
            // jump back to main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSString *blockError = error;
                if (error != nil && [error isEqualToString:@""]) {
                    blockError = nil;
                }
                
                if (completionBlock) {
                    completionBlock(result, blockError);
                }
            }];
        }];
    }];
}


-(void)readAllFieldsWithCompletion:(void (^)(NSString *json, NSString *error))completionBlock
{
    if (!self.guid) {
        if (completionBlock) {
            completionBlock(nil,@"No GUID");
        }
        return;
    }

    __weak GGGNSManager *weakSelf = self;
    // create background thread
    [self.queue addOperationWithBlock:^{
        
        GGGNSManager *strongSelf = weakSelf;
        [strongSelf.clientBridge readAllFields:^(NSString *json, NSString *error) {
            
            // jump back to main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSString *blockError = error;
                if (error != nil && [error isEqualToString:@""]) {
                    blockError = nil;
                }
                
                if (completionBlock) {
                    completionBlock(json, blockError);
                }
                
            }];
        }];
    }];
    
}

#pragma mark - Write GNS

-(void)writeField:(NSString *)fieldName value:(id)value completion:(void (^)(NSString *error))completionBlock
{
    if (!self.guid) {
        if (completionBlock) {
            completionBlock(@"No GUID");
        }
        return;
    }

    __weak GGGNSManager *weakSelf = self;
    // create background thread
    [self.queue addOperationWithBlock:^{
        
        GGGNSManager *strongSelf = weakSelf;
        [strongSelf.clientBridge writeField:fieldName value:value completion:^(BOOL success, NSString *error) {
            
            // jump back to main thread
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                NSString *blockError = error;
                if (error != nil && [error isEqualToString:@""]) {
                    blockError = nil;
                }
                
                if (completionBlock) {
                    completionBlock(blockError);
                }
            }];
        }];
    }];
}


#pragma mark - Connection

-(void)createGNSConntectionWithCompletion:(void (^)(BOOL successfull))completionBlock
{
    if (self.clientBridge != nil) {
        
        if (completionBlock) {
            completionBlock(YES);
        }
        return;
    }
    
    if (self.isConnecting) {
        // already connecting to GNS
        if (completionBlock) {
            completionBlock(NO);
        }
        return;
    }
    
    self.isConnecting = YES;
    self.guid = nil;
    
    [self setStatus:GGGNSStatusConnecting];
    
    // create background thread
    [self.queue addOperationWithBlock:^{
        
        NSString *gnsHost = [GGConstants gnsHost];
        NSInteger gnsPort = [GGConstants gnsPort];
        XLog(@"start connection %@:%li",gnsHost,(long)gnsPort);
        ClientBridge *clientBridge = [[ClientBridge alloc] initWithHost:gnsHost port:gnsPort];
        XLog(@"clientBridge created: %@",clientBridge);
        self.clientBridge = clientBridge;
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            self.isConnecting = NO;
            if (self.clientBridge) {
                [self setStatus:GGGNSStatusConnected];
            }else{
                [self setStatus:GGGNSStatusNotConnected];
            }
            
            if (completionBlock) {
                completionBlock(YES);
            }
        }];
    }];
}


-(void)disconnectGNS
{
    [self.clientBridge disconnect];
    self.clientBridge = nil;
    self.guid = nil;
    
    self.isLoadingAccount = NO;
    self.isConnecting = NO;
    
    [self setStatus:GGGNSStatusNotConnected];
}


-(BOOL)connected
{
    return self.clientBridge != nil;
}

-(NSString *)gnsGUID
{
    return self.guid;
}


#pragma mark - Change GNS Status

-(void)setStatus:(GGGNSStatus)status
{
    _status = status;
    [[NSNotificationCenter defaultCenter] postNotificationName:GGGNSStatusChangeNotification object:nil];
}


#pragma mark - Instance

- (instancetype)init
{
    self = [super init];
    if (self) {

        _status = GGGNSStatusNotConnected;

        self.queue = [[NSOperationQueue alloc] init];
        self.queue.maxConcurrentOperationCount = 1;
   
    }
    return self;
}

+(GGGNSManager *)manager
{
    @synchronized(self)
    {
        if (manager == nil)
        {
            manager = [[GGGNSManager alloc] init];
        }
    }
    return manager;
}
@end
