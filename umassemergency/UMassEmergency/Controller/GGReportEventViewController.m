//
//  GGReportEventViewController.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 10.03.15.
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

#import "GGReportEventViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "GGReportDataManager.h"
#import "GGApp.h"
#import <AVFoundation/AVFoundation.h>
#import <AVKit/AVKit.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "GGAssetsPreviewViewController.h"
#import "GGSnapButton.h"
#import "GGThumbnailBarView.h"
#import "GGThumbnailBarCollectionViewCell.h"
#import "GGPlaceHolderTextView.h"
#import "GGCamera.h"

#define trackingScreenName @"Create Report Screen"

@interface GGReportEventViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, GGAppLocationDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, GGSnapButtonDelegate, GGCameraAssetDelegate>

@property (nonatomic, weak) IBOutlet GGPlaceHolderTextView *reportTitle;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *thumbnailImageView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendButton;
@property (weak, nonatomic) IBOutlet UIButton *mediaLibraryButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *snapButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *switchCameraButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *flashButtonBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cameraPreviewTopConstraint;

@property (strong, nonatomic) GGApp *app;
@property (strong, nonatomic) GGReportDataManager *reportDataManager;
@property (strong, nonatomic) UIActivityIndicatorView *activityView;
@property (strong, nonatomic) GGCamera *camera;
@property (readwrite, nonatomic) BOOL flashEnabled;

@property (strong, nonatomic) IBOutlet UIView *cameraModeLabelsContainer;
@property (weak, nonatomic) IBOutlet UIScrollView *cameraModeLabelsScrollView;
@property (weak, nonatomic) IBOutlet UILabel *photoLabel;
@property (weak, nonatomic) IBOutlet UILabel *videoLabel;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *photoLabelTapGesture;
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *videoLabelTapGesture;

@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *rightSwipeGesture;
@property (strong, nonatomic) IBOutlet UISwipeGestureRecognizer *leftSwipeGesture;

@property (weak, nonatomic) IBOutlet UIView *cameraPreview;
@property (strong, nonatomic) UIView *videoPreview;
@property (weak, nonatomic) IBOutlet GGSnapButton *snapButton;
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet UICollectionView *thumbnailCollectionView;
@property (weak, nonatomic) IBOutlet UIView *thumbnailContainerView;

@property (weak, nonatomic) IBOutlet UIButton *switchCameraButton;
@property (weak, nonatomic) IBOutlet UIButton *toggleFlashButton;


@end

@implementation GGReportEventViewController

-(void)close
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)backButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(reportEventViewControllerDidClose:)]) {
        [self.delegate reportEventViewControllerDidClose:self];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)mediaLibraryButtonPressed:(id)sender
{
    [self showMediaBrowser];
}

#pragma mark - Swipes
- (IBAction)photoLabelTapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer
{
    [self switchToPhotoMode];
}

- (IBAction)videoLabelTapGestureRecognized:(UITapGestureRecognizer *)gestureRecognizer
{
    [self switchToVideoMode];
}

- (IBAction)rightSwipeGestureRecognized:(UISwipeGestureRecognizer *)sender
{
//    if (self.camera.cameraMode == GGCamereModePhoto) {
//        [self.navigationController popViewControllerAnimated:YES];
//    }else{
//        [self switchToPhotoMode];
//    }
    [self switchToPhotoMode];
}

- (IBAction)leftSwipeGestureRecognized:(UISwipeGestureRecognizer *)sender
{
    [self switchToVideoMode];
}


-(void)switchToPhotoMode
{
    self.camera.cameraMode = GGCamereModePhoto;
    self.photoLabel.textColor = [UIColor yellowColor];
    self.videoLabel.textColor = [UIColor whiteColor];
    [self updateCameraModeLabel];
    [self.snapButton showPhotoButton];
    self.camera.cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    self.camera.isFlashOn = self.flashEnabled;
    self.camera.isTorchOn = NO;
}

-(void)switchToVideoMode
{
    self.camera.cameraMode = GGCamereModeVideo;
    self.photoLabel.textColor = [UIColor whiteColor];
    self.videoLabel.textColor = [UIColor yellowColor];
    [self updateCameraModeLabel];
    [self.snapButton showVideoButton];
    self.camera.cameraPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;

    self.camera.isTorchOn = self.flashEnabled;
}

