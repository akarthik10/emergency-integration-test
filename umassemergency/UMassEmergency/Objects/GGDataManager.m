//
//  GGDataManager.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 12.04.15.
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

#import "GGDataManager.h"
#import "GGGNSManager.h"
#import "GGHazard.h"
#import "HTMLParser.h"
#import "GGRadarImage.h"
#import "GGApp.h"
#import "GGTimeframe.h"
#import "GGGeoJSON.h"
#import "GGMapLegendItem.h"
#import "GGWarningTypeGroup.h"
#import "GGAttribute.h"

#define minimumTimerSecondsPassed 60

@interface GGDataManager ()

@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, readwrite) BOOL downloading;
@property (nonatomic, strong) NSDictionary *timeframesDictionary;
@property (nonatomic, strong) NSMutableDictionary *hazardsDictionary;

@end

@implementation GGDataManager


#pragma mark - Alerts

-(void)updateAlertsWithCompletion:(void (^)(void))completion tooEarly:(void (^)(void))tooEarlyBlock
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval timePassed = [self.lastAlertUpdateDate timeIntervalSinceReferenceDate]+minimumTimerSecondsPassed;

    if (timePassed <= now && !self.downloading) {
        
        [self updateAlertsWithCompletion:completion];
        
    }else{
        
        if (tooEarlyBlock) {
            tooEarlyBlock();
        }
    }
}

-(void)updateAlertsWithCompletion:(void (^)(void))completion
{
    self.downloading = YES;
    XLog(@"Start downloading alerts");
    [self downloadAlertsWithCompletion:^(NSArray *newAlerts) {

        for (NSDictionary *alert in newAlerts) {
            GGHazard *hazard = [GGHazard hazardWithDictionary:alert];
            [self addHazard:hazard];
            XLog( @"%@", alert );
        }
        
        

        self.lastAlertUpdateDate = [NSDate date];
        self.downloading = NO;
        
        XLog(@"Alerts downloaded");
        
        if (completion) {
            completion();
        }

    }];
}


-(void)downloadAlertsWithCompletion:(void (^)(NSArray *newAlerts))completion
{
    GGApp *app = [GGApp instance];
    NSString *urlString = [GGConstants casaAlertsURL];
    NSString *deviceID = app.deviceToken;
    NSString *username = app.user.gnsUsername;
    
    if (!deviceID && !username) {
        // no deviceID or username available => no alerts
        
        if (completion) {
            completion(nil);
        }
        return;
    }

    NSURL *url = [NSURL URLWithString:urlString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
    [request setHTTPMethod:@"POST"];
    [request setTimeoutInterval:5];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:@"true" forKey:@"alerts"];
    [params setValue:username forKey:@"username"];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    [manager POST:urlString parameters:params success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSError *error;
        NSArray *alerts = [NSArray array];
        
        if ([responseObject isKindOfClass:[NSString class]]) {
            
            NSString *json = (NSString *)responseObject;
            alerts = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            
        }else if ([responseObject isKindOfClass:[NSData class]]) {
            
            NSData *result = (NSData *)responseObject;
            alerts = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            
        }else if ([responseObject isKindOfClass:[NSArray class]]) {
            
            alerts = (NSArray *)responseObject;
            
        }else{
            
            XLog(@"WTF");
            
        }
        
        if (completion) {
            completion(alerts);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        XLog(@"Error: %@",error);
        if (completion) {
            completion(@[]);
        }

    }];
}


