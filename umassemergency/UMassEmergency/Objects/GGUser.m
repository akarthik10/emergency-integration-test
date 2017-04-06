//
//  GGUser.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 17.04.15.
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

#import "GGUser.h"

@interface GGUser ()

@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *password;

@end

@implementation GGUser


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locations = [[NSMutableSet alloc] init];
    }
    return self;
}



#pragma mark - Locations


// TODO: needs testing in background mode (username & password accessible in background?)
// if not, use commented lines

#pragma mark -

-(void)setGnsUsername:(NSString *)gnsUsername
{
    [[NSUserDefaults standardUserDefaults] setValue:gnsUsername forKey:@"gnsUsername"];
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"GNSCredentials" accessGroup:nil];
//    [keychain setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
//    [keychain setObject:gnsUsername forKey:(__bridge id)kSecAttrAccount];
    self.username = gnsUsername;
}

-(void)setGnsPassword:(NSString *)gnsPassword
{
    [[NSUserDefaults standardUserDefaults] setValue:gnsPassword forKey:@"gnsPassword"];
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"GNSCredentials" accessGroup:nil];
//    [keychain setObject:(__bridge id)kSecAttrAccessibleAlways forKey:(__bridge id)kSecAttrAccessible];
//    [keychain setObject:gnsPassword forKey:(__bridge id)kSecValueData];
    self.password = gnsPassword;
}

-(NSString *)gnsUsername
{
    if (self.username) {
        return self.username;
    }

    NSString *username = [[NSUserDefaults standardUserDefaults] valueForKey:@"gnsUsername"];
    if (username) {
        self.username = username;
        return username;
    }
    
    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuid = [uuid substringToIndex:10];
    NSString *email = [NSString stringWithFormat:@"%@@gns.name",uuid];
//    email = @"goerkem.g+gnstest@gmail.com";
//    email = @"goerkem@mac.com";
    self.username = email;
    return email;

//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"GNSCredentials" accessGroup:nil];
//    NSString *username = [keychain objectForKey:(__bridge id)kSecAttrAccount];
//    if (username && ![username isEqualToString:@""]) {
//        self.username = username;
//        return username;
//    }
//    return nil;
}

-(NSString *)gnsPassword
{
    if (self.password) {
        return self.password;
    }

    NSString *password = [[NSUserDefaults standardUserDefaults] valueForKey:@"gnsPassword"];
    if (password) {
        self.password = password;
        return password;
    }

    NSString *uuid = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    uuid = [uuid stringByReplacingOccurrencesOfString:@"-" withString:@""];
    uuid = [uuid substringToIndex:10];
//    uuid = @"MacBookPro7";
    self.password = uuid;
    return uuid;
    
//    KeychainItemWrapper *keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"GNSCredentials" accessGroup:nil];
//    NSData *passData = [keychain objectForKey:(__bridge id)kSecValueData];
//    NSString *password = [[NSString alloc] initWithBytes:[passData bytes] length:[passData length] encoding:NSUTF8StringEncoding];
//    if (password && ![password isEqualToString:@""]) {
//        self.password = password;
//        return password;
//    }
//    return nil;
}

-(NSDictionary *)dictionaryPresentation
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.name forKey:@"name"];
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (CLLocation *location in self.locations) {
        NSMutableDictionary *locationDic = [[NSMutableDictionary alloc] init];
        [locationDic setValue:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [locationDic setValue:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
        [array addObject:locationDic];
    }
    [dic setValue:array forKey:@"locations"];
    return dic;
}


@end
