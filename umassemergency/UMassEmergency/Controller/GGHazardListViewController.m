//
//  GGHazardListViewController.m
//  WindContours
//
//  Created by Görkem Güclü on 02.06.16.
//  Copyright © 2016 University of Massachusetts. All rights reserved.
//
//  This development was in part funded by the MobilityFirst Future Internet 
//  Architecture project.
//

#import "GGHazardListViewController.h"
#import "GGHazardListTableViewCell.h"
#import "GGHazardView.h"
#import "GGAlertListSectionHeaderView.h"
#import "GGApp.h"

typedef enum : NSUInteger {
    GGListSectionActive = 0,
    GGListSectionExpired = 1
} GGListSection;


@interface GGHazardListViewController () <UITableViewDelegate,UITableViewDataSource,GGAlertListSectionHeaderDelegate,GGAppLocationDelegate>

@property (nonatomic, strong) GGApp *app;
@property (nonatomic, strong) UISegmentedControl *sortListSegmentedControl;
@property (nonatomic, strong) UIView *sortListContainerView;
@property (nonatomic, strong) NSMutableDictionary *tableSectionsVisibilty;

@end

@implementation GGHazardListViewController

#pragma mark - IBAction

-(IBAction)refreshControlTriggered:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hazardListDidRefreshTable:)]) {
        [self.delegate hazardListDidRefreshTable:self];
    }
}

-(IBAction)dismissButtonPressed:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hazardListDidCancel:)]) {
        [self.delegate hazardListDidCancel:self];
    }
}

-(IBAction)sortListSegmentedControlValueChanged:(id)sender
{
    if (self.sortListSegmentedControl.selectedSegmentIndex == 0) {
        // by date
        self.listSortedBy = GGListSortedByDate;
        
    }else if (self.sortListSegmentedControl.selectedSegmentIndex == 1) {
        // by distance
        self.listSortedBy = GGListSortedByDistance;
        
    }
    [self requestDateUpdate];
}

#pragma mark - Table

-(void)setUpdateDate:(NSDate *)date
{
    NSString *updateString = [NSString stringWithFormat:@"Last Update: %@",[NSDateFormatter localizedStringFromDate:date dateStyle:NSDateFormatterShortStyle timeStyle:NSDateFormatterShortStyle]];
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:updateString];
    [self.tableRefreshControl setAttributedTitle:string];
    [self.tableRefreshControl endRefreshing];
}

-(void)reloadListData
{
    [self.table reloadData];
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.hazardViews.count == 0) {
        return 1;
    }
    return 3;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.hazardViews.count == 0) {
        return 1;
    }
    
    NSNumber *visibilityObject = [self.tableSectionsVisibilty objectForKey:[NSNumber numberWithInteger:section]];
    if (visibilityObject && ![visibilityObject boolValue]) {
        return 0;
    }
    
    NSArray *hazardViews;
    if (section == GGListSectionActive) {
        hazardViews = self.activeHazardViews;
    }else if (section == GGListSectionExpired) {
        hazardViews = self.expiredHazardViews;
    }
    
    NSUInteger count = hazardViews.count;
    if (count == 0) {
        return 1;
    }
    return count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GGHazardListTableViewCell *cell = (GGHazardListTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"GGHazardListTableViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.textAlignment = NSTextAlignmentLeft;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    cell.textLabel.textColor = [UIColor blackColor];
    
    if (self.hazardViews.count == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = @"Currently no emergency available.";
        cell.textLabel.textColor = [UIColor grayColor];
        return cell;
    }
    
    NSString *noHazardsAvailableText = @"";
    NSArray *hazardViews;
    if (indexPath.section == GGListSectionActive) {
        hazardViews = self.activeHazardViews;
        noHazardsAvailableText = @"No active emergencies";
    }else if (indexPath.section == GGListSectionExpired) {
        hazardViews = self.expiredHazardViews;
        noHazardsAvailableText = @"No expired emergencies";
    }
    
    NSUInteger count = hazardViews.count;
    if (count == 0) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.text = noHazardsAvailableText;
        return cell;
    }
    
    GGHazardView *hazardView = [hazardViews objectAtIndex:indexPath.row];
    cell.hazard = hazardView.hazard;
    
    cell.accessoryType = UITableViewCellAccessoryDetailButton;
    
    return cell;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSUInteger count = self.hazardViews.count;
    if (count == 0) {
        return nil;
    }
    
    GGAlertListSectionHeaderView *header = [[GGAlertListSectionHeaderView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 34)];
    header.section = section;
    header.delegate = self;
    
    NSNumber *visibilityObject = [self.tableSectionsVisibilty objectForKey:[NSNumber numberWithInteger:section]];
    if (visibilityObject) {
        BOOL visible = [visibilityObject boolValue];
        if (visible) {
            header.visibiltyButtonTitle = @"Collapse";
        }else{
            header.visibiltyButtonTitle = @"Expand";
        }
    }
    
    if (section == GGListSectionActive) {
        header.title = [NSString stringWithFormat:@"Active (%li)",(long)self.activeHazardViews.count];
        return header;
    }else if (section == GGListSectionExpired) {
        header.title = @"Expired";
        return header;
    }
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSUInteger count = self.hazardViews.count;
    if (count == 0) {
        return 0;
    }
    
    if (section == GGListSectionActive) {
        return 34;
    }else if (section == GGListSectionExpired) {
        return 34;
    }
    return 0;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *hazardViews;
    if (indexPath.section == GGListSectionActive) {
        hazardViews = self.activeHazardViews;
    }else if (indexPath.section == GGListSectionExpired) {
        hazardViews = self.expiredHazardViews;
    }
    
    if (hazardViews.count == 0) {
        return UITableViewAutomaticDimension;
    }
    
    return 110;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSUInteger count = self.hazardViews.count;
    if (count == 0) {
        return;
    }
    
    NSArray *hazardViews = self.hazardViews;
    if (indexPath.section == GGListSectionActive) {
        hazardViews = self.activeHazardViews;
    }else if (indexPath.section == GGListSectionExpired) {
        hazardViews = self.expiredHazardViews;
    }
    
    if (hazardViews.count == 0) {
        return;
    }
    
    GGHazardView *hazardView = [hazardViews objectAtIndex:indexPath.row];
    GGHazard *hazard = hazardView.hazard;
    if (self.delegate && [self.delegate respondsToSelector:@selector(hazardList:didSelectHazard:)]) {
        [self.delegate hazardList:self didSelectHazard:hazard];
    }
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
    NSArray *hazardViews;
    if (indexPath.section == GGListSectionActive) {
        hazardViews = self.activeHazardViews;
    }else if (indexPath.section == GGListSectionExpired) {
        hazardViews = self.expiredHazardViews;
    }
    
    GGHazardView *hazardView = [hazardViews objectAtIndex:indexPath.row];

    if (self.delegate && [self.delegate respondsToSelector:@selector(hazardList:didSelectHazardDetail:)]) {
        [self.delegate hazardList:self didSelectHazardDetail:hazardView.hazard];
    }
}