-(void)downloadAlert:(NSString *)alertID withCompletion:(void (^)(GGHazard *hazard))completion
{
    NSString *urlString = [GGConstants casaAlertsURL];
    urlString = [urlString stringByAppendingFormat:@"alerts?alertID=%@",alertID];
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSError *error;
        NSArray *alerts = [NSArray array];
        
        if ([responseObject isKindOfClass:[NSString class]]) {
            
            NSString *json = (NSString *)responseObject;
            alerts = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];
            
        }else if ([responseObject isKindOfClass:[NSData class]]) {
            
            NSData *result = (NSData *)responseObject;
            alerts = [NSJSONSerialization JSONObjectWithData:result options:0 error:&error];
            
        }else{
            
            XLog(@"WTF");
            
        }
        
        GGHazard *hazard = nil;
        if (alerts && alerts.count > 0) {
            NSDictionary *alert = alerts[0];
            hazard = [GGHazard hazardWithDictionary:alert];
            [self addHazard:hazard];
        }

        if (completion) {
            completion(hazard);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        XLog(@"Error: %@",error);
        
    }];
    
    [operation start];
}


-(void)addHazard:(GGHazard *)hazard
{
    if (hazard) {
        if (hazard.hazardID) {
            [self.hazardsDictionary setValue:hazard forKey:hazard.hazardID];
        }
        hazard.type = [self warningTypeForHazardType:hazard.hazardType];
    }
}

-(void)removeHazard:(GGHazard *)hazard
{
    if (hazard && hazard.hazardID) {
        [self.hazardsDictionary removeObjectForKey:hazard.hazardID];
    }
}

-(NSArray *)hazards
{
    NSArray *hazards = [self hazardsSortedByLocation:[self.hazardsDictionary allValues]];
    return hazards;
}

-(GGHazard *)hazardWithHazardID:(NSString *)hazardID
{
    return [self.hazardsDictionary valueForKey:hazardID];
}

-(NSArray *)hazardsSortedByLocation:(NSArray *)hazards
{
    if (hazards && hazards.count > 0) {
        NSArray *sortedHazards = [hazards sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            GGHazard *hazard1 = (GGHazard *)obj1;
            GGHazard *hazard2 = (GGHazard *)obj2;
            CLLocationDistance distance1 = [hazard1 currentDistance];
            CLLocationDistance distance2 = [hazard2 currentDistance];
            if (distance1 < distance2) {
                return NSOrderedAscending;
            }else if (distance1 > distance2) {
                return NSOrderedDescending;
            }else{
                return NSOrderedSame;
            }
        }];
        return sortedHazards;
    }
    return hazards;
}


-(void)updateHazardsDistanceToLocation:(CLLocation *)location
{
    NSArray *hazards = [self.hazardsDictionary allValues];
    for (GGHazard *hazard in hazards) {
        [hazard updateDistanceToLocation:location];
    }
}

-(void)updateHazardsDirectionToHeading:(CLHeading *)heading andLocation:(CLLocation *)location
{
    NSArray *hazards = [self.hazardsDictionary allValues];
    for (GGHazard *hazard in hazards) {
        [hazard updateDirectionToHeading:heading andLocation:location];
    }
}

#pragma mark - Warning Categories

-(GGWarningType *)warningTypeForHazardType:(NSString *)typeName
{
    for (GGWarningTypeGroup *group in self.warningTypeGroups) {
        GGWarningType *type = [group typeForTypeName:typeName];
        if (type) {
            return type;
        }
    }
    return nil;
}