-(void)updateCameraModeLabel
{
    switch (self.camera.cameraMode) {
        
        case GGCamereModePhoto:
        {
            [self.cameraModeLabelsScrollView setContentOffset:CGPointMake(self.photoLabel.center.x-self.cameraModeLabelsScrollView.frame.size.width/2, 0) animated:YES];
            break;
        }
        case GGCamereModeVideo:
        {
            [self.cameraModeLabelsScrollView setContentOffset:CGPointMake(self.videoLabel.center.x-self.cameraModeLabelsScrollView.frame.size.width/2, 0) animated:YES];
            break;
        }
    }
}

#pragma mark -

-(void)tapGestureRecognized:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.reportTitle resignFirstResponder];
    }
}

#pragma mark - Snap Button

-(void)snapButtonDidPress:(GGSnapButton *)button
{
    switch (self.camera.cameraMode) {
        
        case GGCamereModePhoto:
            
            [self takePhoto];
            break;
            
        case GGCamereModeVideo:
            
            if (self.camera.isRecording) {
                [self stopRecording];
            }else{
                [self startRecording];
            }
            break;
    }
}

#pragma mark -

- (void)takePhoto
{
    [self.camera takePhotoWithCompletion:^(GGMediaAsset *asset, NSError *error) {
        if (asset) {
            // all good
        }else{
            NSString *message = [NSString stringWithFormat:@"Unable to take photo."];
            if (error) {
                message = [NSString stringWithFormat:@"Unable to take photo\n%@",error.localizedDescription];
            }
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:YES completion:nil];

        }
    }];
}

-(void)startRecording
{
    XLog(@"START RECORDING");
    
    self.infoLabel.text = @"Recording ...";
    [self showInfoLabelAnimated:YES completion:^(BOOL finished) {
    }];

    [self.snapButton showRecordingButton];
    [self.camera startRecording];
    
    self.leftSwipeGesture.enabled = NO;
    self.rightSwipeGesture.enabled = NO;
    self.cameraModeLabelsScrollView.hidden = YES;
}

-(void)stopRecording
{
    XLog(@"STOP RECORDING");

    self.infoLabel.text = @"Recording finished";
    [self showInfoLabelAnimated:YES completion:^(BOOL finished) {
        [self hideInfoLabelAnimated:YES completion:nil];
    }];

    [self.snapButton showVideoButton];
    [self.camera stopRecording];

    self.leftSwipeGesture.enabled = YES;
    self.rightSwipeGesture.enabled = YES;
    self.cameraModeLabelsScrollView.hidden = NO;
}

-(void)removeThumbnailImage
{
    _thumbnailImageView.image = nil;
}

#pragma mark - Camera Delegate

-(void)camera:(GGCamera *)camera didAddMediaAsset:(GGMediaAsset *)asset
{
    [self.report addAsset:asset];
    [self.thumbnailCollectionView reloadData];
    
    NSUInteger index = [self.report.assets indexOfObject:asset];
    GGThumbnailBarCollectionViewCell *cell = (GGThumbnailBarCollectionViewCell *)[self.thumbnailCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    cell.isUploading = YES;

    self.report.location = self.app.locationManager.location;
    
    if (asset.isVideo) {
        [self.reportDataManager sendVideo:asset ofReport:self.report progressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            cell.isUploading = YES;
            cell.uploadProgress = (double)((double)totalBytesWritten/(double)totalBytesExpectedToWrite);
            
        } withCompletion:^(NSError *error) {
            XLog(@"Uploaded VIDEO");

            cell.isUploading = NO;

        }];
    }else{
        [self.reportDataManager sendImage:asset ofReport:self.report progressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            
            cell.isUploading = YES;
            cell.uploadProgress = (double)((double)totalBytesWritten/(double)totalBytesExpectedToWrite);

        } withCompletion:^(NSError *error) {
            XLog(@"Uploaded IMAGE");
            
            cell.isUploading = NO;

        }];
    }
}

-(void)camera:(GGCamera *)camera didRemoveMediaAsset:(GGMediaAsset *)asset
{
    [self.report removeAsset:asset];
    [self.thumbnailCollectionView reloadData];
}