#pragma mark - AlertListSectionHeaderDelegate

-(void)alertListSectionHeaderDidPressVisibilityButton:(GGAlertListSectionHeaderView *)view
{
    NSNumber *sectionObject = [NSNumber numberWithInteger:view.section];
    NSNumber *visibilityObject = [self.tableSectionsVisibilty objectForKey:sectionObject];
    BOOL visible = [visibilityObject boolValue];
    
    BOOL newVisible = !visible;
    NSNumber *newVisibilityObject = [NSNumber numberWithBool:newVisible];
    [self.tableSectionsVisibilty setObject:newVisibilityObject forKey:sectionObject];
    
    [self.table reloadSections:[NSIndexSet indexSetWithIndex:view.section] withRowAnimation:UITableViewRowAnimationAutomatic];
}

#pragma mark -

-(void)updateHeading
{
    NSArray *cells = [self.table visibleCells];
    for (GGHazardListTableViewCell *cell in cells) {
        [cell updateCompass];
    }
}

#pragma mark - App Location

-(void)app:(GGApp *)app didUpdateLocations:(NSArray *)locations
{
    [self updateHeading];
}

-(void)app:(GGApp *)app didUpdateHeading:(CLHeading *)heading
{
    [self updateHeading];
}

#pragma mark -

-(void)requestDateUpdate
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(hazardListNeedsDateUpdate:)]) {
        [self.delegate hazardListNeedsDateUpdate:self];
    }
}

#pragma mark -

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.app addLocationDelegate:self];

    [self requestDateUpdate];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.title = @"Emergencies";
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.app = [GGApp instance];
    
    self.table = [[UITableView alloc] initWithFrame:CGRectMake(0, 50, self.view.bounds.size.width, self.view.bounds.size.height) style:UITableViewStylePlain];
    self.table.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.table.delegate = self;
    self.table.dataSource = self;
    [self.view addSubview:self.table];
    
    self.tableRefreshControl = [[UIRefreshControl alloc] init];
    [self.tableRefreshControl addTarget:self action:@selector(refreshControlTriggered:) forControlEvents:UIControlEventValueChanged];
    [self.table addSubview:self.tableRefreshControl];
    [self.tableRefreshControl endRefreshing];
    
    self.sortListSegmentedControl = [[UISegmentedControl alloc] initWithFrame:CGRectMake(0, 0, 200, 36)];
    [self.sortListSegmentedControl addTarget:self action:@selector(sortListSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.sortListSegmentedControl insertSegmentWithTitle:@"By time" atIndex:0 animated:NO];
    [self.sortListSegmentedControl insertSegmentWithTitle:@"By distance" atIndex:1 animated:NO];
    self.sortListSegmentedControl.selectedSegmentIndex = 0;
    self.listSortedBy = GGListSortedByDate;

    self.sortListContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 50)];
    [self.sortListContainerView addSubview:self.sortListSegmentedControl];
    self.sortListContainerView.backgroundColor = [UIColor whiteColor];
    self.sortListContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.sortListSegmentedControl.center = CGPointMake(CGRectGetMidX(self.sortListContainerView.frame), CGRectGetMidY(self.sortListContainerView.frame));
    [self.view addSubview:self.sortListContainerView];

    self.tableSectionsVisibilty = [[NSMutableDictionary alloc] init];
    [self.tableSectionsVisibilty setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:GGListSectionActive]];
    [self.tableSectionsVisibilty setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInteger:GGListSectionExpired]];
    
    UIBarButtonItem *dismissButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissButtonPressed:)];
    self.navigationItem.rightBarButtonItem = dismissButton;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.app removeLocationDelegate:self];
}

-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.sortListContainerView.frame = CGRectMake(0, 0, self.view.bounds.size.width, 50);
    CGFloat tableY = self.sortListContainerView.frame.origin.y+self.sortListContainerView.frame.size.height;
    self.table.frame = CGRectMake(0, tableY, self.view.bounds.size.width, self.view.bounds.size.height-tableY);

    self.sortListSegmentedControl.center = CGPointMake(CGRectGetMidX(self.sortListContainerView.frame), CGRectGetMidY(self.sortListContainerView.frame));
}


@end
