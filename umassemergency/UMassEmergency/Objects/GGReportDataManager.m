//
//  GGReportDataManager.m
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

#import "GGReportDataManager.h"
#import <AFNetworking.h>
#import "GGConstants.h"

@implementation GGReportDataManager


-(void)sendLocationOfReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock
{
    XLog(@"Send LOCATION");
    [self uploadReport:report location:report.location title:nil description:nil assets:nil progressBlock:progressBlock withCompletion:completionBlock];
}

-(void)sendTitleOfReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock
{
    XLog(@"Send TITLE");
    [self uploadReport:report location:nil title:report.title description:nil assets:nil progressBlock:progressBlock  withCompletion:completionBlock];
}

-(void)sendDescriptionOfReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock
{
    XLog(@"Send DESCRIPTION");
    [self uploadReport:report location:nil title:nil description:report.description assets:nil progressBlock:progressBlock  withCompletion:completionBlock];
}

-(void)sendImage:(GGMediaAsset *)asset ofReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock
{
    XLog(@"Send IMAGE");
    if (!asset.isVideo) {
        [asset loadImageWithCompletion:^(UIImage *image) {
            NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
            asset.assetData = imageData;
            
            [self uploadReport:report location:nil title:nil description:nil assets:@[asset] progressBlock:progressBlock  withCompletion:completionBlock];
        }];
    }
}

-(void)sendVideo:(GGMediaAsset *)asset ofReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock
{
    XLog(@"Send VIDEO");
    if (asset.isVideo) {
        NSData *videoData = [NSData dataWithContentsOfURL:asset.url];
        asset.assetData = videoData;
        
        [self uploadReport:report location:nil title:nil description:nil assets:@[asset] progressBlock:progressBlock withCompletion:completionBlock];
    }
}

-(void)removeAsset:(GGMediaAsset *)asset ofReport:(GGReport *)report withCompletion:(void (^)(NSError *error))completionBlock
{
    if (asset.isVideo) {
        NSData *videoData = [NSData dataWithContentsOfURL:asset.url];
        asset.assetData = videoData;
        
        [self uploadReport:report location:nil title:nil description:nil assets:@[asset] progressBlock:nil withCompletion:completionBlock];
    }
}

-(void)sendReport:(GGReport *)report withCompletion:(void (^)(NSError *error))completionBlock;

//-(void)sendReport:(CLLocation *)location title:(NSString *)title description:(NSString *)description files:(NSArray<GGMediaAsset *> *)assets withCompletion:(void (^)(NSError *error))completionBlock
{
    NSInteger counter = 0;
    for (GGMediaAsset *asset in report.assets) {
        
        counter++;
        if (asset.isVideo) {
            NSData *videoData = [NSData dataWithContentsOfURL:asset.url];
            asset.assetData = videoData;

            if (counter == report.assets.count) {
                // last one
                // now go upload
                [self uploadReport:report progressBlock:nil withCompletion:completionBlock];
            }

        }else{
            [asset loadImageWithCompletion:^(UIImage *image) {
                NSData *imageData = UIImageJPEGRepresentation(image, 0.5);
                asset.assetData = imageData;
                
                if (counter == report.assets.count) {
                    // last one
                    // now go upload
                    
                    [self uploadReport:report progressBlock:nil withCompletion:completionBlock];
                }
            }];
        }
    }
    

}


-(void)uploadReport:(GGReport *)report progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock
{
}

-(void)uploadReport:(GGReport *)report location:(CLLocation *)location title:(NSString *)title description:(NSString *)description assets:(NSArray<GGMediaAsset *> *)assets progressBlock:(void (^)(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite))progressBlock withCompletion:(void (^)(NSError *error))completionBlock
{
    NSString *sessionID = report.sessionID;
    
    NSString *backendURL = [GGConstants backendURL];
    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:backendURL]];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.requestSerializer.timeoutInterval = 20;

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"updateReport" forKey:@"method"];
    if (sessionID) {
        [parameters setValue:sessionID forKey:@"sessionID"];
    }
    if (!location && report.location) {
        location = report.location;
    }
    if (location) {
        [parameters setValue:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"latitude"];
        [parameters setValue:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"longitude"];
    }
    if (title) {
        [parameters setValue:title forKey:@"title"];
    }
    if (description) {
        [parameters setValue:description forKey:@"desc"];
    }
    
    [parameters setValue:[[[UIDevice currentDevice] identifierForVendor] UUIDString] forKey:@"deviceID"];
    
    XLog(@"Params: %@",parameters);
    
    AFHTTPRequestOperation *op = [manager POST:backendURL parameters:parameters constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        
        NSInteger imageCounter = 0;
        NSInteger videoCounter = 0;
        for (GGMediaAsset *asset in assets) {
            if (asset.isVideo) {
                NSData *videoData = asset.assetData;
                NSNumber *count = [NSNumber numberWithInteger:videoCounter];
                XLog(@"Video: %@",count);
                [formData appendPartWithFileData:videoData name:[NSString stringWithFormat:@"video%@",count] fileName:[NSString stringWithFormat:@"video%@.mov",count] mimeType:@"video/quicktime"];
                videoCounter++;
            }else{
                NSData *imageData = asset.assetData;
                NSNumber *count = [NSNumber numberWithInteger:imageCounter];
                XLog(@"Image: %@",count);
                [formData appendPartWithFileData:imageData name:[NSString stringWithFormat:@"img%@",count] fileName:[NSString stringWithFormat:@"img%@.jpg",count] mimeType:@"image/jpeg"];
                imageCounter++;
            }
        }
        
    } success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        XLog(@"Success: %@ *****", operation.responseString);
        
        if (completionBlock) {
            completionBlock(nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        XLog(@"Error: %@ ***** %@", operation.responseString, error);
        
        NSString *newStr = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
        XLog(@"Error String: %@",newStr);
        
        if (completionBlock) {
            completionBlock(error);
        }
        
    }];
    [op setUploadProgressBlock:progressBlock];
    [op start];
}


-(void)deleteAsset:(GGMediaAsset *)asset ofReport:(GGReport *)report withCompletion:(void (^)(NSError *error))completionBlock
{
    NSString *sessionID = report.sessionID;

    NSString *backendURL = [GGConstants backendURL];

    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    [parameters setValue:@"deleteReportAsset" forKey:@"method"];
    if (sessionID) {
        [parameters setValue:sessionID forKey:@"sessionID"];
    }

    AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:backendURL]];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    AFHTTPRequestOperation *op = [manager POST:backendURL parameters:parameters constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        XLog(@"Success: %@ *****", operation.responseObject);
        
        if (completionBlock) {
            completionBlock(nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        XLog(@"Error: %@ ***** %@", operation.responseObject, error);
        
//        NSString *newStr = [[NSString alloc] initWithData:operation.responseData encoding:NSUTF8StringEncoding];
//        XLog(@"Error String: %@",newStr);
        
        if (completionBlock) {
            completionBlock(error);
        }
        
    }];
    [op start];

}

@end