#pragma mark - IBAction

- (IBAction)toggleFlashButtonPressed:(id)sender
{
    self.flashEnabled = !self.flashEnabled;
    
    if (self.camera.cameraMode == GGCamereModePhoto) {
        self.camera.isFlashOn = self.flashEnabled;
    }else{
        self.camera.isTorchOn = self.flashEnabled;
    }
}

- (IBAction)switchCameraButtonPressed:(id)sender
{
    [self switchCamera];
}

-(IBAction)doneButtonPressed:(id)sender
{
    [self close];
}


#pragma mark - Flash

-(void)setFlashEnabled:(BOOL)flashEnabled
{
    _flashEnabled = flashEnabled;

    if (flashEnabled) {
        self.toggleFlashButton.tintColor = [UIColor yellowColor];
    }else{
        self.toggleFlashButton.tintColor = [UIColor whiteColor];
    }
    
    self.camera.isFlashOn = flashEnabled;
    if (self.camera.cameraMode == GGCamereModeVideo) {
        self.camera.isTorchOn = flashEnabled;
    }
}


#pragma mark - TextView

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    XLog(@"Begin editing");
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self formatTextInTextView:textView];
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    XLog(@"End editing");

    self.report.location = self.app.locationManager.location;

    self.report.title = textView.text;
    if (self.report.title && self.report.title.length > 0) {
        [self.reportDataManager sendTitleOfReport:self.report progressBlock:nil withCompletion:^(NSError *error) {
            XLog(@"Uploaded TITLE");
        }];
        [self.app forceUpdateLocation];
    }
}

- (void)formatTextInTextView:(UITextView *)textView
{
    textView.scrollEnabled = NO;
    NSString *text = textView.text;
    
    UIFont *font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedString addAttribute:NSFontAttributeName
                             value:font
                             range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSForegroundColorAttributeName
                             value:[UIColor whiteColor]
                             range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSStrokeColorAttributeName
                             value:[UIColor blackColor]
                             range:NSMakeRange(0, attributedString.length)];
    [attributedString addAttribute:NSStrokeWidthAttributeName
                             value:@-2
                             range:NSMakeRange(0, attributedString.length)];
    
    textView.attributedText = attributedString;
    textView.scrollEnabled = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSRange resultRange = [text rangeOfCharacterFromSet:[NSCharacterSet newlineCharacterSet] options:NSBackwardsSearch];
    if ([text length] == 1 && resultRange.location != NSNotFound) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

#pragma mark - Location Delegate

-(void)app:(GGApp *)app didUpdateLocations:(NSArray *)locations
{
    XLog(@"Location Update: %@",locations.lastObject);

    self.report.location = locations.lastObject;
    
    if ((self.report.title && self.report.title.length > 0) || self.report.assets.count > 0) {
        [self.reportDataManager sendLocationOfReport:self.report progressBlock:nil withCompletion:^(NSError *error) {
            XLog(@"Uploaded LOCATION");
        }];
    }
}

-(void)app:(GGApp *)app didUpdateHeading:(CLHeading *)heading
{
}

#pragma mark -

-(void)setupCameraSession:(BOOL)forceRestart
{
    // prepare to setup
    [self.camera.cameraPreviewLayer removeFromSuperlayer];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        
        if (!self.camera.captureSession.isRunning || forceRestart) {
            [self.camera stopCameraSession];
            [self.camera setupCameraSession];
            [self.camera startCameraSession];
        }
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{

            self.camera.cameraPreviewLayer.frame = self.cameraPreview.bounds;
            [self.cameraPreview.layer addSublayer:self.camera.cameraPreviewLayer];
            
            self.switchCameraButton.enabled = YES;
        }];
    }];
}

-(void)switchCamera
{
    [self.camera switchCamera];
}


#pragma mark - Info label

-(void)showInfoLabelAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    [self.infoLabel sizeToFit];

    if (animated) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.infoLabel.alpha = 1;
        } completion:completion];
    }else{
        self.infoLabel.alpha = 1;
        if (completion) {
            completion(YES);
        }
    }
}

-(void)hideInfoLabelAnimated
{
    [self hideInfoLabelAnimated:YES completion:nil];
}

