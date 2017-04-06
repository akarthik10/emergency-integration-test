//
//  GGCamera.m
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

#import "GGCamera.h"
#import <AssetsLibrary/AssetsLibrary.h>

@interface GGCamera () <AVCaptureFileOutputRecordingDelegate>

@end

@implementation GGCamera

-(void)requestCameraPermissionWithCompletion:(void (^)(BOOL granted))completion
{
    if ([AVCaptureDevice respondsToSelector:@selector(requestAccessForMediaType: completionHandler:)]) {
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                // Permission has been granted. Use dispatch_async for any UI updating
                // code because this block may be executed in a thread.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(YES);
                    }
                });
            } else {
                // Permission has been denied.
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (completion) {
                        completion(NO);
                    }
                });
            }
        }];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(YES);
            }
        });
    }
}


-(void)setupCameraSession
{
    if ([self.captureSession isRunning]) {
        return;
    }
    
    self.captureSession = [[AVCaptureSession alloc] init];
    
    AVCaptureDevice *videoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    AVCaptureDevice *audioDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    
    self.videoInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
    self.audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:audioDevice error:nil];
    
    if (!self.videoInput || !self.audioInput) {
        return;
    }
    
    self.stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *stillImageOutputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                              AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:stillImageOutputSettings];
    
    self.movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    
    [self.captureSession beginConfiguration];
    
    [self.captureSession addInput:self.videoInput];
    [self.captureSession addInput:self.audioInput];
    [self.captureSession addOutput:self.movieFileOutput];
    [self.captureSession addOutput:self.stillImageOutput];
    
    if ([self.captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    
    [self.captureSession commitConfiguration];
    
    self.cameraPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:self.captureSession];
}

-(BOOL)isCameraSessionRunning
{
    if (self.captureSession) {
        return self.captureSession.isRunning;
    }
    return NO;
}

-(void)startCameraSession
{
    if (!self.captureSession) {
        [self setupCameraSession];
    }
    if (!self.captureSession.isRunning) {
        [self.captureSession startRunning];
    }
}

-(void)stopCameraSession
{
    if ([self.captureSession isRunning]) {
        [self.captureSession stopRunning];
        for(AVCaptureInput *input in self.captureSession.inputs) {
            [self.captureSession removeInput:input];
        }
        
        for(AVCaptureOutput *output in self.captureSession.outputs) {
            [self.captureSession removeOutput:output];
        }
    }
    self.captureSession = nil;
}

-(void)switchCamera
{
    if (self.captureSession) {
        
        AVCaptureDevice *frontCamera;
        AVCaptureDevice *backCamera;
        
        for (AVCaptureDevice *device in [AVCaptureDevice devices]) {
            if ([device hasMediaType:AVMediaTypeVideo]) {
                if (device.position == AVCaptureDevicePositionBack) {
                    backCamera = device;
                }else if(device.position == AVCaptureDevicePositionFront){
                    frontCamera = device;
                }
            }
        }
        
        [self.captureSession beginConfiguration];
        
        [self.captureSession removeInput:self.videoInput];
        
        //add new one
        AVCaptureDevice *newCamera;
        if (self.videoInput.device.position == AVCaptureDevicePositionBack) {
            newCamera = frontCamera;
        }else{
            newCamera = backCamera;
        }
        
        NSError *error;
        AVCaptureDeviceInput *newVideoInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:&error];
        if (error || !newVideoInput) {
            XLog(@"Error: %@",error);
        }else{
            self.videoInput = newVideoInput;
            [self.captureSession addInput:self.videoInput];
        }
        
        // commit changes
        [self.captureSession commitConfiguration];
    }
}

-(void)setIsFlashOn:(BOOL)isFlashOn
{
    _isFlashOn = isFlashOn;
    
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasFlash]){
            [device lockForConfiguration:nil];
            if (isFlashOn) {
                [device setFlashMode:AVCaptureFlashModeOn];
            } else {
                [device setFlashMode:AVCaptureFlashModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}

-(void)setIsTorchOn:(BOOL)isTorchOn
{
    _isTorchOn = isTorchOn;
    
    // for video
    Class captureDeviceClass = NSClassFromString(@"AVCaptureDevice");
    if (captureDeviceClass != nil) {
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]){
            
            [device lockForConfiguration:nil];
            if (isTorchOn) {
                [device setTorchMode:AVCaptureTorchModeOn];
            } else {
                [device setTorchMode:AVCaptureTorchModeOff];
            }
            [device unlockForConfiguration];
        }
    }
}


