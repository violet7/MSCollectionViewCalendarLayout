//
//  MSCalendarViewController.m
//  Example
//
//  Created by Eric Horacek on 2/26/13.
//  Copyright (c) 2013 Monospace Ltd. All rights reserved.
//

#import "MSCalendarViewController.h"
#import "MSCollectionViewCalendarLayout.h"
#import "MSEvent.h"
// Collection View Reusable Views
#import "MSGridline.h"
#import "MSTimeRowHeaderBackground.h"
#import "MSDayColumnHeaderBackground.h"
#import "MSEventCell.h"
#import "MSDayColumnHeader.h"
#import "MSTimeRowHeader.h"
#import "MSCurrentTimeIndicator.h"
#import "MSCurrentTimeGridline.h"

#import <EventKit/EventKit.h>
#import "../../MSCollectionViewCalendarLayout/MSCollectionViewCalendarLayout+TouchTime.h"

NSString * const MSEventCellReuseIdentifier = @"MSEventCellReuseIdentifier";
NSString * const MSDayColumnHeaderReuseIdentifier = @"MSDayColumnHeaderReuseIdentifier";
NSString * const MSTimeRowHeaderReuseIdentifier = @"MSTimeRowHeaderReuseIdentifier";

@interface MSCalendarViewController () <MSCollectionViewDelegateCalendarLayout>
{
    NSMutableArray* tempDays;
}
@property (nonatomic, strong) MSCollectionViewCalendarLayout *collectionViewCalendarLayout;

@property (nonatomic) EKEventStore * store;
@end

@implementation MSCalendarViewController

- (id)init
{
    self.collectionViewCalendarLayout = [[MSCollectionViewCalendarLayout alloc] init];
    self.collectionViewCalendarLayout.delegate = self;
    self = [super initWithCollectionViewLayout:self.collectionViewCalendarLayout];
    
    UILongPressGestureRecognizer* longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
    [self.collectionView addGestureRecognizer:longGesture];
    
    return self;
}

-(void)onLongPress:(UILongPressGestureRecognizer*)recoginzer {
    if (recoginzer.state == UIGestureRecognizerStateBegan) {
       NSDate* date = [_collectionViewCalendarLayout timeForPoint:[recoginzer locationInView:self.collectionView]];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"touchTime" message:[date descriptionWithLocale:[NSLocale currentLocale] ]
                                                                                                        delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}


-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_collectionViewCalendarLayout.sectionLayoutType == MSSectionLayoutTypeHorizontalTile) {
        if (scrollView.contentOffset.x < 0.0f) {
            [self appendPastDates];
        }
        if (scrollView.contentOffset.x > (scrollView.contentSize.width - CGRectGetWidth(scrollView.bounds))) {
            [self appendFutureDates];
        }
    } else {
        if (scrollView.contentOffset.y > (scrollView.contentSize.height - CGRectGetHeight(scrollView.bounds))) {
            [self appendFutureDates];
        }
        if (scrollView.contentOffset.y < 0.0f) {
            [self appendPastDates];
        }
    }
}

- (void) appendFutureDates {
	
	[self shiftDatesByComponents:((^{
		NSDateComponents *dateComponents = [NSDateComponents new];
		dateComponents.day = 15;
		return dateComponents;
	})())];
	
}

- (void) appendPastDates {
	
	[self shiftDatesByComponents:((^{
		NSDateComponents *dateComponents = [NSDateComponents new];
		dateComponents.day = -15;
		return dateComponents;
	})())];
	
}

-(NSInteger) daysBetweenDate: (NSDate *)firstDate andDate: (NSDate *)secondDate
{
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [currentCalendar components: NSDayCalendarUnit
                                                      fromDate: firstDate
                                                        toDate: secondDate
                                                       options: 0];
    
    NSInteger days = [components day];
    return days;
}