-(void)hideInfoLabelAnimated:(BOOL)animated completion:(void (^)(BOOL finished))completion
{
    if (animated) {
        [UIView animateWithDuration:0.5 delay:0.1 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.infoLabel.alpha = 0;
        } completion:completion];
    }else{
        self.infoLabel.alpha = 0;
        if (completion) {
            completion(YES);
        }
    }
}


#pragma mark - CollectionView

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.report.assets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GGThumbnailBarCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.mediaAsset = nil;
    if (indexPath.row < self.report.assets.count) {
        cell.mediaAsset = [self.report.assets objectAtIndex:indexPath.row];
    }
    
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.report.assets.count) {
        // photo
        GGMediaAsset *asset = [self.report.assets objectAtIndex:indexPath.row];
        
        if (asset.isVideo) {
            
            [self playVideo:asset.url];
            
        }else{
            
            [asset loadImageWithCompletion:^(UIImage *image) {
                [self showImage:image];
            }];
        }

    }else{
        // empty
        [self showMediaBrowser];
    }
}

#pragma mark - Thumbnail

-(void)playVideo:(NSURL *)url
{
    AVPlayer *player = [[AVPlayer alloc] initWithURL:url];
    AVPlayerViewController *playerViewController = [AVPlayerViewController new];
    playerViewController.player = player;
    [self presentViewController:playerViewController animated:YES completion:nil];
}

-(void)showImage:(UIImage *)image
{
    GGAssetsPreviewViewController *preview = [[GGAssetsPreviewViewController alloc] initWithNibName:@"GGAssetsPreviewViewController" bundle:nil];
    preview.image = image;
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:preview];
    [self presentViewController:navi animated:YES completion:nil];
}

#pragma mark - Photo Picker

-(BOOL)canSelectMedia
{
    return [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
}

- (void)showMediaBrowser
{
    if (![self canSelectMedia]) {
        return;
    }
    
    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    // Displays saved pictures and movies, if both are available, from the Camera Roll album.
    mediaUI.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
    
    // Hides the controls for moving & scaling pictures, or for trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;
    mediaUI.delegate = self;
    
    [self presentViewController:mediaUI animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    NSURL *assetURL;
    
    // Handle a still image picked from a photo album
    if (CFStringCompare((CFStringRef)mediaType,kUTTypeImage,0) == kCFCompareEqualTo) {

        assetURL = (NSURL *) [info objectForKey:UIImagePickerControllerReferenceURL];
    }
    
    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo) {
        
        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        assetURL = [NSURL fileURLWithPath:moviePath];
        // Do something with the picked movie available at moviePath
        
    }
    GGMediaAsset *asset = [[GGMediaAsset alloc] initWithURL:assetURL];
    
    [self.report.assets addObject:asset];

    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    [self moveCameraButtonsTo:keyboardSize.height+10 animated:YES];
}

- (void)keyboardWillHide:(NSNotification*)notification {
    
    [self moveCameraButtonsTo:60 animated:YES];
}

-(void)moveCameraButtonsTo:(CGFloat)bottomMargin animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:1.0
                         animations:^{
                             self.snapButtonBottomConstraint.constant = bottomMargin;
                             self.flashButtonBottomConstraint.constant = bottomMargin;
                             self.switchCameraButtonBottomConstraint.constant = bottomMargin;
                             [self.snapButton setNeedsUpdateConstraints];
                             [self.view layoutIfNeeded];
                         }];
    }else{
        self.snapButtonBottomConstraint.constant = bottomMargin;
        self.flashButtonBottomConstraint.constant = bottomMargin;
        self.switchCameraButtonBottomConstraint.constant = bottomMargin;
    }
}


#pragma mark - Orientation

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [self updateCameraOrientation];
        [self updateCameraModeLabel];
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

-(void)updateCameraOrientation
{
    self.camera.cameraPreviewLayer.connection.videoOrientation = [GGCamera cameraOrientationForUIInterfaceOrientation:[UIApplication sharedApplication].statusBarOrientation];
}

