//
//  GGMapLegendView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 25.12.15.
//  Copyright © 2015 University of Massachusetts.
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

#import "GGMapLegendView.h"

@interface GGMapLegendView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *listView;
@property (nonatomic, strong) UIButton *overlayButton;

@end

@implementation GGMapLegendView

-(IBAction)overlayButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(mapLegendDidGetPressed:)]) {
        [self.delegate mapLegendDidGetPressed:self];
    }
}


-(void)showAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 1;
                         } completion:nil];
    }else{
        self.alpha = 1;
    }
}

-(void)hideAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.alpha = 0.2;
                         } completion:nil];
    }else{
        self.alpha = 0.2;
    }
}

#pragma mark -

-(void)setLegendItems:(NSArray *)legendItems
{
    _legendItems = legendItems;
    if (legendItems) {
        [self update];
    }
}


-(void)update
{
    CGFloat listWidth = self.frame.size.width;

    [self.listView removeFromSuperview];
    self.listView = nil;

    self.listView = [[UIView alloc] init];
    
    CGFloat rowHeight = 12;
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat boxX = listWidth/2;
    CGFloat boxY = labelY;
    for (GGMapLegendItem *item in self.legendItems) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, listWidth/2, rowHeight)];
        UIView *colorBox = [[UIView alloc] initWithFrame:CGRectMake(boxX+2, boxY, rowHeight, rowHeight)];
        
        label.text = [NSString stringWithFormat:@"%@",item.dbzValue];
        colorBox.backgroundColor = item.color;
        
        label.font = [UIFont boldSystemFontOfSize:9];
        label.textAlignment = NSTextAlignmentRight;
        label.textColor = [UIColor whiteColor];
        
        colorBox.layer.borderColor = [UIColor blackColor].CGColor;
        colorBox.layer.borderWidth = 1;
        
        [self.listView addSubview:label];
        [self.listView addSubview:colorBox];
        
        labelY += rowHeight;
        boxY += rowHeight;
    }
    self.listView.frame = CGRectMake(0, 0, listWidth, labelY);
    [self.scrollView addSubview:self.listView];
    self.scrollView.contentSize = self.listView.frame.size;
}


- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(void)setup
{
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 20)];
    self.titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.titleLabel.font = [UIFont boldSystemFontOfSize:10];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.text = @"DBZ";
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, self.titleLabel.frame.size.height, self.bounds.size.width, self.bounds.size.height)];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.scrollView.alwaysBounceHorizontal = NO;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.scrollsToTop = NO;

    self.overlayButton = [[UIButton alloc] initWithFrame:self.bounds];
    [self.overlayButton addTarget:self action:@selector(overlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self addSubview:self.titleLabel];
    [self addSubview:self.scrollView];
    [self addSubview:self.overlayButton];
    
    self.backgroundColor = [[UIColor grayColor] colorWithAlphaComponent:0.5];
    self.clipsToBounds = YES;
    self.layer.cornerRadius = 5;
}

@end