- (void) shiftDatesByComponents:(NSDateComponents *)components {

    NSIndexSet* set = [_collectionViewCalendarLayout sectionsInRect:self.collectionView.bounds];
    CGRect fromRect = [_collectionViewCalendarLayout rectForSection:[set lastIndex]];
    NSDate* fromDate = [tempDays objectAtIndex:components.day > 0 ? [set firstIndex] : [set lastIndex]];
    NSDate* lastDate = [tempDays objectAtIndex:[set lastIndex]];
    [tempDays removeAllObjects];
    int toSection = 0;
    
    for (int i = 0; i < abs(components.day); i++) {
        NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = components.day > 0 ? i : (components.day + 1) + i;
        
        NSDate* date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:fromDate options:0];
        [tempDays addObject:date];
        if ([self daysBetweenDate:lastDate andDate:date] == 0)
            toSection = i;
    }
    
    [self.collectionViewCalendarLayout invalidateLayoutCache];
    [self.collectionView reloadData];
    
    CGRect toRect = [_collectionViewCalendarLayout rectForSection:toSection];
    [self.collectionView setContentOffset:CGPointMake(toRect.origin.x - fromRect.origin.x + self.collectionView.contentOffset.x , toRect.origin.y - fromRect.origin.y + self.collectionView.contentOffset.y)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.collectionViewCalendarLayout.sectionLayoutType = MSSectionLayoutTypeHorizontalTile;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionViewCalendarLayout.hourHeight = 40;
    
    [self.collectionView registerClass:MSEventCell.class forCellWithReuseIdentifier:MSEventCellReuseIdentifier];
    [self.collectionView registerClass:MSDayColumnHeader.class forSupplementaryViewOfKind:MSCollectionElementKindDayColumnHeader withReuseIdentifier:MSDayColumnHeaderReuseIdentifier];
    [self.collectionView registerClass:MSTimeRowHeader.class forSupplementaryViewOfKind:MSCollectionElementKindTimeRowHeader withReuseIdentifier:MSTimeRowHeaderReuseIdentifier];
    
    // These are optional. If you don't want any of the decoration views, just don't register a class for them.
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeIndicator.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeIndicator];
    [self.collectionViewCalendarLayout registerClass:MSCurrentTimeGridline.class forDecorationViewOfKind:MSCollectionElementKindCurrentTimeHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindVerticalGridline];
    [self.collectionViewCalendarLayout registerClass:MSGridline.class forDecorationViewOfKind:MSCollectionElementKindHorizontalGridline];
    [self.collectionViewCalendarLayout registerClass:MSTimeRowHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindTimeRowHeaderBackground];
    [self.collectionViewCalendarLayout registerClass:MSDayColumnHeaderBackground.class forDecorationViewOfKind:MSCollectionElementKindDayColumnHeaderBackground];
    
    [self store];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.collectionViewCalendarLayout scrollCollectionViewToClosetSectionToCurrentTimeAnimated:NO];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // On iPhone, adjust width of sections on interface rotation. No necessary in horizontal layout (iPad)
    if (self.collectionViewCalendarLayout.sectionLayoutType == MSSectionLayoutTypeVerticalTile) {
        [self.collectionViewCalendarLayout invalidateLayoutCache];
        // These are the only widths that are defined by default. There are more that factor into the overall width.
        self.collectionViewCalendarLayout.sectionWidth = (CGRectGetWidth(self.collectionView.frame) - self.collectionViewCalendarLayout.timeRowHeaderWidth - self.collectionViewCalendarLayout.contentMargin.right);
        [self.collectionView reloadData];
    }
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

#pragma mark - MSCalendarViewController