#pragma mark -

-(void)takePhotoWithCompletion:(void (^)(GGMediaAsset *asset, NSError *error))completion
{
    AVCaptureConnection *videoConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!videoConnection) {
        if (completion) {
            completion(nil,nil);
        }
        return;
    }
    videoConnection.videoOrientation = [GGCamera cameraOrientationForUIInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];

    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        if (imageDataSampleBuffer != NULL) {
            
            NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *image = [UIImage imageWithData:imageData];
            
            // write to documents folder
            NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filename = [NSString stringWithFormat:@"%.4f.jpeg",[NSDate date].timeIntervalSinceReferenceDate];
            NSString *path = [documentsFolder stringByAppendingPathComponent:filename];
            [UIImageJPEGRepresentation(image, 1.0) writeToFile:path atomically:YES];
            
            GGMediaAsset *asset = [[GGMediaAsset alloc] init];
            asset.url = [NSURL fileURLWithPath:path];
            asset.isVideo = NO;
            
            [self addMediaAsset:asset];
            
            if (completion) {
                completion(asset,error);
            }
            return;
        }
        if (completion) {
            completion(nil,error);
        }
    }];
}


-(void)startRecording
{
    self.isRecording = YES;
    
    XLog(@"START RECORDING");
    
    NSString *dateFormat = [NSString stringWithFormat:@"%@%@",[NSDate dateFormatString],[NSDate timeFormatString]];
    NSString *filename = [NSString stringWithFormat:@"output-%@.mov",[[NSDate date] stringWithFormat:dateFormat]];
    NSString *documentsFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *outputPath = [documentsFolder stringByAppendingPathComponent:filename];
    NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:outputPath])
    {
        NSError *error;
        if ([fileManager removeItemAtPath:outputPath error:&error] == NO){
            //Error - handle if requried
        }
    }
    
    [self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo].videoOrientation = [GGCamera cameraOrientationForUIInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];

    //Start recording
    [self.movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
}

-(void)stopRecording
{
    XLog(@"STOP RECORDING");
    
    self.isRecording = NO;
    
    [self.movieFileOutput stopRecording];
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didStartRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    XLog(@"Recording started");
}

-(void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    XLog(@"Recording finished");
    
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr)
    {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
    if (recordedSuccessfully){
        
        GGMediaAsset *thumb = [[GGMediaAsset alloc] init];
        thumb.url = outputFileURL;
        thumb.isVideo = YES;
        
        [self addMediaAsset:thumb];
        
        XLog(@"success");
        if (self.writeCapturesInAssetLibrary) {
            ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
            if ([library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL])
            {
                [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
                    if (error){
                        XLog(@"Error: %@",error);
                    }
                }];
            }
        }
    }
}

#pragma mark -

+(AVCaptureVideoOrientation)cameraOrientationForUIInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            return AVCaptureVideoOrientationLandscapeLeft;
        case UIInterfaceOrientationLandscapeRight:
            return AVCaptureVideoOrientationLandscapeRight;
        case UIInterfaceOrientationPortrait:
            return AVCaptureVideoOrientationPortrait;
        case UIInterfaceOrientationPortraitUpsideDown:
            return AVCaptureVideoOrientationPortraitUpsideDown;
        default:
            return AVCaptureVideoOrientationPortrait;
    }
}


#pragma mark -

-(void)addMediaAsset:(GGMediaAsset *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didAddMediaAsset:)]) {
        [self.delegate camera:self didAddMediaAsset:asset];
    }
}

-(void)removeMediaAsset:(GGMediaAsset *)asset
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(camera:didRemoveMediaAsset:)]) {
        [self.delegate camera:self didRemoveMediaAsset:asset];
    }
}



@end