-(void)loadWarningPreferences
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"warnings" ofType:@"plist"];
    NSArray *fileData = [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *warningTypes = [[NSMutableArray alloc] init];
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    for (NSDictionary *categoryData in fileData) {
        GGWarningCategory *category = [[GGWarningCategory alloc] init];
        
        NSString *name = [categoryData valueForKey:@"name"];
        category.name = name;

        NSString *info = [categoryData valueForKey:@"info"];
        category.info = info;

        NSString *description = [categoryData valueForKey:@"description"];
        category.categoryDescription = description;

        category.icon = [UIImage imageNamed:@"warning-icon"];
        NSString *iconName = [categoryData valueForKey:@"icon"];
        if (iconName && ![iconName isEqualToString:@""]) {
            category.icon = [UIImage imageNamed:iconName];
        }

        category.iconSmall = [UIImage imageNamed:@"warning-icon-small"];
        NSString *iconSmallName = [categoryData valueForKey:@"icon-small"];
        if (iconSmallName && ![iconSmallName isEqualToString:@""]) {
            category.iconSmall = [UIImage imageNamed:iconSmallName];
        }

        category.iconBig = [UIImage imageNamed:@"warning-icon-big"];
        NSString *iconBigName = [categoryData valueForKey:@"icon-big"];
        if (iconBigName && ![iconBigName isEqualToString:@""]) {
            category.iconBig = [UIImage imageNamed:iconBigName];
        }

        category.annotationIcon = [UIImage imageNamed:@"warning-annotation"];
        NSString *annotationIconName = [categoryData valueForKey:@"annotation-icon"];
        if (annotationIconName && ![annotationIconName isEqualToString:@""]) {
            category.annotationIcon = [UIImage imageNamed:annotationIconName];
        }

        NSString *hexColor = [categoryData valueForKey:@"color"];
        if (hexColor) {
            category.color = [UIColor colorFromHexString:hexColor];
        }

        NSArray *types = [categoryData valueForKey:@"types"];
        NSMutableArray *typesArray = [[NSMutableArray alloc] init];
        for (NSDictionary *typeDic in types) {
            GGWarningCategoryType *type = [[GGWarningCategoryType alloc] init];
            type.name = [[typeDic valueForKey:@"name"] lowercaseString];
            NSString *iconName = [typeDic valueForKey:@"icon"];
            if (iconName) {
                type.icon = [UIImage imageNamed:iconName];
            }
            NSString *iconNameSmall = [typeDic valueForKey:@"icon-small"];
            if (iconNameSmall) {
                type.iconSmall = [UIImage imageNamed:iconNameSmall];
            }
            NSString *iconNameBig = [typeDic valueForKey:@"icon-big"];
            if (iconNameBig) {
                type.iconBig = [UIImage imageNamed:iconNameBig];
            }
            NSString *hexColor = [typeDic valueForKey:@"color"];
            if (hexColor) {
                type.color = [UIColor colorFromHexString:hexColor];
            }else{
                type.color = category.color;
            }
            type.category = category;
            [typesArray addObject:type];
            [warningTypes addObject:type];
        }
        category.types = typesArray;

        NSMutableArray *categoryObjects = [[NSMutableArray alloc] init];
        NSArray *warnings = [categoryData valueForKey:@"warnings"];

        for (NSDictionary *warning in warnings) {
            GGWarning *warningObject = [[GGWarning alloc] init];
            NSString *warningID = [warning valueForKey:@"id"];
            NSString *name = [warning valueForKey:@"name"];
            NSString *color = [warning valueForKey:@"color"];
            NSString *title = [warning valueForKey:@"title"];
            NSString *gnsKey = [warning valueForKey:@"gnsKey"];
            NSString *defaultValue = [warning valueForKey:@"default"];
            NSString *source = [warning valueForKey:@"source"];
            NSArray *values = [warning valueForKey:@"values"];

            warningObject.warningCategory = category;
            warningObject.warningID = warningID;
            warningObject.name = name;
            warningObject.color = color;
            warningObject.title = title;
            warningObject.gnsKey = gnsKey;
            warningObject.source = source;
            

            NSString *selectedValue;
            if (gnsKey) {
                selectedValue = [[NSUserDefaults standardUserDefaults] valueForKey:gnsKey];
            }

            NSMutableArray *preferencesObject = [[NSMutableArray alloc] init];
            NSUInteger counter = 0;
            for (NSDictionary *valueDic in values) {
                NSString *key = [valueDic valueForKey:@"key"];
                NSString *value = [valueDic valueForKey:@"value"];
                GGWarningPreference *preference = [[GGWarningPreference alloc] init];
                preference.key = key;
                preference.value = value;
                preference.order = counter;
                preference.warning = warningObject;
                [preferencesObject addObject:preference];
                counter++;
                
                if (selectedValue && [selectedValue isEqualToString:value]) {
                    warningObject.selectedPreference = preference;
                }

                if (defaultValue && [defaultValue isEqualToString:value]) {
                    warningObject.defaultPreference = preference;
                    if (!selectedValue) {
                        warningObject.selectedPreference = preference;
                    }
                }
            }
            warningObject.preferences = preferencesObject;

            [self saveSelectedPreference:warningObject.selectedPreference];

            [categoryObjects addObject:warningObject];
        }
        category.warnings = categoryObjects;

        [array addObject:category];
    }
    
    self.warningPreferences = array;
}