#pragma mark - View

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
 
    [self updateCameraOrientation];
    [self updateCameraModeLabel];
    
    [self.thumbnailCollectionView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.reportTitle.text = nil;
    [self.thumbnailCollectionView reloadData];
    
    [GGConstants sendTrackingScreenName:trackingScreenName];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (self.isBeingPresented || self.navigationController.isBeingPresented) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(doneButtonPressed:)];
        [self.navigationItem setLeftBarButtonItem:doneButton];
    }

    // start camera
    [self.camera requestCameraPermissionWithCompletion:^(BOOL granted) {
        if (granted) {
            [self setupCameraSession:NO];
        }else{
            if ([self.reportTitle.text isEqualToString:@""]) {
                [self.reportTitle becomeFirstResponder];
            }
        }
    }];

    [self updateCameraOrientation];
    [self updateCameraModeLabel];
    
    self.mediaLibraryButton.hidden = ![self canSelectMedia];
    
    [self.app addLocationDelegate:self];

    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Report Event";
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;

    [self.thumbnailCollectionView registerClass:[GGThumbnailBarCollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
    self.thumbnailCollectionView.layoutMargins = UIEdgeInsetsMake(2, 0, 0, 0);
    
    self.thumbnailContainerView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.3];
    
    self.reportTitle.delegate = self;
    self.reportTitle.placeholderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
    self.reportTitle.placeholderTextAlignment = NSTextAlignmentCenter;
    self.reportTitle.textAlignment = NSTextAlignmentCenter;

    self.reportTitle.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.reportTitle.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.reportTitle.layer.shadowOpacity = .9f;
    self.reportTitle.layer.shadowRadius = 4.0f;
    
    self.videoPreview = [[UIView alloc] initWithFrame:self.cameraPreview.bounds];
    self.videoPreview.hidden = YES;
    self.videoPreview.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.cameraPreview addSubview:self.videoPreview];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognized:)];
    [self.cameraPreview addGestureRecognizer:tapGesture];
    
    self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityView.center = self.view.center;
    self.activityView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    self.activityView.hidesWhenStopped = YES;
    [self.view addSubview:self.activityView];
    
    self.app = [GGApp instance];
    [self.app addLocationDelegate:self];
    
    self.reportDataManager = [[GGReportDataManager alloc] init];
    
    self.camera = self.app.camera;
    self.camera.delegate = self;
    
    self.snapButton.delegate = self;
    
    self.infoLabel.backgroundColor = [[UIColor darkGrayColor] colorWithAlphaComponent:0.5];
    self.infoLabel.layer.masksToBounds = YES;
    self.infoLabel.layer.cornerRadius = self.infoLabel.frame.size.height/2;
    [self hideInfoLabelAnimated];
    
    self.switchCameraButton.enabled = NO;
    self.switchCameraButton.hidden = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo].count <= 1;
    AVCaptureDevice *defaultDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.toggleFlashButton.hidden != [defaultDevice hasTorch] && [defaultDevice hasFlash];

    self.switchCameraButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.switchCameraButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.switchCameraButton.layer.shadowOpacity = .9f;
    self.switchCameraButton.layer.shadowRadius = 4.0f;

    self.toggleFlashButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.toggleFlashButton.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.toggleFlashButton.layer.shadowOpacity = .9f;
    self.toggleFlashButton.layer.shadowRadius = 4.0f;

    self.photoLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.photoLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.photoLabel.layer.shadowOpacity = .9f;
    self.photoLabel.layer.shadowRadius = 4.0f;
    self.photoLabel.layer.masksToBounds = YES;

    self.videoLabel.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.videoLabel.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    self.videoLabel.layer.shadowOpacity = .9f;
    self.videoLabel.layer.shadowRadius = 4.0f;
    self.videoLabel.layer.masksToBounds = YES;
    
    [self.cameraModeLabelsScrollView addSubview:self.cameraModeLabelsContainer];
    self.cameraModeLabelsScrollView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.2];

    [self switchToPhotoMode];
}


-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
 
    [self.navigationController setNavigationBarHidden:NO];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    if ([self.camera isRecording]) {
        [self.camera stopRecording];
    }
    
    if (![GGConstants runningCamera]) {
        [self.camera stopCameraSession];
    }

    [self.app removeLocationDelegate:self];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.camera.cameraPreviewLayer.frame = self.cameraPreview.bounds;
}

@end
