//
//  GGCamera.h
//  UMassEmergency
//
//  Created by Görkem Güclü on 26.12.16.
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
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "GGMediaAsset.h"

typedef enum : NSUInteger {
    GGCamereModePhoto,
    GGCamereModeVideo,
} GGCamereMode;

@protocol GGCameraAssetDelegate;
@interface GGCamera : NSObject

@property (assign, nonatomic) id<GGCameraAssetDelegate> delegate;

@property (strong, nonatomic) AVCaptureSession *captureSession;
@property (strong, nonatomic) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *cameraPreviewLayer;
@property (strong, nonatomic) AVCaptureDeviceInput *videoInput;
@property (strong, nonatomic) AVCaptureDeviceInput *audioInput;

@property (readwrite, nonatomic) GGCamereMode cameraMode;
@property (readwrite, nonatomic) BOOL isFlashOn;
@property (readwrite, nonatomic) BOOL isTorchOn;
@property (readwrite, nonatomic) BOOL isRecording;
@property (readwrite, nonatomic) BOOL writeCapturesInAssetLibrary;

-(void)setupCameraSession;
-(BOOL)isCameraSessionRunning;
-(void)startCameraSession;
-(void)stopCameraSession;
-(void)requestCameraPermissionWithCompletion:(void (^)(BOOL granted))completion;

-(void)switchCamera;

-(void)takePhotoWithCompletion:(void (^)(GGMediaAsset *asset, NSError *error))completion;
-(void)startRecording;
-(void)stopRecording;

+(AVCaptureVideoOrientation)cameraOrientationForUIInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@protocol GGCameraAssetDelegate <NSObject>

-(void)camera:(GGCamera *)camera didAddMediaAsset:(GGMediaAsset *)asset;
-(void)camera:(GGCamera *)camera didRemoveMediaAsset:(GGMediaAsset *)asset;

@end