#pragma mark - Attributes

-(void)loadLocalAttributes
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"emergencyAttributes" ofType:@"plist"];
    NSArray *fileData = [NSArray arrayWithContentsOfFile:filePath];
    
    [self handleAttributesData:fileData];
}


-(void)loadAttributesWithCompletion:(void (^)(NSError *error))completionBlock
{
    NSString *url = [GGConstants attributesJSONURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse) {
        return nil;
    }];
    [operation setResponseSerializer:[AFJSONResponseSerializer serializer]];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
        
        NSArray *json;
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            responseObject = [NSArray arrayWithObject:responseObject];
        }
        if([responseObject isKindOfClass:[NSArray class]]) {
            json = responseObject;
        }
        if (json) {
            [self handleAttributesData:json];
        }
        
        if (completionBlock) {
            completionBlock(nil);
        }
        
    } failure:^(AFHTTPRequestOperation * _Nonnull operation, NSError * _Nonnull error) {
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
    [operation start];
}

-(void)handleAttributesData:(NSArray *)attributesData
{
    NSMutableArray *attributes = [[NSMutableArray alloc] init];
    for (NSDictionary *attDic in attributesData) {
        
        NSString *name = [attDic valueForKey:@"name"];
        NSString *title = [attDic valueForKey:@"title"];
        NSNumber *selectCount = [attDic valueForKey:@"selectCount"];
        NSString *type = [attDic valueForKey:@"type"];
        
        GGAttribute *attribute = [[GGAttribute alloc] init];
        attribute.name = name;
        attribute.title = title;
        attribute.selectCount = [selectCount integerValue];
        attribute.type = [GGAttribute typeForTypeName:type];
        
        NSMutableArray *attributeOptions = [[NSMutableArray alloc] init];
        NSArray *options = [attDic valueForKey:@"options"];
        
        // prepare options (range)
        switch (attribute.type) {
            case GGAttributeTypeRange:
            {
                NSNumber *min = [attDic valueForKey:@"min"];
                NSNumber *max = [attDic valueForKey:@"max"];
                NSNumber *steps = [attDic valueForKey:@"steps"];
                NSMutableArray *ageOptions = [[NSMutableArray alloc] init];
                for (double i = [min doubleValue]; i < [max doubleValue]; i = i+[steps doubleValue]) {
                    NSNumber *ageNumber = [NSNumber numberWithDouble:i];
                    NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:[ageNumber stringValue],@"name",[ageNumber stringValue],@"title", nil];
                    [ageOptions addObject:dic];
                }
                options = ageOptions;
            }
                break;
            case GGAttributeTypeBool:
                
                break;
            case GGAttributeTypeNumber:
                
                break;
            case GGAttributeTypeText:
                
                break;
            default:
                break;
        }
        
        for (NSDictionary *optionDic in options) {
            
            NSString *name = [optionDic valueForKey:@"name"];
            NSString *title = [optionDic valueForKey:@"title"];
            
            GGAttributeValue *option = [[GGAttributeValue alloc] init];
            option.name = name;
            option.title = title;
            [attributeOptions addObject:option];
        }
        attribute.options = attributeOptions;
        [attributes addObject:attribute];
    }
    self.attributes = attributes;
}

