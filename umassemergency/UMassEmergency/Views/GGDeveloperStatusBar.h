//
//  GGDeveloperStatusBar.h
//  WindContours
//
//  Created by Görkem Güclü on 13.06.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "GGStatusBarOverlayWindow.h"

@interface GGDeveloperStatusBar : GGStatusBarOverlayWindow

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UILabel *timeLabel;

-(void)startTimer;
-(void)stopTimer;

@end
