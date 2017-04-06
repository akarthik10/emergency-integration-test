//
//  GGHazardListViewController.h
//  WindContours
//
//  Created by Görkem Güclü on 02.06.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import <UIKit/UIKit.h>
#import "GGHazard.h"

typedef enum : NSUInteger {
    GGListSortedByDate = 0,
    GGListSortedByDistance = 1,
} GGListSortedBy;

@protocol GGHazardListDelegate;
@interface GGHazardListViewController : UIViewController

@property (nonatomic, assign) id<GGHazardListDelegate> delegate;
@property (nonatomic, strong) IBOutlet UITableView *table;
@property (nonatomic, strong) IBOutlet UIRefreshControl *tableRefreshControl;

@property (nonatomic, readwrite) GGListSortedBy listSortedBy;

@property (nonatomic, strong) NSArray *hazardViews;
@property (nonatomic, strong) NSArray *activeHazardViews;
@property (nonatomic, strong) NSArray *pendingHazardViews;
@property (nonatomic, strong) NSArray *expiredHazardViews;

-(void)setUpdateDate:(NSDate *)date;
-(void)reloadListData;
-(void)updateHeading;

@end

@protocol GGHazardListDelegate <NSObject>

-(void)hazardListNeedsDateUpdate:(GGHazardListViewController *)controller;
-(void)hazardListDidRefreshTable:(GGHazardListViewController *)controller;
-(void)hazardList:(GGHazardListViewController *)controller didSelectHazard:(GGHazard *)hazard;
-(void)hazardList:(GGHazardListViewController *)controller didSelectHazardDetail:(GGHazard *)hazard;
-(void)hazardListDidCancel:(GGHazardListViewController *)controller;

@end
