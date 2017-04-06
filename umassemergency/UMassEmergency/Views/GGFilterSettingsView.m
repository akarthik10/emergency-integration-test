//
//  GGFilterSettingsView.m
// UMassEmergenxy
//
//  Created by Görkem Güclü on 20.12.15.
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

#import "GGFilterSettingsView.h"

@interface GGFilterElementButton : UIButton

@property (nonatomic, strong) NSMutableArray *filterElements;
@property (nonatomic, strong) UIImage *icon;
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, readwrite) BOOL active;

@end

@implementation GGFilterElementButton

-(void)addFilterElements:(NSArray *)filterElements
{
    for (GGFilterElement *element in filterElements) {
        [self.filterElements addObject:element];
    }
    [self update];
}


-(void)addFilterElement:(GGFilterElement *)filterElement
{
    if (filterElement) {
        [self.filterElements addObject:filterElement];
        [self update];
    }
}

-(void)removeFilterElement:(GGFilterElement *)filterElement
{
    if (filterElement) {
        [self.filterElements removeObject:filterElement];
        [self update];
    }
}

-(void)setActive:(BOOL)active
{
    for (GGFilterElement *filterElement in self.filterElements) {
        filterElement.enabled = active;
    }
    [self update];
}

-(BOOL)active
{
    BOOL active = YES;
    for (GGFilterElement *element in self.filterElements) {
        active = active && element.enabled;
    }
    return active;
}

-(void)update
{
    if (self.active) {
        self.tintColor = [UIColor blackColor];
        [self setImage:self.icon forState:UIControlStateNormal];
        self.backgroundColor = self.color;
        self.layer.borderColor = [UIColor darkGrayColor].CGColor;
    }else{
        self.tintColor = [UIColor grayColor];
        [self setImage:[self.icon grayScaleImage] forState:UIControlStateNormal];
        self.backgroundColor = [UIColor whiteColor];
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
}

-(void)updateEnabled:(BOOL)enabled animated:(BOOL)animated withCompletion:(void (^)(void))completionBlock
{
    if (animated) {
        [UIView animateWithDuration:0.25
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             
                             self.transform = CGAffineTransformMakeScale(1.2, 1.2);
                             
                         } completion:^(BOOL finished) {

                             [UIView animateWithDuration:0.25
                                                   delay:0
                                                 options:UIViewAnimationOptionBeginFromCurrentState
                                              animations:^{

                                                  self.active = enabled;
                                                  
                                              } completion:^(BOOL finished) {

                                                  [UIView animateWithDuration:0.25
                                                                        delay:0
                                                                      options:UIViewAnimationOptionBeginFromCurrentState
                                                                   animations:^{
                                                                       
                                                                       self.transform = CGAffineTransformIdentity;
                                                                       
                                                                   } completion:^(BOOL finished) {

                                                                       if (completionBlock) {
                                                                           completionBlock();
                                                                       }
                                                                       
                                                                   }];
                                              }];
                         }];
    }else{
        
        [self update];
        
        if (completionBlock) {
            completionBlock();
        }
    }
}


+(instancetype)buttonWithType:(UIButtonType)buttonType
{
    GGFilterElementButton *button = [super buttonWithType:buttonType];
    if (button) {
        button.filterElements = [[NSMutableArray alloc] init];
    }
    return button;
}

@end


@interface GGFilterSettingsView ()

@property (nonatomic, strong) UIView *darkOverlay;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSDictionary *filterElementButtonsByGroupID;
@property (nonatomic, strong) NSDictionary *filtersByName;

@end

@implementation GGFilterSettingsView

-(void)changeFilterElementStatusWithName:(NSString *)name enabled:(BOOL)enabled animted:(BOOL)animated  withCompletion:(void (^)(void))completionBlock
{
    GGFilterElementButton *button = [self filterElementButtonWithName:name];
    [self.scrollView insertSubview:button aboveSubview:self.darkOverlay];
    
    // add y margin so button is not on the border of the scroll view
    CGRect scrollToFrame = CGRectInset(button.frame, 0, -20);
    [self.scrollView scrollRectToVisible:scrollToFrame animated:YES];
    
    [self showDarkOverlayAnimated:YES withCompletion:nil];

    [button updateEnabled:enabled animated:animated withCompletion:^{

        if (self.delegate && [self.delegate respondsToSelector:@selector(filterSettings:didSelectFilterElements:enabled:)]) {
            [self.delegate filterSettings:self didSelectFilterElements:button.filterElements enabled:button.active];
        }
        
        [self hideDarkOverlayAnimated:YES withCompletion:^{
            
            [self.scrollView insertSubview:button belowSubview:self.darkOverlay];
            if (completionBlock) {
                completionBlock();
            }
        }];
    }];
}

