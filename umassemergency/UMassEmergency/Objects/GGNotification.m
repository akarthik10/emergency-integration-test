//
//  GGNotification.m
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

#import "GGNotification.h"

@implementation GGNotification

- (instancetype)initWithAlertID:(NSString *)alertID text:(NSString *)alertText sticky:(BOOL)sticky
{
    self = [super init];
    if (self) {
        self.alertID = alertID;
        self.alertText = alertText;
        self.sticky = sticky;
    }
    return self;
}


-(NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    [dic setValue:self.alertID forKey:@"alertID"];
    [dic setValue:self.alertText forKey:@"alertText"];
    [dic setValue:[NSNumber numberWithBool:self.sticky] forKey:@"sticky"];
    return dic;
}

@end
