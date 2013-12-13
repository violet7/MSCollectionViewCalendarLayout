//
//  MSCollectionViewCalendarLayout+TouchTime.m
//  Pods
//
//  Created by Ilya Golovanov on 12/12/13.
//
//

#import "MSCollectionViewCalendarLayout+TouchTime.h"

@implementation MSCollectionViewCalendarLayout (TouchTime)

-(NSDate*)timeForPoint:(CGPoint)point {
  CGFloat topMin = self.dayColumnHeaderHeight + self.contentMargin.top + self.sectionMargin.top;
  CGFloat latestHour = 24;
  CGFloat earliestHour = 0;
  CGFloat sectionColumnHeight = (self.hourHeight * (latestHour - earliestHour));
  point.y = MIN(MAX(topMin, point.y), sectionColumnHeight + topMin) - topMin;
  
  int minutes = point.y / sectionColumnHeight * latestHour * 60.0;
  
  int section = MAX(0, point.x - self.timeRowHeaderWidth) / self.sectionWidth;
  NSDate *sectionDayDate = [self.delegate collectionView:self.collectionView layout:self dayForSection:section];
  NSDate *now = [[NSCalendar currentCalendar] dateFromComponents:[[NSCalendar currentCalendar] components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:sectionDayDate]];
  now = [now dateByAddingTimeInterval:minutes * 60.0];
  return now;
}

@end