#pragma mark -

-(IBAction)filterElementButtonPressed:(id)sender
{
    GGFilterElementButton *button = (GGFilterElementButton *)sender;
    button.active = !button.active;
    
    NSArray *elements = button.filterElements;

    if (self.delegate && [self.delegate respondsToSelector:@selector(filterSettings:didSelectFilterElements:enabled:)]) {
        [self.delegate filterSettings:self didSelectFilterElements:elements enabled:button.active];
    }

}

-(void)showDarkOverlayAnimated:(BOOL)animated withCompletion:(void (^)(void))completionBlock
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.darkOverlay.alpha = 1;
                         } completion:^(BOOL finished) {
                             self.darkOverlay.alpha = 1;
                             if (completionBlock) {
                                 completionBlock();
                             }
                         }];
    }else{
        self.darkOverlay.alpha = 1;
    }
}

-(void)hideDarkOverlayAnimated:(BOOL)animated withCompletion:(void (^)(void))completionBlock
{
    if (animated) {
        [UIView animateWithDuration:0.5
                              delay:0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.darkOverlay.alpha = 0;
                         } completion:^(BOOL finished) {
                             self.darkOverlay.alpha = 0;
                             if (completionBlock) {
                                 completionBlock();
                             }
                         }];
    }else{
        self.darkOverlay.alpha = 0;
    }
}


#pragma mark -

-(CGFloat)height
{
    return self.scrollView.contentSize.height;
}

-(void)setFilters:(NSArray *)filters
{
    _filters = filters;
    if (filters) {
        [self updateFiltersList];
    }
}


-(void)updateFiltersList
{
    CGPoint offset = self.scrollView.contentOffset;
    
    for (UIView *subview in self.scrollView.subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview removeFromSuperview];
        }
    }
    
    CGFloat x = 7;
    CGFloat y = 10;
    CGFloat width = 44;
    CGFloat height = 44;
    
    NSMutableDictionary *filtersByName = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *buttonsByName = [[NSMutableDictionary alloc] init];
    for (GGFilterElementGroup *group in self.filters) {

        GGFilterElementButton *elementButton = [GGFilterElementButton buttonWithType:UIButtonTypeSystem];
        elementButton.icon = group.icon;
        elementButton.color = group.color;
        [elementButton addFilterElements:group.elements];
        elementButton.frame = CGRectMake(x, y, width, height);
        elementButton.layer.cornerRadius = 5;
        elementButton.layer.borderWidth = 0.2;
        [elementButton addTarget:self action:@selector(filterElementButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        y += height+10;
        [self.scrollView insertSubview:elementButton belowSubview:self.darkOverlay];
        
        for (GGFilterElement *element in group.elements) {
            [filtersByName setValue:element forKey:element.name];
        }
        
        [buttonsByName setValue:elementButton forKey:group.groupID];
    }
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, y);
    self.scrollView.contentOffset = offset;
    self.darkOverlay.frame = CGRectMake(0, 0, self.scrollView.contentSize.width, self.scrollView.contentSize.height);
    
    self.filtersByName = filtersByName;
    self.filterElementButtonsByGroupID = buttonsByName;
}

#pragma mark -

-(GGFilterElement *)filterElementWithName:(NSString *)name
{
    return [self.filtersByName valueForKey:name];
}

-(GGFilterElementButton *)filterElementButtonWithName:(NSString *)name
{
    GGFilterElement *element = [self filterElementWithName:name];
    return [self.filterElementButtonsByGroupID valueForKey:element.group.groupID];
}


#pragma mark -

-(void)setup
{
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.85];
    
    self.layer.cornerRadius = 5;
    self.layer.borderWidth = 0.2;
    self.clipsToBounds = YES;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.layer.masksToBounds = YES;
    [self addSubview:self.scrollView];
 
    self.darkOverlay = [[UIView alloc] initWithFrame:self.scrollView.bounds];
    self.darkOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.darkOverlay.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.6];
    self.darkOverlay.userInteractionEnabled = NO;
    [self.scrollView addSubview:self.darkOverlay];
    
    [self hideDarkOverlayAnimated:NO withCompletion:nil];
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.contentSize.height);
}

#pragma mark -

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

@end