- (void)loadData
{
        tempDays = [NSMutableArray array];
        NSDate* fromDate = [NSDate date];
        NSDateComponents * dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = 0;
        fromDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:fromDate options:0];
        for (int i = 0; i < 15; i++) {
            dateComponents = [[NSDateComponents alloc] init];
            dateComponents.day = i;
            NSDate* date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:fromDate options:0];
            [tempDays addObject:date];
        }
        
        [self.collectionViewCalendarLayout invalidateLayoutCache];
        [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [tempDays count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray * events = [self eventsForDate:[tempDays objectAtIndex:section]];
    return [events count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * events = [self eventsForDate:[tempDays objectAtIndex:indexPath.section]];
    EKEvent * ekEvent = [events objectAtIndex:indexPath.item];
    MSEventCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:MSEventCellReuseIdentifier forIndexPath:indexPath];
    MSEvent *event = [[MSEvent alloc] init];
    event.title = ekEvent.title;
    cell.event = event;
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *view;
    if (kind == MSCollectionElementKindDayColumnHeader) {
        MSDayColumnHeader *dayColumnHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSDayColumnHeaderReuseIdentifier forIndexPath:indexPath];
        NSDate *day = [self.collectionViewCalendarLayout dateForDayColumnHeaderAtIndexPath:indexPath];
        NSDate *currentDay = [self currentTimeComponentsForCollectionView:self.collectionView layout:self.collectionViewCalendarLayout];
        dayColumnHeader.day = day;
        dayColumnHeader.currentDay = [[day beginningOfDay] isEqualToDate:[currentDay beginningOfDay]];
        view = dayColumnHeader;
    } else if (kind == MSCollectionElementKindTimeRowHeader) {
        MSTimeRowHeader *timeRowHeader = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:MSTimeRowHeaderReuseIdentifier forIndexPath:indexPath];
        timeRowHeader.time = [self.collectionViewCalendarLayout dateForTimeRowHeaderAtIndexPath:indexPath];
        view = timeRowHeader;
    }
    return view;
}

#pragma mark - MSCollectionViewCalendarLayout

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout dayForSection:(NSInteger)section
{
    return [tempDays objectAtIndex:section];
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout startTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * events = [self eventsForDate:[tempDays objectAtIndex:indexPath.section]];
    EKEvent * ekEvent = [events objectAtIndex:indexPath.item];
    return ekEvent.startDate;
    return [tempDays objectAtIndex:indexPath.section];
}

- (NSDate *)collectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout endTimeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray * events = [self eventsForDate:[tempDays objectAtIndex:indexPath.section]];
    EKEvent * ekEvent = [events objectAtIndex:indexPath.item];
    return ekEvent.endDate;
    return [[tempDays objectAtIndex:indexPath.section] dateByAddingTimeInterval:(60 * 60 * 3)];
        //return [event.start dateByAddingTimeInterval:(60 * 60 * 3)];
}

- (NSDate *)currentTimeComponentsForCollectionView:(UICollectionView *)collectionView layout:(MSCollectionViewCalendarLayout *)collectionViewCalendarLayout
{
    return [NSDate date];
}

- (EKEventStore *)store
{
    if (_store == nil)
      {
        _store = [[EKEventStore alloc] init];
          if ([EKEventStore authorizationStatusForEntityType:(EKEntityTypeEvent)] != EKAuthorizationStatusAuthorized)
              [_store requestAccessToEntityType:(EKEntityTypeEvent) completion:^(BOOL granted, NSError *error) {
                  if (granted) [self loadData];
                  ;
              }]; else
                  [self loadData];
      }
    return _store;
}

- (NSArray *)eventsForDate:(NSDate *)date
{
    
    NSDateComponents * componentsBegin = [[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:date];
    NSDateComponents * componentsDay = [[NSDateComponents alloc] init];
    componentsDay.day = 1;
    
    NSDate * dayBegin = [[NSCalendar currentCalendar] dateFromComponents:componentsBegin];
    NSDate * dayEnd = [[NSCalendar currentCalendar] dateByAddingComponents:componentsDay toDate:dayBegin options:0];
    
    NSPredicate * predicate = [self.store predicateForEventsWithStartDate:dayBegin endDate:dayEnd calendars:nil];
    return [self.store eventsMatchingPredicate:predicate];

}
@end