-(void)uploadAttributesPreferencesWithCompletion:(void (^)(NSString *error))completionBlock
{
    NSMutableDictionary *userSelectedPreferences = [[NSMutableDictionary alloc] init];
    
    for (GGAttribute *attribute in self.attributes) {
        
        NSString *attributeKey = attribute.name;
        
        if (attribute.options.count > 0) {
            
            if (attribute.selectCount > 1) {

                // has multiple values, so store each one seperately as bools
                for (GGAttributeValue *value in attribute.selectedValues) {
                    
                    NSString *valueString = [NSString stringWithFormat:@"%@",[NSNumber numberWithBool:YES]];
                    NSString *keyString = [NSString stringWithFormat:@"%@",value.name];
                    // wheelchair = YES, hearing impaired = YES, ...
                    [userSelectedPreferences setValue:valueString forKey:keyString];
                }
            }else{
                
                // has only one value, so key = value ( age = 28 )
                if (attribute.selectedValues.count > 0) {
                    GGAttributeValue *value = attribute.selectedValues[0];
                    NSString *valueString = [NSString stringWithFormat:@"%@",value.name];
                    NSString *keyString = [NSString stringWithFormat:@"%@",attributeKey];
                    [userSelectedPreferences setValue:valueString forKey:keyString];
                }
            }
            
        }
    }

    if (userSelectedPreferences.count > 0) {
        
        GGGNSManager *gns = [GGGNSManager manager];
        [gns writeField:@"attributes" value:userSelectedPreferences completion:^(NSString *error) {
            
            if (error) {
                XLog(@"Error saving attributes: %@",error);
            }else{
                XLog(@"attributes saved");
            }
            
            if (completionBlock) {
                completionBlock(error);
            }
        }];
    }
    
}

-(void)downloadAttributesPreferencesWithCompletion:(void (^)(NSString *error))completionBlock
{
    XLog(@"Read GNS attributes");
    GGGNSManager *gns = [GGGNSManager manager];
    [gns readField:@"attributes" completion:^(NSString *result, NSString *error) {
        
        NSError *jsonError;
        XLog(@"String Result: %@",result);
        if (error) {
            XLog(@"Error: %@",error);
        }

        NSDictionary *attributes;
        if (result) {
            NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:[result dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&jsonError];
            attributes = [resultDic valueForKey:@"attributes"];
            
            if (attributes && attributes.count > 0) {
                for (GGAttribute *attribute in self.attributes) {
                    
                    // attribute is stored, then save value as attribute name: age = 28
                    NSString *downloadedValue = [attributes valueForKey:attribute.name];
                    if (downloadedValue) {
                        for (GGAttributeValue *value in attribute.options) {
                            if ([value.name isEqualToString:downloadedValue]) {
                                attribute.selectedValues = @[value];
                                break;
                            }
                        }
                    }else{
                        NSMutableArray *selectedValues = [[NSMutableArray alloc] init];
                        // attribute is not stored, then save values as values name: wheelchair = true
                        for (GGAttributeValue *value in attribute.options) {
                            NSString *downloadedValue = [attributes valueForKey:value.name];
                            if (downloadedValue) {
                                [selectedValues addObject:value];
                            }
                        }
                        attribute.selectedValues = selectedValues;
                    }
                    
                }
            }
            
            if (completionBlock) {
                completionBlock(error);
            }
            
        }else{

            XLog(@"No Results: Write empty attributes into GNS");
            [gns writeField:@"attributes" value:@{} completion:^(NSString *error) {
                
                if (error) {
                    XLog(@"Error saving attributes: %@",error);
                }else{
                    XLog(@"attributes saved");
                }
                
                if (completionBlock) {
                    completionBlock(error);
                }
            }];
        }
    }];
}

