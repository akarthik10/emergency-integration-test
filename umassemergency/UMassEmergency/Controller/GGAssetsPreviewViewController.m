//
//  GGAssetsPreviewViewController.m
//  UMassEmergency
//
//  Created by Görkem Güclü on 12.01.17.
//  Copyright © 2017 University of Massachusetts.
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

#import "GGAssetsPreviewViewController.h"

@interface GGAssetsPreviewViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation GGAssetsPreviewViewController

-(IBAction)closeButtonPressed:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.imageView.image = self.image;
    
    UIBarButtonItem *closeButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonPressed:)];
    [self.navigationItem setLeftBarButtonItem:closeButton];
}


@end
