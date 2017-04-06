//
//  GGReportDataManager.h
//  UMassEmergency
//
//  Created by Görkem Güclü on 19.07.16.
//  Copyright © 2016 University of Massachusetts.
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
#import "GGReport.h"

@interface GGReportDataManager : NSObject

-(void)sendLocationOfReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock;
-(void)sendTitleOfReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock;
-(void)sendDescriptionOfReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock;
-(void)sendImage:(GGMediaAsset *)asset ofReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock;
-(void)sendVideo:(GGMediaAsset *)asset ofReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock;

-(void)removeAsset:(GGMediaAsset *)asset ofReport:(GGReport *)report withCompletion:(void (^)(NSError *error))completionBlock;

@end