-(void)saveSelectedAttributes:(NSDictionary *)attributes
{
    [[NSUserDefaults standardUserDefaults] setValue:attributes forKey:@"attributes"];
}


#pragma mark -

-(void)loadHazardTypes
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"hazardTypes" ofType:@"plist"];
    NSArray *fileData = [NSArray arrayWithContentsOfFile:filePath];
    
    NSMutableArray *warningTypeGroups = [[NSMutableArray alloc] init];

    for (NSDictionary *groupDic in fileData) {
        
        GGWarningTypeGroup *group = [[GGWarningTypeGroup alloc] init];
        group.groupID = [[groupDic valueForKey:@"id"] lowercaseString];
        group.name = [groupDic valueForKey:@"name"];
        group.isInFilterList = [[groupDic valueForKey:@"filter-list"] boolValue];
        group.icon = [UIImage imageNamed:@"warning-icon"];
        group.iconSmall = [UIImage imageNamed:@"warning-icon-small"];
        group.iconBig = [UIImage imageNamed:@"warning-icon-big"];
        
        NSString *iconName = [groupDic valueForKey:@"icon"];
        if (iconName) {
            group.icon = [UIImage imageNamed:iconName];
        }
        NSString *iconNameSmall = [groupDic valueForKey:@"icon-small"];
        if (iconNameSmall) {
            group.iconSmall = [UIImage imageNamed:iconNameSmall];
        }
        NSString *iconNameBig = [groupDic valueForKey:@"icon-big"];
        if (iconNameBig) {
            group.iconBig = [UIImage imageNamed:iconNameBig];
        }
        
        NSString *hexColor = [groupDic valueForKey:@"color"];
        if (hexColor) {
            group.color = [UIColor colorFromHexString:hexColor];
        }else{
            group.color = [UIColor darkGrayColor];
        }
        [warningTypeGroups addObject:group];
        
        NSArray *groupTypes = [groupDic valueForKey:@"types"];
        NSMutableArray *types = [[NSMutableArray alloc] init];
        for (NSDictionary *typeDic in groupTypes) {
            GGWarningType *type = [[GGWarningType alloc] init];
            type.name = [[typeDic valueForKey:@"name"] lowercaseString];

            NSString *hexColor = [typeDic valueForKey:@"color"];
            if (hexColor) {
                type.color = [UIColor colorFromHexString:hexColor];
            }else{
                type.color = [UIColor darkGrayColor];
            }

            NSString *iconName = [typeDic valueForKey:@"icon"];
            if (iconName) {
                type.icon = [UIImage imageNamed:iconName];
            }
            NSString *iconNameSmall = [typeDic valueForKey:@"icon-small"];
            if (iconNameSmall) {
                type.iconSmall = [UIImage imageNamed:iconNameSmall];
            }
            NSString *iconNameBig = [typeDic valueForKey:@"icon-big"];
            if (iconNameBig) {
                type.iconBig = [UIImage imageNamed:iconNameBig];
            }

            [types addObject:type];
        }
        group.warningTypes = types;
    }
    self.warningTypeGroups = warningTypeGroups;
}



-(void)saveSelectedPreference:(GGWarningPreference *)preference
{
    if (preference && preference.warning && preference.warning.gnsKey) {
        [[NSUserDefaults standardUserDefaults] setValue:preference.value forKey:preference.warning.gnsKey];
    }
//    XLog(@"Saved Preferences: %@",[[NSUserDefaults standardUserDefaults] dictionaryRepresentation]);
}


-(void)uploadWarningPreferencesWithCompletion:(void (^)(NSString *error))completionBlock
{
    NSMutableDictionary *userSelectedPreferences = [[NSMutableDictionary alloc] init];
    
    for (GGWarningCategory *warningCategory in self.warningPreferences) {
        for (GGWarning *warning in warningCategory.warnings) {
            GGWarningPreference *selectedPreference = warning.selectedPreference;
            if (selectedPreference) {
                [userSelectedPreferences setValue:selectedPreference.value forKey:selectedPreference.warning.gnsKey];
            }
        }
    }
    
//    NSString *json = [userSelectedPreferences jsonStringWithPrettyPrint:NO];
    
    GGGNSManager *gns = [GGGNSManager manager];
    [gns writeField:@"hazardPreferences" value:userSelectedPreferences completion:^(NSString *error) {
        
        if (error) {
            XLog(@"Error saving hazardPreferences: %@",error);

        }else{
            XLog(@"hazardPreferences saved");
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}


#pragma mark - Timeframes

-(void)loadTimeframes
{
    NSMutableArray *timeframesArray = [[NSMutableArray alloc] init];
    NSMutableDictionary *timeframesDic = [[NSMutableDictionary alloc] init];
    
    NSString *timeframesPlist = [[NSBundle mainBundle] pathForResource:@"timeframes" ofType:@"plist"];
    NSArray *timeframes = [NSArray arrayWithContentsOfFile:timeframesPlist];
    for (NSDictionary *timeframeDic in timeframes) {
        NSNumber *timeframeID = [timeframeDic valueForKey:@"id"];
        NSNumber *duration = [timeframeDic valueForKey:@"duration"];
        NSNumber *secondsFromNow = [timeframeDic valueForKey:@"secondsFromNow"];
        NSNumber *enabledValue = [timeframeDic valueForKey:@"enabled"];
        if (![enabledValue boolValue]) {
            continue;
        }
        GGTimeframe *timeframe = [[GGTimeframe alloc] initWithDuration:[duration doubleValue] andSecondsFromNow:[secondsFromNow integerValue]];
        timeframe.timeframeID = timeframeID;
        timeframe.title = [timeframeDic valueForKey:@"title"];
        timeframe.alertFileURLs = [timeframeDic valueForKey:@"alertFileURLs"];
        timeframe.radarImageURLs = [timeframeDic valueForKey:@"radarImageURLs"];
        timeframe.priority = [timeframeDic valueForKey:@"priority"];
        [timeframesArray addObject:timeframe];
        [timeframesDic setObject:timeframe forKey:timeframeID];
    }
    self.timeframes = timeframesArray;
    self.timeframesDictionary = timeframesDic;
}


#pragma mark -

-(void)loadSimulationLocations
{
    NSMutableArray *locationsArray = [[NSMutableArray alloc] init];
    NSString *sLocationsPlist = [[NSBundle mainBundle] pathForResource:@"simulationLocations" ofType:@"plist"];
    NSArray *locations = [NSArray arrayWithContentsOfFile:sLocationsPlist];
    for (NSDictionary *info in locations) {
        NSString *name = [info valueForKey:@"name"];
        NSString *latitude = [info valueForKey:@"latitude"];
        NSString *longitude = [info valueForKey:@"longitude"];
        CLLocationDegrees lat = [latitude doubleValue];
        CLLocationDegrees lon = [longitude doubleValue];
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(lat, lon);
        if (CLLocationCoordinate2DIsValid(coordinates)) {
            GGLocation *location = [[GGLocation alloc] initWithLatitude:lat longitude:lon];
            location.name = name;
            [locationsArray addObject:location];
        }
    }
    self.simulationLocations = locationsArray;
}


#pragma mark -

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.downloading = NO;
        self.lastAlertUpdateDate = [NSDate distantPast];
        self.operationQueue = [[NSOperationQueue alloc] init];
        self.hazardsDictionary = [NSMutableDictionary dictionary];
        self.userPreferences = [NSMutableDictionary dictionary];
        self.alertFiles = [NSArray array];
        
        [self loadLocalAttributes];
        [self loadAttributesWithCompletion:nil];
        
        [self loadWarningPreferences];
        [self loadHazardTypes];
        
        [self loadTimeframes];
        [self loadSimulationLocations];
    }
    return self;
}


@end
